# Hayati (حياتي) — El Haya Foundation Community Platform
## Enterprise Architecture & Implementation Blueprint

> Version 2.0 — enterprise-grade rewrite. Reviewed against production Firebase+Flutter patterns from Orchestra (multi-tenant FM app, 2026-03). All sections are authoritative — no placeholders, no open hand-waving.

---

## 1. Product Summary

**Hayati** is a mobile-first community enrollment and services platform operated by **El Haya Foundation**, a non-governmental organization delivering training, medical, agricultural, legal, and material aid to rural villages in Egypt.

The platform launches in **Abusir** (Giza governorate) and expands to additional villages under independent rollouts. Each village operates on its own phase timeline, its own staff, and its own service calendar, while sharing a single application binary, a single Firestore database, and a single foundation-wide admin view.

Residents self-enroll through a link shared on the village Facebook group, complete a phone OTP, receive a permanent signed QR code that acts as their identity and access ticket for all foundation services, and progressively share more profile data in exchange for more benefits.

**Core principles:**
- Every data collection step is gated behind a **tangible benefit**.
- Every sensitive action is **audited and reversible**.
- Every village is **independent** in its phase rollout.
- Every feature is **offline-first** and **low-literacy friendly**.
- Every release is **staged, tested, and rollback-able**.

---

## 2. User Roles & RBAC

### 2.1 Role catalog

All roles are stored as Firebase Auth **custom claims** set exclusively by Cloud Functions (Admin SDK). Role assignment cannot be self-modified from the client.

| Role | Scope | Description | Assigned by |
|------|-------|-------------|-------------|
| `resident` | Village | Default for self-enrollment. Owns a household record. Can view services, access own QR, read blog, register for services, report issues, view own profile. | Self (on enrollment) |
| `field_worker` | Village | Foundation ground staff. Can scan QR codes, confirm service participation, log attendance, assist residents with enrollment door-to-door. | `admin` or `super_admin` |
| `health_worker` | Village | Medical convoy and clinic staff. Can read medical profiles (with step-up auth), log health visits, manage medical service registrations. | `admin` or `super_admin` |
| `data_collector` | Village | Progressive profile data collector (Phase 3). Can edit household profile fields after consent-ledger entry. | `admin` or `super_admin` |
| `service_provider` | Village | External partners (trainers, veterinarians, legal aid volunteers). Can view attendees for their own services, mark attendance at their events. Cannot see household data outside their service. | `admin` or `super_admin` |
| `admin` | Village | Full village management. Creates/edits services, publishes blog posts, manages village staff roles, views village dashboard, approves sensitive data changes, manages village phase config. | `super_admin` |
| `super_admin` | Foundation | El Haya Foundation HQ. Cross-village village switcher. Creates new villages, sets village-level Remote Config, issues/revokes admin claims, views foundation-wide aggregate dashboard, manages global emergency kill switch. | Bootstrapped manually via Admin SDK |

### 2.2 Custom claim shape

```jsonc
{
  "role": "field_worker",          // single role per token
  "villageIds": ["abusir"],        // scope — empty means foundation-wide (super_admin only)
  "permissions": [                 // optional fine-grained flags
    "canScanQr",
    "canConfirmAttendance"
  ],
  "stepUpExpiresAt": 1712563200    // unix ts of last successful step-up OTP
}
```

