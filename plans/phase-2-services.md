# Plan: Phase 2 — Service Access

Status: proposed (planning only — implementation deferred)
Owner: (assign)
Last updated: 2026-04-19
Revision: 1
Cross-reference: `plans/phase-1-closeout.md` Workstream 8

## Implementation gate

**Do not begin implementation until ALL of the following are true:**

1. A super_admin has flipped `phaseConfig.phase_2_services` for at least one village (e.g. Abusir).
2. A human-reviewed design sign-off exists for the services board UI.
3. Phase 1 closeout (Workstream 1 in `plans/phase-1-closeout.md`) is complete and merged to `main`.
4. All Phase 1 rules-tests and function tests are green.

## Goal

Enable village residents to view, register for, and attend foundation services (training, employment, giveaways, medical, agricultural, legal, children). Staff can create services, scan QR codes to confirm attendance, and view participation data. FCM push notifications alert residents to new services.

## Non-goals

- Phase 3 sensitive data collection (medical, children, etc.).
- Blog authoring (Phase 4).
- Payment handling (Phase 5 garbage fees).
- Training modules with video/quiz (Phase 6).
- Overbooking waitlists — Phase 2 simply rejects at capacity.

## Architecture reference

- `hayati-architecture.md` §3 Phase 2, §5.6 (services schema), §5.7 (participations schema), §2.3 (permission matrix).
- `CLAUDE.md` — canonical vocabulary, roles, trigger safety, phase discipline.

---

## 1. Services Board UI

### Screen: `lib/features/services/screens/services_list_screen.dart`

- **Resident view**: list of active services for the current village, filtered by `isActive: true` and `villageId == activeVillageId`. Each card shows: title, type icon, date, location name, capacity remaining. Tap → service detail → register button.
- **Staff view** (field_worker, health_worker, admin, super_admin): same list + a FAB to create a new service (admin/super_admin only). Tap → service detail with attendance scanner and participant list.
- **service_provider view**: filtered to services where `assignedServiceProviderUid == uid`. Can mark attendance for their own services only.
- Offline-first: services list cached in Firestore persistence. Show cached data immediately, refresh on connectivity.
- Arabic-first, RTL, 48dp touch targets, `maxLines` + `TextOverflow.ellipsis` on card titles.
- Responsive: single column on phone, two-column grid on tablet+ (per `lib/core/theme/responsive.dart` from WS3).

### Screen: `lib/features/services/screens/service_detail_screen.dart`

- Title, description, date, location (with map link), capacity, registered count, type.
- Resident: "Register" button (calls `serviceRegistration` callable). Disabled if already registered or at capacity.
- Staff: "Scan QR" button → opens QR scanner → calls `attendanceConfirm` callable. Participant list with status badges.

### Screen: `lib/features/services/screens/service_create_screen.dart`

- Admin/super_admin only. Form: title, description, type (dropdown), date, location, capacity, requirements (optional).
- Writes to `services/{auto}` via Firestore (direct write, not callable — per existing rules allowing admin/super_admin).

### Phase gate

- All services routes wrapped in `PhaseGate(featureFlag: 'phase_2_services')`.
- If flag is off, render `PhasePlaceholderScreen` (from WS2).

---

## 2. `serviceRegistration` callable

**Location**: `functions/src/serviceRegistration.js`

### Input

```json
{
  "serviceId": "string",
  "villageId": "string"
}
```

### Logic

1. `requireAuth(request)` — must be authenticated.
2. Validate `serviceId` and `villageId` are non-empty strings.
3. Verify caller's `villageIds` claim includes `villageId`.
4. Firestore transaction:
   a. Read `services/{serviceId}` — verify `isActive`, `villageId` matches, `deletedAt` is null.
   b. Check `capacity` — if `capacity > 0 && registeredCount >= capacity`, throw `resource-exhausted`.
   c. Query `participations` where `residentUid == uid && serviceId == serviceId && status != "cancelled"` — if exists, throw `already-exists`.
   d. Create `participations/{auto}` with fields per §5.7: `villageId`, `householdId` (= uid in Phase 1), `residentUid`, `serviceId`, `status: "registered"`, `registeredAt: serverTimestamp`.
   e. Increment `services/{serviceId}.registeredCount` by 1.
