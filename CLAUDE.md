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

## Localization

- Keep `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` synchronized.
- Add keys only for the current phase unless a future phase needs a shared shell string.
- Update the `context.l(...)` mapping when a new key is added.

## Trigger Safety

- Never add client-side custom-claim writes.
- Never use `allow: if true` in Firestore rules.
- Default deny is the baseline for rules and UI routing.

## Responsive UI

- Design for mobile first.
- Respect text scale up to 2.0.
- Use 48dp minimum touch targets.
- Keep RTL and LTR both legible, but default to Arabic.

## Phase Discipline

- Phase 1 only in the scaffold implementation.
- Phase 2 through Phase 6 should exist only as stub directories.
- Do not implement future-phase logic until the architecture explicitly requires it.
