#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "Deploy failed: $1" >&2
  exit 1
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
force=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      force=true
      shift
      ;;
    -h|--help)
      echo "Usage: ./scripts/deploy-staging.sh [--force]" >&2
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

current_branch="$(git branch --show-current 2>/dev/null || true)"
if [[ "$current_branch" != "main" && "$force" != true ]]; then
  fail "Refusing to deploy staging from '$current_branch'. Re-run on main or pass --force."
fi

"$script_dir/preflight.sh" --project staging

firebase deploy --only firestore:rules,firestore:indexes,functions -P staging