Rules always use `request.auth.token.role`, `request.auth.token.villageIds`, and `request.auth.token.stepUpExpiresAt`. Claims are issued via `userManagement.js` Cloud Function (similar to Orchestra's `setUserRole` callable).

### 2.3 Permission matrix (Phase 1–6)

| Capability | resident | field_worker | health_worker | data_collector | service_provider | admin | super_admin |
|---|---|---|---|---|---|---|---|
| Self-enroll (create own household) | ✅ | — | — | — | — | — | — |
| View own QR | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Scan QR | — | ✅ | ✅ | ✅ | ✅ (own service only) | ✅ | ✅ |
| Confirm service attendance | — | ✅ | ✅ | — | ✅ (own service only) | ✅ | ✅ |
| Read blog | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Write blog | — | — | — | — | — | ✅ | ✅ |
| View services list | ✅ | ✅ | ✅ | ✅ | own | ✅ | ✅ |
| Register for service | ✅ | — | — | — | — | — | — |
| Create/edit services | — | — | — | — | — | ✅ | ✅ |
| Read own profile | ✅ | — | — | — | — | — | — |
| Read household public fields | — | ✅ | ✅ | ✅ | — | ✅ | ✅ |
| Read household **medical** (step-up) | — | — | ✅ | — | — | ✅ | ✅ |
| Read household **children** (step-up) | — | — | — | ✅ | — | ✅ | ✅ |
| Read household **finance** (step-up) | — | — | — | — | — | ✅ | ✅ |
| Edit household profile (with consent) | — | — | — | ✅ | — | ✅ | ✅ |
| Submit community report | ✅ | ✅ | ✅ | ✅ | — | ✅ | ✅ |
| Read report (blurred) | own | ✅ | ✅ | — | — | ✅ | ✅ |
| Transition report status | — | ✅ | — | — | — | ✅ | ✅ |
| Log garbage payment | — | ✅ | — | — | — | ✅ | ✅ |
| Create village | — | — | — | — | — | — | ✅ |
| Toggle village phase config | — | — | — | — | — | ✅ | ✅ |
| Issue staff role | — | — | — | — | — | ✅ (village roles) | ✅ (any) |
| Data export (CSV) | — | — | — | — | — | ✅ (own village) | ✅ |
| Global emergency kill switch | — | — | — | — | — | — | ✅ |

Residents cannot be staff on the same account. A person who is both (e.g. a field_worker who lives in the village) must have a separate staff account.

---

## 3. Phase Rollout Plan

All 6 phases ship in every release. Features are hidden until the **per-village phase flag** is enabled. The foundation toggles phases per village — Abusir may be on Phase 3 while a newly-added village is still on Phase 1.

### Phase 1 — Enrollment + QR Identity (MVP)
- Phone OTP authentication (Firebase Auth Phone provider).
- Self-registration: name (Arabic), address (free text), household size, comment field.
- Auto GPS stamp on save (+ reverse geocode with geohash).
- Generate permanent **signed QR code** (encodes villageId + householdId + HMAC).
- QR displayed full-screen with "Save to Gallery" and "Share" options.
- Blog feed (read-only for residents).
- Village context resolved from enrollment link (`hayati://enroll/v/{villageId}`).

### Phase 2 — Service Access
- Services board per village (training, employment, giveaways, medical, agricultural, legal, children).
- Register for a service (one tap). Registration is **Cloud-Function-transacted** to prevent overbooking.
- At the event: staff scan resident QR → Function verifies signature + village + capacity → logs participation → appends audit entry.
- Push notifications via FCM topics `village_{villageId}` and `village_{villageId}_service_{type}`.

### Phase 3 — Progressive Data Collection (sensitive subcollections)
Data is collected into **per-category subcollections** under the household, each gated behind an explicit consent ledger entry:
- `children` subcollection → unlocks school supply distribution + tutoring
- `medical` subcollection → unlocks medical convoy priority + pharmacy vouchers
- `skills` subcollection → unlocks employment matching + advanced training
- `agriculture` subcollection → unlocks seeds/equipment/veterinary programs
- `finance` subcollection → unlocks micro-loan eligibility (optional)

### Phase 4 — Community Communication
- Rich blog posts (text + images + audio). Audio support is critical for low-literacy users.
- Event calendar with reminders.
- Success stories (with photo release consent-ledger entry).
- Foundation transparency reports.
- Simple polls/surveys.

### Phase 5 — Garbage Collection & Community Watch
- Garbage fee payment logged by staff (Cloud Function + audit entry).
- Community watch: photo upload with on-device face blur, auto GPS + geohash, status tracking (reported → acknowledged → in_progress → resolved).
- **Only blurred photo is persisted.** Original is discarded after blur; face bounding box metadata is kept for audit.
- Anonymous reporting option (no householdId, device-signed).
- Cleanest-area gamification.

### Phase 6 — Training Modules
- In-app training: video + quiz.
- Completion stored in `training_progress` subcollection.
- Certificate generation on completion (Cloud Function, signed PDF).
- Prerequisites enforced at service registration time (e.g. hygiene-101 required for medical convoy attendance).

---

## 4. Flutter Project Structure

```
hayah/
├── android/
│   └── app/
│       └── src/
│           ├── dev/        # Flavor
│           ├── staging/    # Flavor
│           └── prod/       # Flavor
├── ios/
├── assets/
│   ├── images/
│   ├── audio/              # Audio blog intro stubs
│   └── fonts/              # Cairo / Tajawal for Arabic
├── lib/
│   ├── main.dart           # Flavor-aware entrypoint (main_dev.dart / _staging / _prod)
│   ├── main_dev.dart
│   ├── main_staging.dart
│   ├── main_prod.dart
│   ├── app.dart            # MaterialApp, theme, routing, locale
│   ├── firebase_options_dev.dart
│   ├── firebase_options_staging.dart
│   ├── firebase_options_prod.dart
│   ├── l10n/               # ARB files (Flutter convention)
│   │   ├── app_ar.arb
│   │   └── app_en.arb
│   ├── gen_l10n/           # Generated
│   ├── core/
│   │   ├── config/
│   │   │   ├── flavor_config.dart
│   │   │   └── app_config.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   ├── constants/
│   │   │   ├── timeout_constants.dart
│   │   │   ├── firestore_collections.dart
│   │   │   ├── business_constants.dart
│   │   │   └── feature_flags.dart
│   │   ├── services/
│   │   │   ├── firebase_service.dart
│   │   │   ├── app_check_service.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── location_service.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── phase_gate_service.dart       # Reads per-village phaseConfig
│   │   │   ├── village_service.dart          # CRUD on villages
│   │   │   ├── qr_service.dart               # Generation + signature verify (via Function)
│   │   │   ├── audit_service.dart            # Append-only log client
│   │   │   ├── consent_service.dart          # Consent ledger client
│   │   │   ├── sync_queue_service.dart       # Offline-first write queue
│   │   │   ├── crashlytics_service.dart
│   │   │   ├── analytics_service.dart
│   │   │   ├── logger_service.dart           # AppLogger (no raw print)
│   │   │   └── connectivity_service.dart
│   │   ├── providers/                        # Riverpod
│   │   │   ├── auth_provider.dart
│   │   │   ├── village_provider.dart         # Active village context
│   │   │   ├── phase_provider.dart           # Phase flags for active village
│   │   │   ├── household_provider.dart
│   │   │   └── connectivity_provider.dart
│   │   ├── models/
│   │   │   ├── village.dart
│   │   │   ├── household.dart
│   │   │   ├── sensitive/
│   │   │   │   ├── children_record.dart
│   │   │   │   ├── medical_record.dart
│   │   │   │   ├── skills_record.dart
│   │   │   │   ├── agriculture_record.dart
│   │   │   │   └── finance_record.dart
│   │   │   ├── consent_entry.dart
│   │   │   ├── audit_entry.dart
│   │   │   ├── service_event.dart
│   │   │   ├── participation.dart
│   │   │   ├── blog_post.dart
│   │   │   ├── report.dart
│   │   │   ├── training_module.dart
│   │   │   └── training_progress.dart
│   │   ├── widgets/
│   │   │   ├── big_button.dart
│   │   │   ├── icon_label_card.dart
│   │   │   ├── loading_overlay.dart
│   │   │   ├── phase_gate.dart               # Per-village flag check
│   │   │   ├── role_gate.dart                # RBAC check
│   │   │   ├── step_up_gate.dart             # Re-OTP gate
│   │   │   ├── rtl_aware_icon.dart
│   │   │   └── audio_player_card.dart        # Blog audio
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── arabic_utils.dart
│   │       ├── gps_utils.dart                # Includes geohash
│   │       └── image_utils.dart              # Resize before upload
│   ├── features/
│   │   ├── village_picker/                   # super_admin
│   │   │   └── screens/village_picker_screen.dart
│   │   ├── onboarding/
│   │   │   └── screens/
│   │   │       ├── welcome_screen.dart
│   │   │       ├── phone_otp_screen.dart
│   │   │       └── consent_screen.dart        # Versioned T&C
│   │   ├── enrollment/
│   │   │   └── screens/
│   │   │       ├── enrollment_screen.dart
│   │   │       └── enrollment_success_screen.dart
│   │   ├── qr/
│   │   │   └── screens/
│   │   │       ├── my_qr_screen.dart
│   │   │       └── qr_scanner_screen.dart
│   │   ├── home/
│   │   │   └── screens/
│   │   │       ├── resident_home_screen.dart
│   │   │       ├── staff_home_screen.dart
│   │   │       └── super_admin_home_screen.dart
│   │   ├── services/                          # Phase 2
│   │   ├── profile/                           # Phase 3 (sensitive subcollection editors)
│   │   ├── blog/                              # Phase 4
│   │   ├── community_watch/                   # Phase 5
│   │   ├── training/                          # Phase 6
│   │   ├── admin/
│   │   │   └── screens/
│   │   │       ├── staff_management_screen.dart
│   │   │       ├── village_settings_screen.dart  # Phase toggles
│   │   │       └── data_export_screen.dart
│   │   └── settings/
│   │       └── screens/
│   │           ├── language_screen.dart
│   │           └── accessibility_screen.dart
│   └── routing/
│       ├── app_router.dart                   # GoRouter with phase + role guards
│       └── route_guards.dart
├── functions/                                # Cloud Functions (Node 20)
│   ├── src/
│   │   ├── index.js
│   │   ├── userManagement.js                 # Set custom claims
│   │   ├── enrollment.js                     # Callable: create household
│   │   ├── qrSignature.js                    # Callable: sign + verify QR
│   │   ├── serviceRegistration.js            # Transactional register
│   │   ├── attendanceConfirm.js              # QR scan → participation
│   │   ├── villageManagement.js              # Create / update village, phase toggles
│   │   ├── reportWorkflow.js                 # Status transitions
│   │   ├── garbagePayment.js
│   │   ├── dataExport.js
│   │   ├── rightToErasure.js
│   │   ├── scheduledBackup.js                # Daily Firestore export
│   │   ├── dataIntegrityCheck.js             # Invariant monitor
│   │   └── utils/
│   │       ├── triggerGuard.js               # skipIfUnchanged, single-write
│   │       ├── auditLog.js                   # Append entry
│   │       ├── rateLimiter.js                # Per-uid + per-ip limits
│   │       └── kms.js                        # Field-level encryption
│   └── package.json
├── rules-tests/                              # Firestore rules test suite
│   ├── households.test.js
│   ├── villages.test.js
│   ├── sensitive.test.js
│   ├── audit_log.test.js
│   └── package.json
├── test/                                     # Flutter unit + widget tests
├── integration_test/                         # Emulator-backed integration
├── docs/
│   ├── adr/
│   │   ├── 0001-identity-and-auth.md
│   │   ├── 0002-phase-gating-per-village.md
│   │   ├── 0003-sensitive-data-split.md
│   │   ├── 0004-signed-qr.md
│   │   └── 0005-offline-first-sync-queue.md
│   ├── DATA_MODEL.md
│   ├── RUNBOOK.md
│   ├── SECURITY.md
│   ├── PRIVACY.md
│   └── ACCESSIBILITY.md
├── .github/
│   └── workflows/
│       ├── pr.yml                            # analyze, test, rules, build dev
│       ├── staging.yml                       # deploy to Firebase App Distribution
│       └── prod.yml                          # manual gate, Play Store
├── firebase.dev.json
├── firebase.staging.json
├── firebase.prod.json
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
├── pubspec.yaml
└── CLAUDE.md
```

---

## 5. Firestore Schema

Every document carries `schemaVersion: int`, `createdAt: serverTimestamp`, `updatedAt: serverTimestamp`, and (where applicable) `deletedAt: timestamp | null` for soft deletes.

### 5.1 Villages (new, top-level)

```
villages/{villageId}
├── name: string                 "أبوصير"
├── nameEn: string               "Abusir"
├── governorate: string          "الجيزة"
├── gps: geopoint
├── geohash: string
├── phaseConfig: {               // Per-village, independent rollout
│     phase_1_enrollment: true,
│     phase_2_services: false,
│     phase_3_profile: false,
│     phase_4_blog: true,
│     phase_5_community_watch: false,
│     phase_6_training: false
│   }
├── featureKillSwitch: bool      // Global emergency disable (settable by super_admin)
├── stats: {                     // Denormalized, updated by Cloud Function
│     enrolledHouseholds: int,
│     activeUsers30d: int,
│     lastAggregatedAt: timestamp
│   }
├── createdBy: string            // super_admin uid
├── createdAt, updatedAt, schemaVersion
└── isActive: bool
```

### 5.2 Households (identity, public+internal fields only)

```
households/{householdId}
├── villageId: string            // REQUIRED — scopes every query
├── ownerUid: string              // Firebase Auth uid of the enrolling resident
├── name: string                 "محمد أحمد"
├── phone: string                "+201012345678" (E.164, recovery only)
├── address: string              "شارع المدرسة، أبوصير"
├── householdSize: int
├── comment: string              "نفسي في نضافة الشوارع"
├── gps: geopoint
├── geohash: string
├── qrTokenId: string            // Current signed QR token ID (rotates on re-link)
├── profileCompletion: int       // 0-100, drives Phase 3 unlocks
├── consentVersion: int          // Privacy policy version they agreed to
├── deviceId: string             // Hint for seamless re-login (not identity)
├── role: string                 // Mirror of custom claim for denormalized queries
├── createdAt, updatedAt, deletedAt, schemaVersion
```

### 5.3 Sensitive subcollections (Phase 3+)

```
households/{householdId}/sensitive/medical
├── conditions: [{ name, diagnosedAt, notes }]
├── medications: [{ name, dosage }]
├── bloodType: string
├── encryptedPayload: blob      // KMS-wrapped field-level encryption
├── consentId: string           // Ref to consents/{id}
├── updatedBy: string, updatedAt, schemaVersion

households/{householdId}/sensitive/children
├── children: [{ name, birthYear, gender, schoolId, grade }]
├── consentId: string
├── parentalConsent: bool       // Required — parent must OTP-confirm
└── ...

households/{householdId}/sensitive/skills
households/{householdId}/sensitive/agriculture
households/{householdId}/sensitive/finance
```

### 5.4 Consent ledger (append-only)

```
households/{householdId}/consents/{consentId}
├── scope: string                "medical" | "children" | "photo_release" | "privacy_v2" | ...
├── version: int
├── grantedAt: timestamp
├── grantedByUid: string         // Who performed the grant (may be self or data_collector)
├── onBehalfOfUid: string        // Resident whose data it is (for staff-assisted capture)
├── evidence: {
│     method: "otp" | "signature" | "in_person_witness",
│     tokenHash: string,         // HMAC of OTP token
│     witnessUid: string?        // For in-person capture
│   }
├── revokedAt: timestamp | null
└── schemaVersion: int
```

Rules: `create` allowed for authenticated users matching household; `update` allowed only to set `revokedAt`; `delete` forbidden.

### 5.5 Audit log (append-only, top-level)

```
audit_log/{entryId}
├── timestamp: serverTimestamp
├── villageId: string            // For scoped queries
├── actorType: "resident" | "staff" | "function" | "system"
├── actorUid: string
├── actorRole: string
├── action: string               // "household.create", "participation.confirm", "role.grant", ...
├── resourceType: string
├── resourceId: string
├── resourceVillageId: string
├── summary: string
├── diff: map                    // Changed keys only (bounded size)
├── metadata: {
│     platform: string,
│     appVersion: string,
│     requestId: string,
│     ip: string?,               // Hashed
│     gpsGeohashPrefix: string?  // First 5 chars only
│   }
└── schemaVersion: int
```

Rules: `create` allowed only via Cloud Function service account (client path denied). `update`, `delete` forbidden for everyone including super_admin.

### 5.6 Services (per village)

```
services/{serviceId}
├── villageId: string            // REQUIRED
├── title: string, titleEn: string
├── type: "training" | "employment" | "giveaway" | "medical" | "agricultural" | "legal" | "children"
├── description: string
├── date: timestamp
├── location: geopoint, geohash: string, locationName: string
├── capacity: int                // 0 = unlimited
├── registeredCount: int         // Updated ONLY by Cloud Function transaction
├── requirements: {
│     minProfileCompletion: int,
│     requiredSensitiveCategories: ["medical"],
│     requiredTraining: ["hygiene-101"]
│   }
├── imageUrl: string
├── isActive: bool
├── createdByUid: string
├── assignedServiceProviderUid: string | null   // For service_provider scope
└── createdAt, updatedAt, deletedAt, schemaVersion
```

### 5.7 Participations

```
participations/{participationId}
├── villageId: string            // Denormalized from service for scoped queries
├── householdId: string
├── residentUid: string
├── serviceId: string
├── status: "registered" | "attended" | "no_show" | "cancelled"
├── registeredAt: timestamp
├── scannedAt: timestamp
├── scannedByUid: string
├── scanGeohash: string
├── notes: string
└── createdAt, updatedAt, schemaVersion
```

### 5.8 Posts (blog, per village)

```
posts/{postId}
├── villageId: string
├── title: string, body: string
├── images: [string]             // Storage URLs (resized, <500KB)
├── audioUrl: string | null      // For low-literacy readers
├── authorUid: string
├── isPinned: bool
├── publishedAt: timestamp
└── createdAt, updatedAt, deletedAt, schemaVersion
```

### 5.9 Reports (Phase 5)

```
reports/{reportId}
├── villageId: string
├── householdId: string | null   // null = anonymous
├── reporterUid: string | null
├── type: "garbage" | "violation" | "infrastructure"
├── description: string
├── blurredImageUrl: string      // Only blurred version stored
├── faceBBoxes: [{x,y,w,h}]      // Metadata for audit
├── gps: geopoint, geohash: string
├── status: "new" | "acknowledged" | "in_progress" | "resolved"
├── statusHistory: [{ status, at, byUid }]
├── adminNotes: string
├── createdAt, resolvedAt, updatedAt, deletedAt, schemaVersion
```

### 5.10 Training (Phase 6)

```
training_modules/{moduleId}
├── villageIds: [string]         // Null/empty = foundation-wide
├── title, description, videoUrl, duration, passingScore, order, isActive
├── quiz: [{ question, options, correctIndex }]
└── createdAt, updatedAt, schemaVersion

training_progress/{progressId}
├── villageId, householdId, residentUid, moduleId
├── videoWatched: bool, quizScore: int, passed: bool, completedAt: timestamp
├── certificateUrl: string
└── createdAt, updatedAt, schemaVersion
```

### 5.11 Garbage payments (Phase 5)

```
garbage_payments/{paymentId}
├── villageId, householdId
├── amount: number, currency: "EGP"
├── period: "2026-04"
├── collectedByUid: string
├── method: "cash" | "digital"
├── gps: geopoint, geohash
├── auditEntryId: string
└── createdAt, schemaVersion
```

### 5.12 Sync queue (client-local, mirrored to user scratch space)

```
users/{uid}/sync_queue/{opId}
├── op: "create" | "update"
├── target: "household" | "participation" | "report" | "consent"
├── payload: map
├── createdAt, attempts: int, lastError: string
```

Processed by the client; used for offline-originated writes.

---

## 6. Authentication Strategy

**Firebase Auth Phone provider is enabled from Day 1.** Device-only identity is not acceptable for a platform handling medical, children, and financial data.

### 6.1 Resident enrollment flow

1. User taps village enrollment link → `hayati://enroll/v/{villageId}` → app opens or Play Store redirect.
2. Language picker (Arabic default, English optional).
3. **Versioned consent screen** — user must accept current privacy policy version. Stored with `consentVersion` number.
4. **Phone OTP** (Firebase Auth Phone provider, via reCAPTCHA + Play Integrity in Android).
5. Enrollment form: name, address, household size, comment, auto GPS.
6. **Callable function `enrollment.createHousehold`** — validates shape, creates household under `households/{uid}`, sets `villageId`, issues signed QR token, sets custom claim `{ role: "resident", villageIds: [villageId] }`.
7. Client receives QR → displays success screen.

### 6.2 Staff issuance flow

- super_admin or village admin opens "Manage staff" screen.
- Enters phone number + selects role + (optional) permissions.
- Callable function `userManagement.grantStaffRole` verifies caller, OTPs the staff phone, creates user account, sets claims server-side.
- No staff role can be self-assigned.

### 6.3 Re-authentication (step-up)

Sensitive actions require the user to have a **fresh OTP within the last 5 minutes**:
- Editing medical/children/finance subcollections
- Logging garbage payment
- Granting/revoking staff roles
- Village phase config changes
- Data export
- Right-to-erasure requests

Enforced in both rules (`request.auth.token.stepUpExpiresAt > request.time`) and Cloud Functions.

### 6.4 Device binding

`users/{uid}.deviceIds` is a hint array for seamless re-login. Up to 2 devices. If a third is added, the oldest is evicted and an audit entry is written. Device binding is **never** used as identity — the Firebase Auth token is authoritative.

### 6.5 Account recovery

- User lost phone → contacts village admin → admin triggers `userManagement.recoverAccount` → admin OTPs new phone → user's custom claims migrate → audit entry written.
- All recovery is logged; super_admin can review.

---

## 7. QR Code (signed)

### 7.1 Encoding

```
hayati://v/{villageId}/h/{householdId}?t={tokenId}&s={hmacSig}
```

- `tokenId` — short identifier for the current active token (rotates on re-link).
- `hmacSig` — HMAC-SHA256(`secret_key`, `villageId|householdId|tokenId|issuedAt`). Secret lives in Secret Manager, accessible only to `qrSignature.js` Cloud Function.

### 7.2 Generation

- On enrollment or re-link, `qrSignature.issueToken` callable runs, issues a token, stores `qrTokenId` on the household, signs and returns the full URI.
- Client renders the URI with `qr_flutter`. Black on white, El Haya logo watermark, printed householdId for human verification.

### 7.3 Scanning & verification

- Scanner app (`mobile_scanner`) extracts URI → calls `qrSignature.verifyToken` callable with the URI.
- Function verifies HMAC, checks villageId scope against scanner's token, checks token is current (not rotated/revoked), returns household summary.
- Offline grace: Function returns a short-lived local signing key (JWT, 10 min TTL) on first scan so repeat scans at the same event can verify locally. Revoked on event end.

### 7.4 Impersonation resistance

A photographed QR **cannot** be reused:
- Verification requires villageId scope match — a field_worker in village A cannot scan a resident of village B.
- tokenId rotation invalidates old QRs on re-link.
- Event-bound offline grace keys prevent after-event spoofing.

---

## 8. Key Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State management | **Riverpod** | Familiar from Orchestra, testable, compile-safe |
| Routing | **GoRouter** | Deep links, declarative phase + role guards |
| Auth | **Firebase Auth (Phone OTP)** | Day 1, not deferred |
| Offline | **Firestore persistence + explicit sync queue** | Write queue for auditable operations |
| Phase gating | **Per-village Firestore `phaseConfig` doc** | Independent village rollouts |
| Emergency kill | **Firebase Remote Config global flag** | Single-toggle feature disable across all villages |
| Push | **FCM topics** (`village_{id}`, `role_{role}`) | Scalable targeted delivery |
| Image storage | **Firebase Storage** + client resize | <500KB max, lifecycle tied to docs |
| Face blur | **google_mlkit_face_detection**, original discarded | On-device, privacy-preserving |
| QR generation | **qr_flutter** | Pure Dart |
| QR scanning | **mobile_scanner** | Maintained, fast |
| QR signature | **HMAC-SHA256 via Cloud Function + Secret Manager** | Forge-resistant |
| GPS | **geolocator + dart_geohash** | Geohash enables range queries |
| Localization | **flutter_localizations + ARB in `lib/l10n/`** | Flutter convention |
| Arabic fonts | **Tajawal** (bundled) | Consistent rendering across devices |
| App Check | **Play Integrity (Android), DeviceCheck (iOS)** | Blocks non-app clients |
| Field encryption | **google_tink_flutter** (KMS-wrapped) | Medical + finance fields |
| Crash reporting | **Firebase Crashlytics** | Sliced by village + role |
| Performance | **Firebase Performance Monitoring** | Cold start, screen renders |
| Analytics | **Firebase Analytics** (PII-free events) | Funnel tracking |
| Logging | **AppLogger + Cloud Logging** | Structured logs in Functions |
| CI/CD | **GitHub Actions + Firebase App Distribution** | Auto staging, manual prod |
| Testing | **flutter_test, integration_test, @firebase/rules-unit-testing, patrol** | Pyramid coverage |
| Secrets | **Google Secret Manager** (via functions.config) | No secrets in repo |
| Functions region | **europe-west1** | Closest stable region to Egypt |

---

## 9. Phase Gate System (per-village)

```dart
// lib/core/widgets/phase_gate.dart
class PhaseGate extends ConsumerWidget {
  final String featureFlag;      // e.g., "phase_2_services"
  final Widget child;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reads from villages/{activeVillageId}.phaseConfig via Riverpod + Firestore cache
    final enabled = ref.watch(phaseProvider(featureFlag));
    if (enabled.valueOrNull ?? false) return child;
    return placeholder ?? const SizedBox.shrink();
  }
}
```

- `phase_provider.dart` streams `villages/{activeVillageId}` and exposes a per-flag boolean.
- Cache-first (Firestore persistence) → zero network on cold start.
- Emergency global kill switch via Firebase Remote Config (`global_kill_switch: bool`). If true, all phases disabled regardless of village config.
- Phase toggles in the admin UI require step-up auth and append an audit entry.

---

## 10. Resident Home Screen (Phase 1)

```
┌──────────────────────────────┐
│  أبوصير  مؤسسة الحياة  [≡]   │
│──────────────────────────────│
│  أهلاً يا محمد 👋            │
│  ┌──────────────────────┐    │
│  │   [ QR CODE ]        │    │
│  │   اضغط لتكبير        │    │
│  └──────────────────────┘    │
│  ── آخر الأخبار ──           │
│  ┌──────────────────────┐    │
│  │ 📷 [Blog image]      │    │
│  │ 🔊 [Audio play]      │    │
│  │ مؤسسة الحياة ترحب... │    │
│  └──────────────────────┘    │
│  [Phase 2+ hidden sections]  │
│  ┌────┐ ┌────┐ ┌────┐       │
│  │ 🏠 │ │ 📋 │ │ 👤 │       │
│  │بيتي │ │خدمات│ │حسابي│      │
│  └────┘ └────┘ └────┘       │
└──────────────────────────────┘
```

- Active village name shown top-left (RTL).
- Big icons, minimum 48dp touch targets.
- Audio playback on blog posts for non-readers.
- Screen reader labels on every actionable element.
- Font scale respects system setting up to 2.0x.

---

## 11. Staff & Admin Flows

### 11.1 field_worker
Scan QR → verify → confirm attendance → tap to log. All one-handed, large targets.

### 11.2 admin (village)
Dashboard (enrollment, services, reports counters) → create service → publish blog → manage staff → toggle phase flags (step-up) → export village data (step-up).

### 11.3 super_admin
Village picker on login → select village → acts as village admin in that scope, OR select "Foundation-wide" to see aggregate dashboard (read-only counters across all villages). Create village action at top-right.

---

## 12. Firestore Security Rules (v1)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() { return request.auth != null; }
    function role() { return request.auth.token.role; }
    function villageIds() { return request.auth.token.villageIds; }
    function isInVillage(v) {
      return isAuthenticated() && v in villageIds();
    }
    function isSuperAdmin() {
      return isAuthenticated() && role() == 'super_admin';
    }
    function isVillageAdmin(v) {
      return isAuthenticated() && role() == 'admin' && v in villageIds();
    }
    function hasRoleIn(v, roles) {
      return isAuthenticated() && role() in roles && v in villageIds();
    }
    function stepUpFresh() {
      return isAuthenticated() &&
             request.auth.token.stepUpExpiresAt is number &&
             request.auth.token.stepUpExpiresAt > request.time.toMillis() / 1000;
    }
    function isNotDeleted(r) {
      return !('deletedAt' in r.data) || r.data.deletedAt == null;
    }
    function validHouseholdCreate() {
      let d = request.resource.data;
      return d.villageId is string &&
             d.ownerUid == request.auth.uid &&
             d.name is string && d.name.size() > 0 && d.name.size() < 200 &&
             d.householdSize is int && d.householdSize > 0 && d.householdSize < 50 &&
             d.schemaVersion is int &&
             d.createdAt == request.time &&
             !('role' in d) &&              // Role is set by Function, not client
             !('qrTokenId' in d);           // Token is issued by Function
    }

    // ── Villages ────────────────────────────────────────────────────────────
    match /villages/{villageId} {
      allow read: if isAuthenticated();
      allow create: if isSuperAdmin();
      allow update: if isSuperAdmin() ||
                       (isVillageAdmin(villageId) && stepUpFresh() &&
                        request.resource.data.diff(resource.data).affectedKeys()
                          .hasOnly(['phaseConfig', 'updatedAt']));
      allow delete: if false;
    }

    // ── Households ──────────────────────────────────────────────────────────
    match /households/{householdId} {
      allow read: if isNotDeleted(resource) && (
        request.auth.uid == resource.data.ownerUid ||
        hasRoleIn(resource.data.villageId, ['field_worker','health_worker','data_collector','admin','super_admin'])
      );
      allow create: if isAuthenticated() && householdId == request.auth.uid && validHouseholdCreate();
      allow update: if isNotDeleted(resource) && (
        (request.auth.uid == resource.data.ownerUid &&
         !request.resource.data.diff(resource.data).affectedKeys()
           .hasAny(['role','villageId','qrTokenId','ownerUid'])) ||
        (hasRoleIn(resource.data.villageId, ['data_collector','admin','super_admin']) && stepUpFresh())
      );
      allow delete: if false;  // Soft delete only via Function

      // Sensitive subcollections
      match /sensitive/medical {
        allow read: if hasRoleIn(get(/databases/$(database)/documents/households/$(householdId)).data.villageId,
                                 ['health_worker','admin','super_admin']) && stepUpFresh();
        allow write: if hasRoleIn(get(/databases/$(database)/documents/households/$(householdId)).data.villageId,
                                  ['health_worker','admin','super_admin']) && stepUpFresh();
      }
      match /sensitive/children {
        allow read: if hasRoleIn(get(/databases/$(database)/documents/households/$(householdId)).data.villageId,
                                 ['data_collector','admin','super_admin']) && stepUpFresh();
        allow write: if hasRoleIn(get(/databases/$(database)/documents/households/$(householdId)).data.villageId,
                                  ['data_collector','admin','super_admin']) && stepUpFresh();
      }
      match /sensitive/{doc} {
        allow read, write: if hasRoleIn(get(/databases/$(database)/documents/households/$(householdId)).data.villageId,
                                        ['admin','super_admin']) && stepUpFresh();
      }

      match /consents/{consentId} {
        allow read: if request.auth.uid == householdId ||
                       hasRoleIn(get(/databases/$(database)/documents/households/$(householdId)).data.villageId,
                                 ['admin','super_admin']);
        allow create: if request.auth.uid == householdId ||
                         hasRoleIn(get(/databases/$(database)/documents/households/$(householdId)).data.villageId,
                                   ['data_collector','health_worker','admin','super_admin']);
        allow update: if (request.auth.uid == householdId) &&
                         request.resource.data.diff(resource.data).affectedKeys().hasOnly(['revokedAt']);
        allow delete: if false;
      }
    }

    // ── Services ────────────────────────────────────────────────────────────
    match /services/{serviceId} {
      allow read: if isNotDeleted(resource) && isAuthenticated();
      allow create, update: if hasRoleIn(request.resource.data.villageId, ['admin','super_admin']);
      allow delete: if false;
    }

    // ── Participations — writes via Cloud Function only ─────────────────────
    match /participations/{pid} {
      allow read: if isAuthenticated() && (
        request.auth.uid == resource.data.residentUid ||
        hasRoleIn(resource.data.villageId, ['field_worker','health_worker','service_provider','admin','super_admin'])
      );
      allow create, update, delete: if false;  // Cloud Function only
    }

    // ── Posts ───────────────────────────────────────────────────────────────
    match /posts/{postId} {
      allow read: if isNotDeleted(resource) && isAuthenticated();
      allow create, update: if hasRoleIn(request.resource.data.villageId, ['admin','super_admin']);
      allow delete: if false;
    }

    // ── Reports ─────────────────────────────────────────────────────────────
    match /reports/{reportId} {
      allow read: if isAuthenticated() && (
        request.auth.uid == resource.data.reporterUid ||
        hasRoleIn(resource.data.villageId, ['field_worker','health_worker','admin','super_admin'])
      );
      allow create: if isAuthenticated() && request.resource.data.villageId in villageIds();
      allow update: if hasRoleIn(resource.data.villageId, ['field_worker','admin','super_admin']);
      allow delete: if false;
    }

    // ── Audit log — Functions only ──────────────────────────────────────────
    match /audit_log/{id} {
      allow read: if isSuperAdmin() ||
                     (role() == 'admin' && resource.data.villageId in villageIds());
      allow create, update, delete: if false;
    }

    // ── Default deny ────────────────────────────────────────────────────────
    match /{path=**} {
      allow read, write: if false;
    }
  }
}
```

All rules are covered by `rules-tests/` with positive and negative cases per role + village scope.

---

## 13. Packages (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.0
  cloud_firestore: ^5.4.0
  firebase_storage: ^12.3.0
  firebase_messaging: ^15.1.0
  firebase_remote_config: ^5.1.0
  firebase_app_check: ^0.3.1
  firebase_crashlytics: ^4.1.0
  firebase_performance: ^0.10.0
  firebase_analytics: ^11.3.0
  cloud_functions: ^5.1.0

  # QR
  qr_flutter: ^4.1.0
  mobile_scanner: ^5.2.0

  # Location & geohash
  geolocator: ^13.0.1
  geocoding: ^3.0.0
  dart_geohash: ^2.0.2

  # State & Routing
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.7

  # UI
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
  photo_view: ^0.15.0
  flutter_markdown: ^0.7.3
  audioplayers: ^6.1.0

  # Utilities
  device_info_plus: ^11.0.0
  share_plus: ^10.0.2
  path_provider: ^2.1.4
  image: ^4.2.0            # Client-side resize

  # Phase 5
  google_mlkit_face_detection: ^0.11.0

  # Phase 6
  video_player: ^2.9.1

  # Observability
  logging: ^1.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  integration_test:
    sdk: flutter
  patrol: ^3.11.0
  mocktail: ^1.0.4
  golden_toolkit: ^0.15.0
```

