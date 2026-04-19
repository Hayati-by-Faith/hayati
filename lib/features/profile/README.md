# Profile (Phase 3)

Phase 3 — not implemented yet (see `hayati-architecture.md` §3).

This directory is a placeholder for the progressive profile feature, which
extends resident records with health, education, and family detail fields
behind consent gates.

Routes registered in `lib/routing/app_router.dart` under `/profile` currently
render `PhasePlaceholderScreen` regardless of `phaseConfig.phase_3_profile`.

Implementation is gated on `phaseConfig.phase_3_profile == true` for the active
village, plus a human-reviewed privacy scope review.
