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

## Web setup

The web runtime uses the same Firebase projects. Dev web now uses the baked-in
`firebase_options_dev.dart` values, and `WebDebugProvider()` is used
automatically for local debug runs. For staging and prod web builds, pass the
web Firebase options via `--dart-define`:

```bash
flutter run -d chrome --dart-define=FLAVOR=dev
flutter build web --release --dart-define=FLAVOR=staging \
  --dart-define=FIREBASE_WEB_API_KEY_STAGING=<key> \
  --dart-define=FIREBASE_WEB_APP_ID_STAGING=<app-id> \
  --dart-define=FIREBASE_WEB_MEASUREMENT_ID_STAGING=<measurement-id> \
  --dart-define=FIREBASE_WEB_APPCHECK_SITE_KEY=<site-key>
```

Required web defines:

- `staging`: `FIREBASE_WEB_API_KEY_STAGING`, `FIREBASE_WEB_APP_ID_STAGING`, `FIREBASE_WEB_MEASUREMENT_ID_STAGING`
- `prod`: `FIREBASE_WEB_API_KEY_PROD`, `FIREBASE_WEB_APP_ID_PROD`, `FIREBASE_WEB_MEASUREMENT_ID_PROD`
- `web App Check`: `FIREBASE_WEB_APPCHECK_SITE_KEY_STAGING` / `..._PROD`
  when running the deploy scripts or any non-debug web release build

Preview channels are used for PRs, while staging and prod use live Hosting
deploys from the project aliases in `.firebaserc`. See the
"Hosting site setup" and "CI service account for Hosting" sections below for
one-time infrastructure setup.

## Hosting site setup

Hayati deploys web bundles to one Firebase Hosting site per environment.
These sites are global (their IDs are globally unique across all Firebase
projects) and must be created once by a human operator with access to the
Firebase project.

```bash
firebase hosting:sites:create hayati-dev --project hayati-dev-20260408
firebase hosting:sites:create hayati-staging --project hayati-staging-20260408
firebase hosting:sites:create hayati-prod --project hayati-prod-20260408
```

If any of these site IDs are already taken globally, fall back to the prefixed
naming convention:

```bash
firebase hosting:sites:create elhaya-hayati-dev --project hayati-dev-20260408
# …etc
```

After creation, apply targets so `firebase.json` can refer to each site by a
stable flavor alias:

```bash
firebase target:apply hosting dev hayati-dev -P dev
firebase target:apply hosting staging hayati-staging -P staging
firebase target:apply hosting prod hayati-prod -P prod
```

Targets are persisted to `.firebaserc` and committed to the repo. After this
step, `firebase deploy --only hosting -P staging` deploys to the correct site
automatically.

## CI service account for Hosting

The `build-web-preview` job in `.github/workflows/ci.yml` deploys PR preview
channels to the staging Hosting site. It authenticates with a dedicated
Google Cloud service account whose JSON key is stored as the
`FIREBASE_SERVICE_ACCOUNT_STAGING` GitHub Actions secret.

### One-time provisioning

```bash
gcloud iam service-accounts create gh-actions-hosting \
  --display-name="GitHub Actions Hosting Deploy" \
  --project=hayati-staging-20260408

gcloud projects add-iam-policy-binding hayati-staging-20260408 \
  --member="serviceAccount:gh-actions-hosting@hayati-staging-20260408.iam.gserviceaccount.com" \
  --role="roles/firebasehosting.admin"

gcloud projects add-iam-policy-binding hayati-staging-20260408 \
  --member="serviceAccount:gh-actions-hosting@hayati-staging-20260408.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageConsumer"

gcloud iam service-accounts keys create /tmp/gh-hosting-key.json \
  --iam-account=gh-actions-hosting@hayati-staging-20260408.iam.gserviceaccount.com
```

Copy the full JSON contents (not base64) and add them as the
`FIREBASE_SERVICE_ACCOUNT_STAGING` secret in
GitHub → Settings → Secrets and variables → Actions. The
`FirebaseExtended/action-hosting-deploy@v0` action accepts raw JSON.

Immediately after:

```bash
rm /tmp/gh-hosting-key.json
```

### Rotation policy

- Rotate the key every **90 days**.
- When rotating, create the new key first, update the GitHub secret, confirm
  the next CI run succeeds, then delete the old key:
  ```bash
  gcloud iam service-accounts keys list \
    --iam-account=gh-actions-hosting@hayati-staging-20260408.iam.gserviceaccount.com
  gcloud iam service-accounts keys delete <OLD_KEY_ID> \
    --iam-account=gh-actions-hosting@hayati-staging-20260408.iam.gserviceaccount.com
  ```
- The service account has only `firebasehosting.admin` +
  `serviceusage.serviceUsageConsumer` scopes. If those scopes expand, update
  this runbook and open an advisory PR.

### Fork-PR safety

The `build-web-preview` job is guarded by
`github.event.pull_request.head.repo.full_name == github.repository` so PRs
opened from forks do not get the staging secret. Trusted forks can still be
deployed by maintainers re-pushing to an internal branch.