---

## 14. Face Blurring Strategy (Phase 5, privacy-first)

```
User takes photo of violation/garbage
      ↓
google_mlkit_face_detection runs ON-DEVICE
      ↓
Gaussian blur applied to face bounding boxes
      ↓
Original image is DISCARDED from memory — never written to disk
      ↓
Only blurred image uploaded to Storage
      ↓
Firestore report stores:
  - blurredImageUrl
  - faceBBoxes (coordinates only, for audit)
  - No original, ever
```

Trade-off acknowledged: ground-truth photos are not recoverable. The foundation accepts this — privacy in a small community where everyone recognizes everyone is more important than forensic fidelity.

---

## 15. Offline-First Sync Queue

Firestore persistence is enabled by default. On top of that, every write from the client follows Orchestra's **local-first queue pattern**:

```dart
// 1. Save to local cache immediately (optimistic UI)
await _cache.save(item);

// 2. Attempt Firestore write
if (ConnectivityService.isConnected) {
  try {
    await _firestore.collection(col).doc(id).set(data);
  } catch (e) {
    await _syncQueue.enqueue(op);
  }
} else {
  await _syncQueue.enqueue(op);
}
```

- `SyncQueueService` watches connectivity, retries queued ops with exponential backoff.
- UI shows a "pending sync" badge on optimistically-saved items.
- Conflict resolution: last-write-wins on non-critical fields; critical fields (participations, payments, sensitive subcollections) go through Cloud Functions which reject stale writes.
- Photo uploads queue in the same way, with background upload service.

