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

## Firebase rules

Deploy only after reviewing the architecture doc and running the rules test suite.

```bash
firebase deploy --only firestore:rules,firestore:indexes
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

- Firebase projects are placeholders for now.
- Tajawal font files are tracked under `assets/fonts/` as build-time assets.
- Phase 2 through Phase 6 directories exist only as stubs for now.
