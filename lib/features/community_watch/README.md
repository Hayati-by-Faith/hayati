# Community Watch (Phase 5)

Phase 5 — not implemented yet (see `hayati-architecture.md` §3).

This directory is a placeholder for the community watch / reports feature
(`reports` collection, incident intake, triage queues for staff).

Routes registered in `lib/routing/app_router.dart` under `/community-watch`
currently render `PhasePlaceholderScreen` regardless of
`phaseConfig.phase_5_community_watch`.

Implementation is gated on `phaseConfig.phase_5_community_watch == true` for
the active village.