---

## 16. Deployment & Environments

### 16.1 Three Firebase projects

| Project | Purpose | Who accesses |
|---|---|---|
| `hayati-dev` | Local dev, emulator suite | Engineering only |
| `hayati-staging` | Pre-release validation, foundation UAT | Engineering + foundation leads |
| `hayati-prod` | Live village users | Engineering (deploy) + foundation admins |

Each has its own App Check debug/prod tokens, FCM keys, Secret Manager entries, and Firestore data.

### 16.2 Flutter flavors

- `dev`, `staging`, `prod` — separate bundle IDs (`com.elhaya.hayati.dev` etc.), separate Firebase options files, icons tinted differently so installs are distinguishable on one device.

### 16.3 Distribution

1. CI builds signed APK per flavor.
2. `staging` APK auto-deploys to **Firebase App Distribution** → foundation UAT testers.
3. On manual approval, `prod` APK is uploaded to **Google Play Store** (internal testing track → closed → production).
4. Foundation staff assist with Play Store installation during door-to-door visits.
5. Release notes in Arabic and English auto-generated from conventional commits.

---

## 17. Observability & SLOs

### 17.1 Client telemetry
- **Crashlytics** — every crash tagged with `villageId`, `role`, `appVersion`, `buildFlavor`.
- **Performance Monitoring** — cold start (target p95 < 3s), screen render (< 500ms), network traces on all callable Functions.
- **Analytics** — no PII. Events: `enrollment_started`, `enrollment_completed`, `qr_viewed`, `service_registered`, `report_submitted`, `phase_3_section_completed`. Custom dimensions: `villageId`, `role`.

