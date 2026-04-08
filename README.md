# Hayati

Hayati is the mobile community platform for El Haya Foundation. This repo contains the Phase 1 scaffold: Arabic-first enrollment, signed-QR identity, resident home, and the supporting Flutter, Cloud Functions, Firestore rules, and CI structure needed for later phases.

## Architecture

The authoritative implementation guide is [hayati-architecture.md](./hayati-architecture.md).

## Run the app

The app uses three Flutter flavors and a matching `--dart-define=FLAVOR=...` value.

```bash
flutter run -t lib/main_dev.dart --flavor dev --dart-define=FLAVOR=dev
flutter run -t lib/main_staging.dart --flavor staging --dart-define=FLAVOR=staging
flutter run -t lib/main_prod.dart --flavor prod --dart-define=FLAVOR=prod
```

## Firebase setup

The Firebase environments are wired to:

- `hayati-dev-20260408`
- `hayati-staging-20260408`
- `hayati-prod-20260408`

The operational runbook is [docs/runbooks/firebase-setup.md](./docs/runbooks/firebase-setup.md).

The condensed staging deploy command is:

```bash
./scripts/deploy-staging.sh
```

## Cloud Functions bootstrap

- Set `QR_HMAC_SECRET` in Secret Manager before deploying the functions.
- Bootstrap the first `super_admin` with the Admin SDK script:

```bash
node scripts/bootstrap_super_admin.js --uid <firebase-uid>
```

## Tests

```bash
flutter analyze
flutter test
cd functions && npm ci && npm run lint && npm test
cd rules-tests && npm ci && npm test
```

## Notes

- Tajawal font files are tracked under `assets/fonts/` as build-time assets.
- Phase 2 through Phase 6 directories exist only as stubs for now.
- iOS is deferred for this PR; Android flavor wiring is complete first.
