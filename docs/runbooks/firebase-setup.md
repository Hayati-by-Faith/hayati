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
deploys from the project aliases in `.firebaserc`.

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

## iOS status

iOS is deferred for this PR. The Phase 1 milestone is Android-first and will revisit iOS bundling and plists in a later PR.