### 17.2 Server telemetry
- **Cloud Logging** — structured JSON logs from every Function with `requestId`, `villageId`, `actorUid`, `action`, `latencyMs`.
- **Log-based metrics** — rule-denies per minute, function error rate per minute, trigger invocation count.
- **Alerts** (Cloud Monitoring):
  - Function error rate > 1% for 5min → PagerDuty (or email + SMS)
  - Firestore rule denies > 100/min → potential attack
  - Budget alerts at 50%, 80%, 100% of monthly budget
  - Any single village exceeds 100k reads/day

### 17.3 SLOs
| Metric | Target |
|---|---|
| Enrollment callable success rate | ≥ 99% |
| QR verify callable p95 latency | ≤ 2s |
| Service registration p95 latency | ≤ 3s |
| Blog feed first-paint | ≤ 1s (cached) |
| Client crash-free sessions | ≥ 99.5% |
| Function error rate | ≤ 1% |

### 17.4 Health dashboard
super_admin-only screen: enrollment per village (24h/7d/30d), service registrations, reports open/resolved, function error rate, recent audit entries.

---

## 18. Testing Strategy

### 18.1 Pyramid

| Layer | Target coverage | Tools |
|---|---|---|
| Unit (models, services, validators, utils) | ≥ 80% | `flutter_test`, `mocktail` |
| Widget (critical screens) | Key flows | `flutter_test` |
| Firestore rules | 100% of rule branches | `@firebase/rules-unit-testing` in `rules-tests/` |
| Cloud Functions unit | ≥ 80% | `jest`, `firebase-functions-test` |
| Integration (emulator) | Happy paths | `integration_test` + Firebase Emulator Suite |
| Golden (Arabic RTL rendering) | All top-level screens | `golden_toolkit` |
| E2E smoke | 1 full enrollment → QR → service → scan flow | `patrol` |

