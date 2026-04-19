# Plan: Add Flutter Web Support to Hayati

Status: proposed (revised after Codex review)
Owner: (assign)
Last updated: 2026-04-18
Revision: 3 — applied Codex findings on Performance Monitoring, QR export,
App Check provider naming, and hosting deploy flow.

## Goal

Run Hayati in Chrome for development and UI review, with a minimum-viable path
to a production-capable PWA. Maintain Arabic-first RTL, offline-first reads,
and Phase 1 discipline defined in `hayati-architecture.md` and `CLAUDE.md`.

## Non-goals (this plan)

- Replacing mobile as the primary runtime.
- Web equivalents for on-device ML (face detection).
- Background messaging parity with Android/iOS.

## Current state (verified 2026-04-18)

- No `web/` directory exists.
- `lib/firebase_options_{dev,staging,prod}.dart` all throw `UnsupportedError`
  when `kIsWeb` is true.
- `google_mlkit_face_detection` is in `pubspec.yaml` but is not imported by any
  Dart source; safe to gate or remove for the web build.
- `mobile_scanner` is imported only in
  `lib/features/qr/screens/qr_scanner_screen.dart`.
- Firebase packages (`core`, `auth`, `firestore`, `storage`, `messaging`,
  `remote_config`, `app_check`, `analytics`, `performance`, `functions`) all
  support web. `firebase_crashlytics` does NOT support web and must be gated.
  `firebase_performance` DOES support web via `firebase_performance_web`; do
  not gate it off.
- Flavor entry points: `main_dev.dart`, `main_staging.dart`, `main_prod.dart`
  via `lib/main.dart` switch on `FLAVOR`. Each must call
  `usePathUrlStrategy()` from `package:flutter_web_plugins/url_strategy.dart`
  before `bootstrap` on web.
- `lib/core/services/app_check_service.dart` currently activates with
  `AndroidPlayIntegrityProvider` / `AppleAppAttestProvider` (not DeviceCheck).
  Web support needs the `webProvider:` named argument.
- `lib/features/qr/screens/my_qr_screen.dart` imports `dart:io`, uses
  `File`, and calls `path_provider`'s `getTemporaryDirectory()`. This will
  fail to compile on web and needs an explicit refactor.

## Phases

### Phase W0 - Feasibility gate (0.5 day)

- [ ] Confirm target browsers: Chrome + Safari (iPad) + Edge.
- [ ] Decide whether web is Phase 1 scope or a parallel dev-only lane.
- [ ] Tag decision in `hayati-architecture.md` under a new "Web runtime"
      section.

### Phase W1 - Scaffold web platform (0.5 day)

- [ ] Run `flutter create . --platforms=web` from repo root.
- [ ] Commit the generated `web/` folder untouched first, then customize:
  - [ ] `web/index.html`: set `<html lang="ar" dir="rtl">`, set title to
    "حياتي", preconnect Firebase, Tajawal font, theme color.
  - [ ] `web/manifest.json`: Arabic `name`, `short_name`, `description`,
    orientation `any`, display `standalone`, icons 192 and 512.
  - [ ] Replace `favicon.png` and `icons/Icon-*.png` with Hayati branding.
- [ ] Add `web/` to analyzer excludes only if generated files produce warnings.

### Phase W2a - Firebase init, auth, and App Check on web (0.75 day)

- [ ] Run `flutterfire configure` three times (one per flavor) to regenerate
      `firebase_options_{dev,staging,prod}.dart` with a web app entry.
      Use separate Firebase web apps per flavor.
- [ ] Register authorized domains per flavor in Firebase Auth (localhost,
      staging host, prod host).
- [ ] Configure App Check for web with reCAPTCHA v3 site keys per flavor.
      Store keys in env-specific config or `--dart-define`, not committed
      secrets (site key itself is public, but keep it out of hardcoded
      source for cleanliness).
  - [ ] Update `lib/core/services/app_check_service.dart` to pass a
        `webProvider:` argument to `FirebaseAppCheck.instance.activate(...)`:
        `ReCaptchaV3Provider('<site-key>')` in staging/prod and
        `WebDebugProvider()` for dev/local web runs.
  - [ ] Keep the existing mobile providers as they are:
        `AndroidPlayIntegrityProvider` on Android and
        `AppleAppAttestProvider` on Apple (not DeviceCheck).
- [ ] Gate `firebase_crashlytics` behind `!kIsWeb` in
      `lib/core/services/crashlytics_service.dart` and `lib/bootstrap.dart`.
      Route crash reporting on web through `AppLogger` only.
- [ ] Verify Firestore persistence: opt into IndexedDB cache for web in
      `firebase_service.dart`, keep SQLite-style settings on mobile.

### Phase W2b - Web observability (0.5 day)

- [ ] Keep `firebase_performance` enabled on web. Add a web-specific init in
      `bootstrap.dart` (or a dedicated `performance_service.dart`) that
      enables `FirebasePerformance.instance.setPerformanceCollectionEnabled`
      on all platforms including web.