5. Write audit entry: `action: "participation.register"`.
6. Return `{ ok, participationId }`.

### Rate limit

10 registrations per uid per hour.

### Idempotency

If a participation already exists for the same uid + serviceId with status `registered`, return the existing participationId without creating a duplicate.

---

## 3. `attendanceConfirm` callable

**Location**: `functions/src/attendanceConfirm.js` (already exists as a stub — wire to full logic)

### Input

```json
{
  "qrToken": "string",
  "serviceId": "string",
  "villageId": "string"
}
```

### Logic

1. `requireAuth(request)` — must be authenticated.
2. `requireRole(request, ['field_worker', 'health_worker', 'service_provider', 'admin', 'super_admin'])`.
3. Verify scanner's `villageIds` includes `villageId` (scope check per §7.4).
4. Call `verifyQrTokenString(qrToken, secret)` — validates HMAC, expiration, village match.
5. Extract `householdId` from the verified payload.
6. Query `participations` where `residentUid == householdId && serviceId == serviceId && status == "registered"`.
   - If not found: throw `not-found` ("Resident is not registered for this service").
   - If found: update participation status to `attended`, set `scannedAt: serverTimestamp`, `scannedByUid: request.auth.uid`, `scanGeohash` (from request data if provided).
7. Write audit entry: `action: "participation.confirm"`.
8. Return `{ ok, participationId, householdSummary: { name } }`.

### service_provider scope check

If caller role is `service_provider`, verify `services/{serviceId}.assignedServiceProviderUid == request.auth.uid`. Otherwise deny.

---

## 4. FCM Topic Wiring

### Topics

| Topic pattern | Subscribers | Trigger |
|---------------|------------|---------|
| `village_{villageId}` | All residents + staff in the village | On enrollment (Phase 1), on staff role grant |
| `village_{villageId}_service_{type}` | Residents registered for services of that type | On service registration |

### Implementation

- **Subscribe on enrollment**: after `enrollment.createHousehold` succeeds, subscribe the user's FCM token to `village_{villageId}`. Add to the enrollment callable or as a separate Firestore trigger on household create.
- **Subscribe on service registration**: after `serviceRegistration` callable succeeds, subscribe to `village_{villageId}_service_{type}`.
- **Unsubscribe on cancellation**: if a resident cancels a registration (update participation status to `cancelled`), unsubscribe from the service-type topic.
- **Web FCM**: wire `web/firebase-messaging-sw.js` (currently a placeholder) to handle background messages. Foreground messages handled by `firebase_messaging` in-app.

### Notifications sent

| Event | Topic | Title (AR) | Body (AR) |
|-------|-------|-----------|----------|
| New service created | `village_{villageId}` | `خدمة جديدة` | `{serviceTitle} — سجل الآن` |
| Service reminder (1 day before) | `village_{villageId}_service_{type}` | `تذكير بالخدمة` | `{serviceTitle} غداً` |
| Registration confirmed | Direct to user (not topic) | `تم التسجيل` | `تم تسجيلك في {serviceTitle}` |

---

## 5. Firestore Rules Deltas

Current rules already cover:

- `services/{serviceId}`: read for authenticated, create/update for admin/super_admin. **No changes needed.**
- `participations/{pid}`: read for self, staff, service_provider. Create/update/delete denied (Cloud Function only). **No changes needed.**

Potential additions:

- If we add a `service_registrations` subcollection (not planned — using top-level `participations`): N/A.
- Rate limit documents at `rate_limits/{id}`: currently not protected by rules (no client path). Verify the default deny covers them. **Confirmed: the catch-all `/{path=**}` deny covers `rate_limits`.**

---

## 6. Rules-Tests

New file: `rules-tests/services.test.js`