### 18.2 TDD discipline
Every new feature: write the failing test first (unit or rules), then implement, then run `flutter test` and `cd rules-tests && npm test`.

### 18.3 Pre-commit hooks
`lefthook` runs: `flutter format --set-exit-if-changed`, `flutter analyze`, `flutter test`, ARB key sync check, banned-terms grep.

---

## 19. CI/CD (GitHub Actions)

### 19.1 PR workflow (`.github/workflows/pr.yml`)
- Checkout + Flutter setup
- `flutter pub get`
- `flutter analyze --fatal-warnings`
- `flutter test --coverage`
- `cd rules-tests && npm ci && npm test`
- `cd functions && npm ci && npm test`
- `flutter build apk --flavor dev --debug`
- Coverage uploaded to CodeCov (fail if drop > 2%)

### 19.2 Staging workflow (`staging.yml`)
- Triggered on merge to `main`
- Build `staging` APK
- Deploy to Firebase App Distribution (`foundation-testers` group)
- Deploy Functions to `hayati-staging`
- Deploy rules to `hayati-staging`
- Notify Slack/email

### 19.3 Prod workflow (`prod.yml`)
- Manual trigger only
- Requires approval from `azizmansour1`
- Build `prod` APK, sign, upload to Play Store internal track
- Deploy Functions + rules to `hayati-prod`
- Create GitHub release with auto-generated changelog