## Preview channels vs. live hosting deploys

Hayati uses two distinct Hosting flows:

| Flow | Trigger | Target | Expires | Purpose |
|------|---------|--------|---------|---------|
| **Preview** | PR opened from internal branch | `hayati-staging` preview channel `pr-<N>` | 7 days | Per-PR QA + reviewer sharing |
| **Live staging** | `./scripts/deploy-staging.sh` on `main` | `hayati-staging` live channel | — | Integration staging env |
| **Live prod** | `./scripts/deploy-prod.sh --i-really-mean-it` on `main` | `hayati-prod` live channel | — | Production release |

Preview channels never replace the live staging channel — they are isolated
URLs (`https://hayati-staging--pr-123-<hash>.web.app`) that auto-expire.

### Hosting target resolution

`firebase.json` now uses target-keyed hosting configs (`dev`, `staging`,
`prod`), and `.firebaserc` maps each target to its Hosting site. The deploy
scripts use `--only hosting:<target>` so each environment pushes only to its
own site.

If the site IDs in `.firebaserc` don't match what was created in the Firebase
Console (see "Hosting site setup"), update `.firebaserc` accordingly — for
example, if the global ID `hayati-prod` was taken and `elhaya-hayati-prod`
was used instead:

```json
"hayati-prod-20260408": {
  "hosting": {
    "prod": ["elhaya-hayati-prod"]
  }
}
```

### Rollback: live hosting

Hosting deploys are snapshotted per release. Two rollback paths:

1. **Firebase Console** → Hosting → pick the previous version → **Rollback**.
2. **CLI** (preferred for reproducibility): clone a known-good version onto
   the live channel.
   ```bash
   firebase hosting:clone hayati-prod:<GOOD_VERSION_ID> hayati-prod:live
   ```
   Each deploy logs its version ID to CI output; tag it locally with
   `git tag -a web-prod-<ts>-VERSION-<id> -m "..."` if long-term retention is
   needed.

### Rollback: Firestore rules

Every deploy script creates a `firestore-rules-<env>-<timestamp>` git tag
before (or during) deploy. To roll back:

```bash
git checkout <firestore-rules-prod-YYYYMMDD-HHMMSSZ> -- firestore.rules
./scripts/deploy-prod.sh --i-really-mean-it
```

### Rollback: Cloud Functions

Cloud Functions have no built-in rollback. Check out the previous commit and
redeploy:

```bash
git checkout <previous-commit> -- functions/
./scripts/deploy-staging.sh
```

Crashed functions can also be disabled via
`gcloud functions deploy <name> --no-allow-unauthenticated` to quickly stop
traffic while preparing a fix.

### Local web development — Phone OTP on `127.0.0.1`

