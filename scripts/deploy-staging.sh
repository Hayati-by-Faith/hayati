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

flutter build web --release --dart-define=FLAVOR=staging \
  --dart-define=FIREBASE_WEB_API_KEY_STAGING="${FIREBASE_WEB_API_KEY_STAGING:?Missing FIREBASE_WEB_API_KEY_STAGING}" \
  --dart-define=FIREBASE_WEB_APP_ID_STAGING="${FIREBASE_WEB_APP_ID_STAGING:?Missing FIREBASE_WEB_APP_ID_STAGING}" \
  --dart-define=FIREBASE_WEB_MEASUREMENT_ID_STAGING="${FIREBASE_WEB_MEASUREMENT_ID_STAGING:-}" \
  --dart-define=FIREBASE_WEB_APPCHECK_SITE_KEY="${FIREBASE_WEB_APPCHECK_SITE_KEY_STAGING:?Missing FIREBASE_WEB_APPCHECK_SITE_KEY_STAGING}"

firebase deploy --only firestore:rules,firestore:indexes,functions,hosting:staging -P staging

# Tag the rules + web bundle for auditable rollback (§26 hardening).
deploy_ts="$(date -u +%Y%m%d-%H%M%SZ)"
rules_tag="firestore-rules-staging-${deploy_ts}"
web_tag="web-staging-${deploy_ts}"
git tag -a "${rules_tag}" -m "Staging deploy ${deploy_ts} — firestore.rules" 2>/dev/null || true
git tag -a "${web_tag}" -m "Staging deploy ${deploy_ts} — web bundle" 2>/dev/null || true
echo "Tagged staging deploy: ${rules_tag} and ${web_tag}"