### 19.4 Branch protection on `main`
- Require PR review
- Require passing CI
- Require up-to-date with `main`
- No force push
- Only `azizmansour1` may merge to `main`

---

## 20. Disaster Recovery & Data Retention

### 20.1 Backup
- **Daily scheduled Firestore export** to GCS bucket (`gs://hayati-prod-backups/`). Retention: 30 days rolling + first-of-month snapshots for 1 year.
- **Point-in-Time Recovery (PITR)** enabled on `hayati-prod` Firestore (7-day window).
- **Dual-region GCS bucket** (europe-west1 + europe-west3) for backups.

### 20.2 Restore
- Documented restore runbook in `docs/RUNBOOK.md` tested quarterly.
- Restore target: dev project first, verify data shape, then prod.

### 20.3 Data integrity checks
Daily Cloud Function `dataIntegrityCheck.js`:
- Every household has a villageId referencing an existing village.
- Every participation has valid householdId + serviceId + matching villageId.
- Every audit entry has valid actorUid.
- `services.registeredCount` matches count of participations.
- Any violation → alert + ticket.

### 20.4 Retention matrix
| Data | Retention | Action after |
|---|---|---|
| `households` (active) | Indefinite | — |
| `households` (soft-deleted) | 90 days | Cascade-delete Function |
| `participations` | 5 years | Archive to GCS |
| `reports` (blurred) | 2 years | Archive, then delete |
| `reports` original photos | NEVER STORED | — |
| `audit_log` | Indefinite | Archive to GCS yearly |
| `garbage_payments` | 7 years | Tax/accounting compliance |
| `consents` | Indefinite | — |

### 20.5 Right to erasure
`rightToErasure.js` Cloud Function (admin-triggered with step-up):
- Cascades soft-delete through household + sensitive subcollections.
- Scrubs PII from posts/reports authored by the user.
- Writes final audit entry with resident's `handshakeHash` instead of name.
- Keeps `participations` (anonymized) for foundation reporting.

---

## 21. Accessibility & Low-Literacy UX

### 21.1 Targets
- WCAG 2.1 AA minimum.
- Text scale support 1.0×–2.0×.
- Minimum touch target 48dp.
- Contrast ratio ≥ 4.5:1 on all text.
- Screen reader (TalkBack / VoiceOver) labels on every interactive element.
- No information conveyed by color alone.

### 21.2 Low-literacy accommodations
- **Audio-first blog posts** — every post supports an audio attachment (Phase 4).
- **Voice input** on enrollment form (Arabic Speech-to-Text via platform API).
- **Icon-heavy navigation** — text labels under icons, but icons are primary.
- **Pictographic forms** where possible — e.g. household size as a slider of people icons.
- **Spoken tooltips** on long-press (custom widget).
- **Simple language ARB** — Arabic translations reviewed for Fusha-vs-colloquial accessibility (use familiar colloquial).

### 21.3 RTL
- `Directionality.of(context)` respected everywhere.
- Icons that imply direction (back arrow, forward) auto-mirror.
- Phone numbers, QR IDs, and numerals stay LTR via `Directionality(textDirection: TextDirection.ltr, ...)`.
- Font: **Tajawal** bundled in `assets/fonts/`, fallback Noto Sans Arabic.

### 21.4 Verification
- `golden_toolkit` tests render every screen in Arabic RTL + English LTR.
- Manual audit on real devices with TalkBack enabled.
- Font scale 2.0× regression tests.

---

## 22. Legal, Consent & Content Moderation

### 22.1 Legal docs
- Terms of Use (Arabic + English, reviewed by Egyptian lawyer) in `docs/TERMS_AR.md` / `TERMS_EN.md`.
- Privacy Policy (Arabic + English) in `docs/PRIVACY_AR.md` / `PRIVACY_EN.md`.
- Data Processing Agreement between El Haya Foundation and Google (Firebase) on file.
- Versioned — bumping version forces re-consent on next app open.

### 22.2 Consent ledger
Every sensitive data capture, photo release, and privacy policy acceptance writes an entry to `households/{id}/consents/`. See §5.4. Append-only, revocation supported.

### 22.3 Children's data (Phase 3)
- Minimum account holder age: 18.
- Parental consent required for each child record.
- OTP-verified parental confirmation stored in the consent ledger as evidence.
- Children's data lives only in `households/{id}/sensitive/children`, behind step-up auth.
- Never shared with third parties without a new, scope-specific consent entry.

### 22.4 Content moderation
- Blog comments are **disabled** in v1 (no moderation capacity). Reconsider in v2.
- Reports can be flagged by staff; flagged reports require admin review before acting.
- Posts are admin-only (no user-generated blog content).
- Takedown of a blog post → soft-delete + audit entry + reason.

### 22.5 Photo release (Phase 4 success stories)
Publishing a photo that shows a resident's face requires:
- A consent entry in the subject's household consent ledger with scope `photo_release`.
- The photo's post document references the `consentId`.
- Revoking the consent → Function unpublishes the post.

---

## 23. Security Hardening Checklist

- [ ] **Firebase App Check** enforced on Firestore, Storage, Functions
- [ ] **Play Integrity** attestation on Android
- [ ] **DeviceCheck / App Attest** on iOS
- [ ] **Rate limiting** per-uid and per-IP on all callables (`rateLimiter.js`)
- [ ] **Trigger guard** (`skipIfUnchanged`, single-write) on every `onWrite`/`onCreate`/`onUpdate`
- [ ] **`maxInstances`** cap on every Function (default: 10)
- [ ] **Budget alerts** at $50, $100, $200/month
- [ ] **No secrets in repo** — all via Secret Manager
- [ ] **HMAC secret rotation** policy (quarterly) for QR signing
- [ ] **Custom claims only via Admin SDK** — never from client
- [ ] **Rules tests** passing on CI
- [ ] **App Check debug token** not committed
- [ ] **Storage rules** restrict bucket access per role + village
- [ ] **No `allow create: if true`** anywhere
- [ ] **Shape validation** on every rule `create`/`update`
- [ ] **Soft-delete only**, hard delete via Function audit-stamped
- [ ] **Step-up auth** verified in rules AND Functions for sensitive actions