- [ ] Enable `firebase_analytics` on web; verify the measurement ID is
      present in the regenerated `firebase_options_*.dart`.
- [ ] Add a smoke HTTP trace and a screen-render custom trace so at least
      one data point reaches the Performance dashboard per flavor.
- [ ] Document that Crashlytics is mobile-only; errors on web surface only
      via `AppLogger` and analytics error events.

### Phase W3 - Plugin compatibility gating (1.5 day)

For each plugin, confirm web support and add a `kIsWeb` guard or
platform-specific abstraction. No new code paths outside Phase 1 scope.

| Plugin | Web support | Action |
|---|---|---|
| `firebase_*` (listed above) | Yes, except `firebase_crashlytics` | Gate Crashlytics only; keep Performance, Analytics, Messaging, Remote Config, App Check, Functions, Auth, Firestore, Storage |
| `cloud_functions` | Yes | Verify CORS on callable endpoints |
| `firebase_messaging` | Yes with service worker | Add `web/firebase-messaging-sw.js`; VAPID key per flavor |
| `qr_flutter` | Yes | None |
| `mobile_scanner` | Partial (Chrome only, HTTPS or localhost) | Gate `qr_scanner_screen.dart`; show fallback on unsupported browsers |
| `geolocator` | Yes (HTTPS + permission prompt) | Test permission flow |
| `geocoding` | No | Abstract behind interface; use a callable or disable on web |
| `google_mlkit_face_detection` | No | Remove from `pubspec.yaml` until a feature needs it, OR isolate behind a platform interface with a web stub |
| `image_picker` | Yes | None |
| `video_player` | Yes | Verify codecs |
| `audioplayers` | Yes | Handle autoplay policies (must be user gesture) |
| `cached_network_image` | Yes | None |
| `share_plus` | Yes (accepts in-memory `XFile.fromData`) | None |
| `path_provider` | Limited | Replace disk writes on web with in-memory bytes; use IndexedDB only if persistence is required |
| `device_info_plus` | Yes | None |
| `cross_file` | Yes | None |
| `flutter_markdown` | Yes | None |
| `dart_geohash` | Pure Dart | None |

### Phase W3a - QR export refactor (explicit task, part of W3)

`lib/features/qr/screens/my_qr_screen.dart` is the only known Dart file that
imports `dart:io` and uses `File` + `path_provider`. It must be refactored
before the web build compiles.

- [ ] Remove `import 'dart:io'` and `import 'package:path_provider/...`
      from `my_qr_screen.dart`.
- [ ] Change `_captureQr()` to return `Uint8List` instead of `File`.
- [ ] Update `_shareQr()` to call
      `SharePlus.instance.share(ShareParams(files: [XFile.fromData(bytes, name: 'hayati-qr.png', mimeType: 'image/png')]))`.
- [ ] Implement `_saveQr()` with platform-specific behavior:
  - On web: trigger a browser download via `package:web`
    (`HTMLAnchorElement` + `Blob` URL) or a thin `universal_html` wrapper.
  - On mobile: either keep a native save path (requires an Android/iOS
    save plugin) or reuse `SharePlus` as the save mechanism.
- [ ] Verify QR semantics, RTL, and Tajawal font still apply on web.
- [ ] Add a widget test that renders `MyQrScreen` and asserts the capture
      path produces non-empty bytes.

### Phase W4 - Routing, RTL, and responsive shell (0.75 day)

Most of this phase is verification: `MaterialApp.router`, `go_router`, RTL
`Directionality`, and Tajawal are already wired in `lib/app.dart`,
`lib/routing/app_router.dart`, and `lib/core/theme/app_theme.dart`.

- [ ] Call `usePathUrlStrategy()` from
      `package:flutter_web_plugins/url_strategy.dart` in each of
      `main_dev.dart`, `main_staging.dart`, and `main_prod.dart` before
      `bootstrap`. Guard with `if (kIsWeb)` so mobile is untouched.
- [ ] Add a 404 / not-found route in `app_router.dart` for unknown deep
      links that web users can paste into the URL bar.
