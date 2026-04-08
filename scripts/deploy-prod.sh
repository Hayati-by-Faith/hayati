#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "Deploy failed: $1" >&2
  exit 1
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
force=false
confirmed=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      force=true
      shift
      ;;
    --i-really-mean-it)
      confirmed=true
      shift
      ;;
    -h|--help)
      echo "Usage: ./scripts/deploy-prod.sh --i-really-mean-it [--force]" >&2
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

if [[ "$confirmed" != true ]]; then
  fail "Refusing to deploy prod without --i-really-mean-it"
fi

current_branch="$(git branch --show-current 2>/dev/null || true)"
if [[ "$current_branch" != "main" && "$force" != true ]]; then
  fail "Refusing to deploy prod from '$current_branch'. Re-run on main or pass --force."
fi

"$script_dir/preflight.sh" --project prod

firebase deploy --only firestore:rules,firestore:indexes,functions -P prod