---

## 24. Success Metrics

| Metric | Target (6 months, Abusir) |
|---|---|
| Enrolled households | 80% of village |
| Monthly active users | 50% of enrolled |
| Service event attendance | 70% of registrations |
| Blog post engagement | 40% open rate |
| Phase 3 profile completion | 60% with children data |
| Community reports (Phase 5) | 20+ / month |
| Crash-free sessions | ≥ 99.5% |
| Enrollment funnel completion | ≥ 85% |
| Function error rate | ≤ 1% |

---

## 25. Open Questions (trimmed)

1. **App name:** "Hayati" (حياتي = My Life) confirmed?
2. **Branding:** El Haya Foundation logo/color palette deliverables?
3. **SMS fallback:** For residents with spotty data, send SMS confirmations for service registrations via Twilio/Vonage? (Cost implication.)
4. **Certificate generator (Phase 6):** In-app PDF or Cloud Function? Storage cost projection?
5. **Audio hosting:** Firebase Storage or a CDN? Bandwidth from Egypt.
6. **Lawyer review:** Who reviews the Arabic Privacy Policy? Timeline before Phase 3 launch.
7. **Initial super_admin bootstrap:** Manual via Admin SDK script — who holds the key?
8. **Third-party partner onboarding:** How does a trainer or vet become a `service_provider`? KYC workflow?

---

## 26. Web Runtime (Phase W0)

The same single codebase targets Android, iOS, and **Flutter Web** (Chrome
desktop + mobile web). Web is a peer target for the enrollment flow — the
public enrollment link opens the web build if the native app is not
installed, and foundation staff can run admin screens from a laptop browser.

### 26.1 Platform-specific Firebase wiring

| Concern | Mobile (Android/iOS) | Web |
|---|---|---|
| App Check provider (debug) | Debug provider with device-specific token | `WebDebugProvider()` with `self.FIREBASE_APPCHECK_DEBUG_TOKEN = true` in `web/index.html` (set only for `localhost` and `127.0.0.1`) |
| App Check provider (release) | Play Integrity / App Attest | `ReCaptchaV3Provider(FIREBASE_WEB_APPCHECK_SITE_KEY_*)` |
| Crashlytics | `firebase_crashlytics` via `crashlytics_service_io.dart` | No-op logger via `crashlytics_service_web.dart` (Crashlytics has no web SDK) |
| QR "save" action | `share_plus` → native share sheet | `HTMLAnchorElement` download via `web` package |
| FCM | Foreground + background via OS | Service worker at `web/firebase-messaging-sw.js` (Phase 2 — placeholder today) |

Platform splits live behind `if (dart.library.js_interop)` conditional
imports — **not** `dart.library.html`, which is the deprecated DOM path
that fails under WASM. Files that currently route on platform:

- `lib/core/services/crashlytics_service.dart` → `_io.dart` / `_web.dart`
- `lib/features/qr/screens/my_qr_screen.dart` → `qr_download.dart` (no-op)
  / `qr_download_web.dart` (anchor + blob)

### 26.2 Bootstrap and zone discipline

`lib/bootstrap.dart` must call `WidgetsFlutterBinding.ensureInitialized()`
**inside** the `runZonedGuarded` block, together with every async
initializer (`FirebaseService.initialize`, `AppCheckService.activate`,
`PerformanceService.activate`, `CrashlyticsService.install`). Initializing
bindings outside the zone that later calls `runApp` produces a
`Zone mismatch` exception on web in debug mode and inconsistently-routed
`FlutterError.onError` callbacks in release. The zone's error handler
delegates to `CrashlyticsService.install()`'s returned callback so the
platform-correct implementation (Crashlytics on mobile, logger on web) is
used without conditional imports in the bootstrap file.

### 26.3 Phone OTP on web (dev): `127.0.0.1`, not `localhost`

Firebase Auth silently rejects phone verification from `localhost` on web
since mid-2024, returning `auth/invalid-app-credential` with a misleading
"reCAPTCHA token response is either invalid or expired" message. **The web
dev server must bind to `127.0.0.1`**, and `127.0.0.1` must appear in the
Firebase project's Authentication → Settings → Authorized domains list for
every environment where OTP is exercised.

The checked-in `.vscode/launch.json` enforces this:

```
--web-hostname 127.0.0.1 --web-port 5000
```

The equivalent CLI invocation:

```bash
flutter run -d chrome --web-hostname 127.0.0.1 --web-port 5000 --dart-define=FLAVOR=dev
```

Real phone numbers on web always round-trip through reCAPTCHA (Enterprise
first, v2 as fallback) — this is a Firebase Auth guarantee, not optional.
The v2 fallback uses an auto-provisioned site key whose allowed domains are
driven by the Authorized domains list. For SMS-less development, use
**Authentication → Settings → Phone numbers for testing**.

### 26.4 Hosting hardening

`firebase.json` applies security headers to the Hosting response for all
paths:

- `Content-Security-Policy` — scopes scripts to `self`, Firebase, Google
  reCAPTCHA, and gstatic font CDN; `connect-src` allows Firebase Auth,
  Firestore, Functions (`europe-west1`), Storage, App Check, Google APIs
  for reCAPTCHA; `frame-src` allows reCAPTCHA challenge.
- `Strict-Transport-Security` — `max-age=63072000; includeSubDomains; preload`.
- `X-Content-Type-Options: nosniff`.
- `Referrer-Policy: strict-origin-when-cross-origin`.
- `Permissions-Policy` — restricts camera/geolocation/microphone to `self`
  (camera is needed for QR scan; geolocation for enrollment).
- `X-Frame-Options: DENY`.

Static assets (`.js`, `.png`, fonts) receive `Cache-Control: public,
max-age=31536000, immutable`; the entrypoint `index.html` and `flutter_bootstrap.js`
are `no-cache` so new deploys are picked up immediately.

### 26.5 Web runtime — open items

- CSP `script-src` currently allows `'unsafe-inline'` for the small App Check
  debug-token bootstrap snippet in `index.html`. Migrate to a nonce or move
  the snippet out of the HTML to tighten CSP before prod Hosting enforcement.
- FCM web push (`firebase-messaging-sw.js`) is a Phase 2 placeholder — it
  installs as a service worker but does not yet register for messages. Wire
  `firebase_messaging` foreground/background handlers when Phase 2 lands.
- Performance Monitoring is active on debug web for parity with mobile;
  revisit this when we have a representative traffic sample.

---

## 27. Document Changelog

- **v2.1** — Phase W0 web runtime documented (§26): `js_interop` conditional
  imports, zone discipline in `bootstrap.dart`, `127.0.0.1` requirement for
  phone OTP on dev web, Hosting CSP + security headers, FCM SW placeholder.
- **v2.0** — Enterprise rewrite. Multi-village, 7-role RBAC, per-village phase gating, Phone OTP Day 1, App Check, signed QR, sensitive subcollections, consent ledger, append-only audit_log, observability, CI/CD, DR, a11y, legal. Supersedes v1.
- **v1.0** — Initial product spec + Section 19 security retrofit.
