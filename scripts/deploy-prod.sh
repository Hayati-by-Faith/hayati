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

flutter build web --release --dart-define=FLAVOR=prod \
  --dart-define=FIREBASE_WEB_API_KEY_PROD="${FIREBASE_WEB_API_KEY_PROD:?Missing FIREBASE_WEB_API_KEY_PROD}" \
  --dart-define=FIREBASE_WEB_APP_ID_PROD="${FIREBASE_WEB_APP_ID_PROD:?Missing FIREBASE_WEB_APP_ID_PROD}" \
  --dart-define=FIREBASE_WEB_MEASUREMENT_ID_PROD="${FIREBASE_WEB_MEASUREMENT_ID_PROD:-}" \
  --dart-define=FIREBASE_WEB_APPCHECK_SITE_KEY="${FIREBASE_WEB_APPCHECK_SITE_KEY_PROD:?Missing FIREBASE_WEB_APPCHECK_SITE_KEY_PROD}"

firebase deploy --only firestore:rules,firestore:indexes,functions,hosting:prod -P prod

# Tag the rules + web bundle for auditable rollback (§26 hardening, CLAUDE.md
# deployment policy: "Always tag firestore.rules before deploy for rollback").
deploy_ts="$(date -u +%Y%m%d-%H%M%SZ)"
rules_tag="firestore-rules-prod-${deploy_ts}"
web_tag="web-prod-${deploy_ts}"
git tag -a "${rules_tag}" -m "Prod deploy ${deploy_ts} — firestore.rules" 2>/dev/null || true
git tag -a "${web_tag}" -m "Prod deploy ${deploy_ts} — web bundle" 2>/dev/null || true
echo "Tagged prod deploy: ${rules_tag} and ${web_tag}"