| Test case | Expected |
|-----------|----------|
| Authenticated user reads service in their village | Allow |
| Unauthenticated user reads service | Deny |
| Admin creates service | Allow |
| Resident creates service | Deny |
| Resident reads own participation | Allow |
| Staff reads participation in their village | Allow |
| Staff reads participation in different village | Deny |
| service_provider reads participation (not tested for own-service filter — rules don't enforce this, callable does) | Allow (if in village) |
| Client writes participation | Deny |
| Client deletes participation | Deny |

---

## 7. Telemetry Events

| Event name | Dimensions | Triggered by |
|-----------|-----------|-------------|
| `service_created` | `villageId`, `serviceType` | Admin creates service |
| `service_registered` | `villageId`, `serviceType`, `serviceId` | Resident registers |
| `service_cancelled` | `villageId`, `serviceType`, `serviceId` | Resident cancels |
| `attendance_confirmed` | `villageId`, `serviceType`, `serviceId`, `scannedByRole` | Staff confirms attendance |
| `attendance_no_show` | `villageId`, `serviceType`, `serviceId` | Scheduled function marks no-shows after event date |

All events are PII-free per `CLAUDE.md`. No uid, name, or phone in analytics events.

---

## 8. Phase Toggle UX

- Village admin → village settings screen → toggle `phase_2_services` (requires step-up auth per §6.3).
- Toggle calls `villageManagement.updatePhaseConfig` callable (to be created or extend existing `villageManagement.js`).
- Audit entry: `action: "village.phaseConfig.update"`, `details: { phase_2_services: true }`.
- On toggle-on: services routes become visible for all users in the village.
- On toggle-off: services routes show `PhasePlaceholderScreen`. Existing registrations and participations are preserved but hidden.

---

## 9. ARB Keys (Phase 2)

| Key | AR | EN |
|-----|----|----|
| `services_title` | `الخدمات` | `Services` |
| `service_detail_title` | `تفاصيل الخدمة` | `Service details` |
| `service_register_button` | `تسجيل` | `Register` |
| `service_registered_label` | `مسجل` | `Registered` |
| `service_at_capacity` | `الخدمة ممتلئة` | `Service at capacity` |
| `service_create_title` | `إنشاء خدمة` | `Create service` |
| `service_type_training` | `تدريب` | `Training` |
| `service_type_employment` | `توظيف` | `Employment` |
| `service_type_giveaway` | `توزيع` | `Giveaway` |
| `service_type_medical` | `طبي` | `Medical` |
| `service_type_agricultural` | `زراعي` | `Agricultural` |
| `service_type_legal` | `قانوني` | `Legal` |
| `service_type_children` | `أطفال` | `Children` |
| `attendance_confirm_success` | `تم تأكيد الحضور` | `Attendance confirmed` |
| `attendance_not_registered` | `المقيم غير مسجل لهذه الخدمة` | `Resident is not registered for this service` |
| `scan_qr_for_service` | `امسح رمز QR لتأكيد الحضور` | `Scan QR to confirm attendance` |
| `capacity_remaining` | `المتبقي: {count}` | `Remaining: {count}` |

---

## Effort Estimate

| Component | Days |
|-----------|------|
| Services list + detail screens | 2 |
| Service create screen | 1 |
| `serviceRegistration` callable + tests | 1.5 |
| `attendanceConfirm` callable wiring + tests | 1 |
| FCM topic wiring (subscribe/unsubscribe + SW) | 1.5 |
| Rules-tests for services | 0.5 |
| Telemetry events | 0.5 |
| Phase toggle callable + admin UI | 0.5 |
| Localization (ARB keys) | 0.5 |
| Integration testing (emulator) | 1 |
| **Total** | **10** |

---

## Risks

| Risk | Mitigation |
|------|-----------|
| Overbooking race condition in registration | Firestore transaction with read-then-write in `serviceRegistration` callable. |
| FCM web push unreliable on Safari iPad | Document as known limitation. Safari requires Add-to-Home-Screen for push. |
| Large service lists slow on 2G Egyptian networks | Paginate with Firestore `limit(20)` + cursor. Cache aggressively. |
| service_provider scope enforcement is in callable only, not in rules | Acceptable — the rule denies all client writes to participations anyway. Document the trade-off. |

---

## References

- `hayati-architecture.md` §3 Phase 2, §5.6, §5.7, §2.3.
- `CLAUDE.md` — canonical vocabulary, trigger safety, phase discipline.
- `plans/phase-1-closeout.md` — prerequisite plan.
