#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "Preflight failed: $1" >&2
  exit 1
}

usage() {
  cat >&2 <<'EOF'
Usage: scripts/preflight.sh --project <dev|staging|prod>
EOF
  exit 1
}

project_alias=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      project_alias="${2:-}"
      shift 2
      ;;
    --project=*)
      project_alias="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$project_alias" ]] || usage

case "$project_alias" in
  dev) project_id="hayati-dev-20260408" ;;
  staging) project_id="hayati-staging-20260408" ;;
  prod) project_id="hayati-prod-20260408" ;;
  *)
    fail "Unknown project alias '$project_alias'"
    ;;
esac

command -v firebase >/dev/null 2>&1 || fail "firebase CLI is not installed or not on PATH"
command -v gcloud >/dev/null 2>&1 || fail "gcloud CLI is not installed or not on PATH"

firebase_version="$(firebase --version 2>&1)" || fail "firebase CLI is installed but could not report a version"
echo "firebase version: ${firebase_version}"

login_output="$(firebase login:list 2>&1)" || fail "Firebase CLI is not authenticated. Run 'firebase login' first."
echo "firebase account: ${login_output}"

projects_output="$(firebase projects:list 2>&1)" || fail "Firebase CLI cannot list projects. Check authentication and permissions."
if ! printf '%s\n' "$projects_output" | grep -Fq "$project_id"; then
  fail "Firebase project '$project_id' was not found in the current account"
fi

gcloud secrets describe QR_HMAC_SECRET --project="$project_id" >/dev/null 2>&1 \
  || fail "QR_HMAC_SECRET is missing or inaccessible in project '$project_id'"

echo "Preflight passed for ${project_alias} (${project_id})"