- [ ] Confirm `Directionality` resolves to `rtl` on web (already forced in
      `app.dart`'s `builder`).
- [ ] Add web breakpoints in `lib/core/theme/app_theme.dart` or a new
      `lib/core/theme/responsive.dart`: phone (<600), tablet (600-1024),
      desktop (>1024). Keep 48dp minimum touch targets.
- [ ] Review constrained widgets: retain `maxLines`, `TextOverflow.ellipsis`,
      and `mainAxisSize: MainAxisSize.min` per `CLAUDE.md`.

### Phase W5 - Security hardening (0.5 day)

- [ ] Confirm `firestore.rules` default-deny still passes `rules-tests` after
      any new web-specific subcollections (none expected in Phase 1).
- [ ] No client-side custom-claim writes introduced.
- [ ] CSP header for hosted web: strict `default-src`, explicit allow-list for
      Firebase, reCAPTCHA, Tajawal font host.
- [ ] Ensure no secrets land in `web/` (App Check reCAPTCHA site key is
      public; Firebase API keys are restricted by console referrer rules).

### Phase W6a - CI build and PR preview channels (0.75 day)

- [ ] Add a web build job to `.github/workflows/pr.yml`:
      `flutter build web --release --dart-define=FLAVOR=dev`.
- [ ] Decide hosting: Firebase Hosting recommended, one site per flavor.
      Configure hosting targets in `.firebaserc` so each flavor maps to its
      own site id.
- [ ] Add `firebase.dev.json`, `firebase.staging.json`, and `firebase.json`
      hosting sections with SPA rewrites to `/index.html`.
- [ ] For PRs, deploy ephemeral previews with
      `firebase hosting:channel:deploy pr-<id> --expires 7d -P staging`.
      This is a preview channel only; it does NOT update the live site.
- [ ] Post the preview URL back to the PR via the Firebase Hosting GitHub
      action or a follow-up `gh pr comment` step.

### Phase W6b - Live hosting deploys for staging and prod (0.75 day)

- [ ] Update `scripts/deploy-staging.sh` to add a hosting step AFTER the
      existing rules/indexes/functions deploy:
      `firebase deploy --only hosting:staging -P staging`.
      This is a live deploy to the durable staging site, not a preview
      channel.
- [ ] Update `scripts/deploy-prod.sh` similarly with
      `firebase deploy --only hosting:prod -P prod`, gated on the same
      `rules-tests` + tag + human review requirements from `CLAUDE.md`.
- [ ] Always tag `firestore.rules` AND the web bundle commit before prod
      deploy for rollback symmetry.
- [ ] Document both flows (preview vs live) in
      `docs/runbooks/firebase-setup.md`, including how to roll back a
      hosting release with `firebase hosting:clone` or the Hosting
      console's previous version.

### Phase W7 - Localization and strings (0.5 day)

- [ ] Audit `lib/l10n/app_ar.arb` and `app_en.arb` for any web-only strings
      (for example "Install app", "Use supported browser"). Add keys only if
      needed this phase.
- [ ] Update the `context.l(...)` mapping for any new keys.

### Phase W8 - Verification (1 day)

- [ ] `flutter analyze` clean.
- [ ] `flutter test` clean (existing tests stay mobile-oriented; no new golden
      tests for web this phase).
- [ ] Manual smoke on Chrome + Safari iPad:
  - [ ] Phone OTP sign-in round trip (reCAPTCHA visible).
  - [ ] Village picker loads with offline cache (reload while offline).
  - [ ] Resident home, staff home, super admin home render RTL without
        overflow at 360x640, 768x1024, 1440x900.
  - [ ] Text scale 1.0, 1.5, 2.0.
  - [ ] QR display works; QR scan shows a graceful fallback if camera
        permission is denied.
- [ ] Record results in the web section of
      `docs/runbooks/firebase-setup.md`.

## Rollback

- Revert the `web/` folder and Firebase options regeneration commits.
- Remove web hosting targets from `firebase*.json` and hosting targets from
  `.firebaserc`.
- Remove the web job from `.github/workflows/pr.yml`.
- Roll back a shipped web release via `firebase hosting:clone <SOURCE_SITE>:<VERSION> <TARGET_SITE>:live`
  or the Hosting console's "Rollback" action on the previous version.
- No schema changes, so no data rollback required.

## Risks

- reCAPTCHA friction on low-bandwidth Egyptian networks. Measure before
  promoting past staging.
- IndexedDB quotas differ from SQLite; large sync queues may evict.
- Safari iOS PWA push requires iOS 16.4+ and Add-to-Home-Screen.
- `mobile_scanner` behaves inconsistently across browsers. Treat as best
  effort on web.

## Open questions

- Is web intended for residents (public) or staff (internal) in Phase 1?
- Do we need PWA install and offline shell now, or only dev preview?
- Which domains are authorized for staging and prod?

## Exit criteria

- `flutter run -d chrome --dart-define=FLAVOR=dev` boots to the phone OTP
  screen with RTL and Tajawal applied.
- Dev flavor deployed to a Firebase Hosting preview channel.
- Staging flavor deployed to the live staging hosting site via
  `scripts/deploy-staging.sh`.
- PR checklist in `pr.yml` builds web without errors.
- `firebase_performance` reports at least one trace from the web build.
- `my_qr_screen.dart` no longer imports `dart:io`.
- Human review sign-off per `CLAUDE.md` deployment rule.

## Effort estimate

Revised estimate: 7 to 9 developer-days for a Phase-1-compatible web lane.
Increases vs the initial 5.5-6 day estimate come from:

- Explicit QR export refactor (Phase W3a): ~0.5 day.
- Safari iPad + FCM web service worker per flavor: ~0.5 to 1 day.
- Splitting hosting into preview vs live flows across three flavors and
  two deploy scripts: ~0.5 day.
- Web observability wiring and smoke traces (Phase W2b): ~0.5 day.

Excludes visual design polish and any Phase 2-6 features.