Firebase Auth silently rejects phone verification from `localhost` on web
(returns `auth/invalid-app-credential` with a misleading "reCAPTCHA token
response is either invalid or expired" message). Until Firebase relaxes this,
**all local web development of the OTP flow must run on `127.0.0.1`**, not
`localhost`.

Required one-time Firebase Console setup per environment (dev / staging / prod):

1. Firebase Console → **Authentication → Settings → Authorized domains** →
   add `127.0.0.1` (exact string, no protocol, no port). `localhost` stays
   there as well; it is used by emulators.
2. Firebase Console → **App Check → Manage debug tokens** for the web app →
   add the debug token printed to the Chrome console on first run
   (look for `App Check debug token: <uuid>`). Each developer machine has its
   own token, stored in the browser's IndexedDB; re-adding is only needed if
   the browser profile is wiped.

Run the dev web app pinned to `127.0.0.1:5000`:

```bash
flutter run -d chrome \
  --web-hostname 127.0.0.1 --web-port 5000 \
  --dart-define=FLAVOR=dev
```

The checked-in `.vscode/launch.json` has a "Hayati Web (dev, 127.0.0.1)"
configuration that enforces the same hostname, port, and flavor.

#### Troubleshooting phone OTP on web

| Symptom | Likely cause | Fix |
|---|---|---|
| `auth/invalid-app-credential` — "reCAPTCHA token response is either invalid or expired" | App is served from `localhost` | Relaunch on `127.0.0.1:5000` per above |
| `auth/captcha-check-failed` — "Hostname match not found" | `127.0.0.1` not in Authentication → Authorized domains | Add it in the console; hard-refresh Chrome; hot restart |
| "Send code" button does nothing, no network call | Form validation silently failing on the empty SMS code field | Ensure each `TextFormField` uses its own `GlobalKey<FormFieldState>` and `_sendCode` only validates the phone field (see `phone_otp_screen.dart`) |
| App Check errors after wiping browser profile | Debug token changed | Copy the new token from the Chrome console and add it under App Check → Manage debug tokens |

For real numbers, the phone OTP flow always requires reCAPTCHA on web — there
is no bypass. For test numbers that skip SMS and reCAPTCHA, see
**Authentication → Settings → Phone numbers for testing**; those still work on
`127.0.0.1` but also on emulators.

## Android App Check (Phase 1)

Phase 1 ships Android first. Before turning on App Check enforcement in the
console for any Android flavor:

1. Collect the SHA-256 fingerprints for every signing config:
   ```bash
   cd android && ./gradlew signingReport
   ```
   Record the `SHA-256` lines for the `debug`, `releaseUpload`, and
   `release` variants across all three flavors.
2. Firebase Console → **Project settings → Your apps → Android app →
   Add fingerprint** and paste each SHA-256. Do this for dev, staging, and
   prod Android app registrations.
3. Firebase Console → **App Check → Apps → Android → Play Integrity** and
   link the app. Keep **"Enforcement"** in *Unenforced* mode until the
   attestation traffic shows healthy in the metrics tab (typically 24–48h).
4. For local debug builds, copy the `App Check debug token` printed in
   `adb logcat` and add it under **App Check → Manage debug tokens**. One
   token per developer device/emulator.

Do not enable enforcement on production until the dev and staging rollouts
have been running green for a week.

## iOS App Check (deferred)

iOS is intentionally deferred for Phase 1. When it lands:

1. Enable the **App Attest** capability in Xcode for every scheme (dev,
   staging, prod).
2. Register the iOS app bundle IDs in Firebase and generate the
   `GoogleService-Info.plist` files (one per flavor).
3. Firebase Console → **App Check → Apps → iOS → App Attest** and link the
   app, leaving enforcement *Unenforced* for the first week.
4. For simulator runs, grab the debug token from Xcode's console output and
   register it under App Check → Manage debug tokens. Simulators cannot use
   App Attest directly.

## Rollback

Tag `firestore.rules` before every deploy so rollback is simple and auditable.

```bash
git checkout <tag> -- firestore.rules
./scripts/deploy-staging.sh
```

## Web verification log (W8)

Run this checklist before every staging → prod promotion. Record results in
the table below; one row per verification run. Use Chrome (desktop) and Safari
on iPad for the cross-browser items.

### Automated gates (must pass in CI)

- [ ] `flutter analyze --fatal-warnings --fatal-infos`
- [ ] `flutter test --coverage`
- [ ] `cd rules-tests && npm test`
- [ ] `cd functions && npm test`
- [ ] `flutter build web --release --dart-define=FLAVOR=dev`
- [ ] ARB ar↔en parity (`.github/workflows/ci.yml` step)
- [ ] ARB ↔ `localization.dart` map parity (`scripts/check_l10n_parity.py`)

### Manual smoke — Chrome desktop (1440×900)

- [ ] Phone OTP round trip on `127.0.0.1:5000` (reCAPTCHA visible, code
      delivers, verification lands on `/consent`).
- [ ] Village picker loads with offline cache (reload browser while offline,
      list still renders).
- [ ] Resident / staff / super_admin home screens render RTL without
      horizontal overflow at 360×640, 768×1024, 1440×900 (Chrome DevTools
      responsive mode).
- [ ] Text scale 1.0, 1.5, 2.0 — no overflow, no clipped buttons, no broken
      layouts.
- [ ] QR display renders the signed token; share + save-to-gallery both work.
- [ ] QR scanner shows a graceful fallback when camera permission is denied.
- [ ] Consent screen submits (writes `households/{uid}/consents/{auto}`) and
      navigates to `/enrollment`.
- [ ] Enrollment form submits to `enrollment.createHousehold`; success screen
      displays QR.
- [ ] **GPS allowed**: household doc has valid `gps` (geopoint) and
      `geohash` (non-empty string); audit entry has `gpsProvided: true`.
- [ ] **GPS denied**: skip dialog appears (Arabic + English); user can
      proceed; household has `gps: null` and `geohash: null`; audit entry
      has `gpsProvided: false`.
- [ ] `/services`, `/profile`, `/blog`, `/community-watch`, `/training`
      routes each render the `PhasePlaceholderScreen` (locked state).
- [ ] 404 fallback: navigate to `/bogus-route` → "not found" screen renders
      Arabic title and body from ARB.

### Manual smoke — Safari iPad (portrait + landscape)

- [ ] Phone OTP round trip on `127.0.0.1:5000`.
- [ ] Resident home renders responsive two-column layout in landscape
      (>1024 px) and single-column in portrait.
- [ ] No `position: fixed` or service-worker lifecycle regressions.
- [ ] IndexedDB persistence survives one tab reload.

### Verification log

| Run | Tester | Date | Browser | Build (flavor/commit) | Result | Notes |
|-----|--------|------|---------|------------------------|--------|-------|
| _1_ | _(initials)_ | _(YYYY-MM-DD)_ | Chrome desktop | _dev / `<sha>`_ | — | _First log; fill on first run._ |
| _2_ | _(initials)_ | _(YYYY-MM-DD)_ | Safari iPad | _dev / `<sha>`_ | — | _Paired with run 1._ |

Add one row per run. Keep the header and first two placeholder rows when
archiving old entries; do not delete historic rows until after the
corresponding Firebase Hosting version has been replaced twice over.

## iOS status

iOS is deferred for this PR. The Phase 1 milestone is Android-first and will revisit iOS bundling and plists in a later PR.
