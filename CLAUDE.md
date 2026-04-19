# Hayati Conventions

This file distills the operational conventions from `hayati-architecture.md` for day-to-day implementation.

## Canonical Vocabulary

- Use `village`, `household`, `resident`, `service`, `post`, and `report`.
- Do not use `tenant`, `customer`, `user profile`, `janitor`, or `facility`.

## Roles

Only these role names are valid:

- `resident`
- `field_worker`
- `health_worker`
- `data_collector`
- `service_provider`
- `admin`
- `super_admin`

## App Behavior

- Arabic-first UI with RTL by default.
- Offline-first reads and optimistic writes.
- No raw `print()` calls; use `AppLogger`.
- Every visible string must come from `context.l('key')`.
- Keep constrained text widgets bounded with `maxLines` and `TextOverflow.ellipsis`.
- Use `mainAxisSize: MainAxisSize.min` inside cards or constrained columns.

## Error Handling & PII

- In async callbacks, always `if (!mounted) return;` before `setState(...)` or `ScaffoldMessenger.of(context)` calls.
- Never surface raw exception messages or stack traces in the UI. User-facing errors go through `context.l('key')`.
- Never display raw Firebase UIDs. Resolve names on screen load and display from cache. Fallback chain: `name` → `displayName` → `phoneNumber` → `context.l('unknownUser')`. Do not fall back to the UID.

## Services & Lifecycle

- Every service with timers, streams, or listeners (`crashlytics_service`, `performance_service`, `app_check_service`, etc.) must:
  - Use an `_isInitialized` (or `_is<Action>`) guard flag to prevent double-init.
  - Cancel-before-reassign for any `Timer` or `StreamSubscription`.
  - Expose an `emergencyCleanup()` (or equivalent `dispose`) that resets the guard and releases resources.
- Keep web and IO split files (`*_web.dart`, `*_io.dart`) behind the same public surface; no conditional imports leaking into callers.

## Constants & Magic Numbers

- No ad-hoc `Duration` literals, magic numbers, currency codes, or hardcoded collection/field names in feature code.
- Constants live under `lib/core/` (most-specific existing file first; create a new one only if none fits). Extract on first use — do not defer to a cleanup pass.

## Localization

- Keep `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` synchronized.
- Add keys only for the current phase unless a future phase needs a shared shell string.
- Update the `context.l(...)` mapping when a new key is added.

## Trigger Safety

- Never add client-side custom-claim writes.
- Never use `allow: if true` in Firestore rules.
- Default deny is the baseline for rules and UI routing.
- Any Cloud Function trigger that writes back to its own collection must guard against re-entry (idempotency key, change-sentinel field, or explicit "skip if source field unchanged"). Trigger loops are cost-critical.

## Firestore Rules Change Policy

- Every change to `firestore.rules` or `storage.rules` must ship with matching updates in `rules-tests/` in the same commit.
- Each new ALLOW branch needs a passing case; each new DENY branch needs a failing case (including the pre-fix state when fixing a bug).
- For `list` queries, include both an ALLOW with the required filter and a DENY without it (prevents enumeration).
- No "add tests in a follow-up." The CI `rules` job must be green on the commit that touches rules.

## Responsive UI

- Design for mobile first.
- Respect text scale up to 2.0.
- Use 48dp minimum touch targets.
- Keep RTL and LTR both legible, but default to Arabic.

## Phase Discipline

- Phase 1 only in the scaffold implementation.
- Phase 2 through Phase 6 should exist only as stub directories.
- Do not implement future-phase logic until the architecture explicitly requires it.

## Git Workflow

- Always `git pull` before starting work.
- Stage specific files only (`git add <files>`). Never `git add -A`, `git add .`, or `git add --all`.
- Conventional commit prefixes required: `feat|fix|refactor|docs|chore|test|perf|ci`.
- Never force-push to `main` or any shared branch.
- Never revert a merge commit — resolve conflicts file by file.
- When discarding local changes, prefer `git stash push -u -m "<reason>"` over `git reset --hard`, `git checkout .`, `git restore .`, or `git clean -fd`.
- If another agent may be active on the same repo, work on a dedicated branch (`agent/<task>`). Do not edit `main` directly while parallel agents are running.

## Deployment

- Never deploy to prod without human review.
- Always run `rules-tests` before deploy.
- Always tag `firestore.rules` before deploy for rollback.
- Use the Firebase setup runbook at `docs/runbooks/firebase-setup.md`.

## CI

- CI is a single workflow: `.github/workflows/ci.yml`. Do not reintroduce `pr.yml` or other parallel workflows; add jobs to `ci.yml` instead.
- The Flutter SDK version is pinned via the `FLUTTER_VERSION` env var at the top of `ci.yml`. Bump it deliberately when upgrading; do not use `channel: stable` alone.
- Every PR must pass, in order: `dart format --set-exit-if-changed`, `flutter analyze --fatal-warnings --fatal-infos`, ARB key parity between `app_ar.arb` and `app_en.arb`, `flutter test --coverage`, APK dev-debug build, and web dev-release build.
- Coverage is uploaded as the `flutter-coverage` artifact but not gated. Do not add a coverage threshold without first committing an excludes list for generated files (`*.g.dart`, `*.freezed.dart`, `firebase_options_*.dart`, `main_*.dart`, `l10n/`).
- `rules-tests` and `functions` jobs must stay green on every PR. Do not skip them to unblock a merge.
- Concurrency is scoped to `ci-${{ github.ref }}` with `cancel-in-progress: true`; do not remove this.
- Fix CI by fixing the code, not by loosening the gates. Any gate relaxation (e.g. dropping `--fatal-infos`) requires human review.

## Plans & Contracts

- Any file under `plans/*.md` with "Locked decisions", "Phased implementation", or numbered notes is a contract while active.
- When an item is shipped, mark it in the plan with a `file:line` reference. When deferred, mark it `[DEFERRED: reason + owner + phase]`. Unmarked items are unshipped.
- Before closing or reverting a plan item, diff the current code against the plan first. Partial restores are the biggest source of plan drift.

## Flutter Test Cache Note

- If `flutter test` fails with an intermittent compile error, rerun once before investigating. Only dig in if the error reproduces on an immediate rerun.

## Response Style (Agents)

- Be concise. No preamble, no recap of the user's question, no closing summary.
- Answer the question asked — nothing extra. The user will ask for more if wanted.
- Prefer tables, bullets, and short sentences over paragraphs.
- Show plans as short numbered lists. Skip filler words ("great", "certainly", "let me…").
- Cite file refs with path and line (e.g. `lib/features/qr/screens/my_qr_screen.dart:42`). No emoji unless the user asks.
