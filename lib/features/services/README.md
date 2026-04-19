# Services (Phase 2)

Phase 2 — not implemented yet (see `hayati-architecture.md` §3).

This directory is a placeholder for the services board feature, which includes
the `serviceRegistration` callable, transactional capacity tracking, the
services board UI per role, and FCM topic wiring.

Routes registered in `lib/routing/app_router.dart` under `/services` currently
render `PhasePlaceholderScreen` regardless of `phaseConfig.phase_2_services`.

Implementation is gated on:

- `phaseConfig.phase_2_services == true` for the active village.
- Human-reviewed design sign-off for the services board UI.

See `plans/phase-2-services.md` for the full rollout plan.
