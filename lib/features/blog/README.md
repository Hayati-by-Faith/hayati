# Blog (Phase 4)

Phase 4 — not implemented yet (see `hayati-architecture.md` §3).

This directory is a placeholder for the village blog / posts feature
(`posts` collection, authoring per role, moderation queue).

Routes registered in `lib/routing/app_router.dart` under `/blog` currently
render `PhasePlaceholderScreen` regardless of `phaseConfig.phase_4_blog`.

Implementation is gated on `phaseConfig.phase_4_blog == true` for the active
village.
