# Training (Phase 6)

Phase 6 — not implemented yet (see `hayati-architecture.md` §3).

This directory is a placeholder for the training modules feature
(training catalogue, lesson progress tracking, completion certificates).

Routes registered in `lib/routing/app_router.dart` under `/training` currently
render `PhasePlaceholderScreen` regardless of `phaseConfig.phase_6_training`.

Implementation is gated on `phaseConfig.phase_6_training == true` for the
active village.
