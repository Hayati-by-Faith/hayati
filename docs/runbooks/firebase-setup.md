# Firebase Setup Runbook

This runbook covers the one-time Firebase wiring and the repeatable deployment path for Hayati Phase 1.

## One-time setup

The repo is wired to these Firebase projects:

- `hayati-dev-20260408`
- `hayati-staging-20260408`
- `hayati-prod-20260408`

The FlutterFire CLI has already been used to generate the flavor-specific Firebase options files:

- `lib/firebase_options_dev.dart`
- `lib/firebase_options_staging.dart`
- `lib/firebase_options_prod.dart`

The Android app registrations are flavor-specific:

- `org.elhaya.hayati.dev` for dev
- `org.elhaya.hayati.staging` for staging
- `org.elhaya.hayati` for prod

The iOS side is intentionally deferred for this phase. No `GoogleService-Info.plist` files are committed yet.

## Secret setup

Create the QR signing secret in dev and staging before deploying functions:

```bash
echo -n "$(openssl rand -hex 32)" | gcloud secrets create QR_HMAC_SECRET --project=hayati-dev-20260408 --replication-policy=automatic --data-file=-
echo -n "$(openssl rand -hex 32)" | gcloud secrets create QR_HMAC_SECRET --project=hayati-staging-20260408 --replication-policy=automatic --data-file=-
# prod secret deliberately deferred until Phase 1 is ready for prod
```

## Functions service account access

Grant the functions runtime service account permission to read the secret. The project number can be read from the generated `google-services.json` files:

```bash
gcloud projects add-iam-policy-binding hayati-dev-20260408 --member=serviceAccount:<PROJECT_NUMBER>-compute@developer.gserviceaccount.com --role=roles/secretmanager.secretAccessor
gcloud projects add-iam-policy-binding hayati-staging-20260408 --member=serviceAccount:<PROJECT_NUMBER>-compute@developer.gserviceaccount.com --role=roles/secretmanager.secretAccessor
```

## Bootstrap

Bootstrap the first `super_admin` out of band with the Admin SDK script:

```bash
node scripts/bootstrap_super_admin.js --uid <uid>
```

Run it once for each environment only after the Firebase project and secret setup is complete.

## Deploy

Deploy staging from the repo root:

```bash
./scripts/deploy-staging.sh
```

The staging deploy script runs the preflight checks, rules tests, and Firebase deploy target selection.

## Rollback

Tag `firestore.rules` before every deploy so rollback is simple and auditable.

```bash
git checkout <tag> -- firestore.rules
./scripts/deploy-staging.sh
```

## iOS status

iOS is deferred for this PR. The Phase 1 milestone is Android-first and will revisit iOS bundling and plists in a later PR.
