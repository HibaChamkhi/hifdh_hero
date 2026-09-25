# Hifz Hero — Feature Backlog

An inventory of what the app does today, what the designs promise that it does
not do yet, and the debt sitting inside the parts that are built.

Screen numbers refer to the design exports in [`assets/ui-app/`](../assets/ui-app).
`T###` identifiers are the ones already cited in code comments and
[`README_ARCHITECTURE.md`](../README_ARCHITECTURE.md); items without one are
identified by their design screen instead of being given invented numbers.

**Coverage at a glance:** 20 of the 41 design screens are built, plus the logo
mark, the shared empty state, and a reading view the designs never specified.
Everything shipped runs offline on the bundled Quran corpus and
SharedPreferences — there is no live backend yet.

---

## 1. Shipped

### 1.1 Onboarding & session

| Feature | Screens | Entry point |
| --- | --- | --- |
| Splash + boot routing (new → onboarding, logged-out → login, else home) | 01 | `presentation/splash/pages/splash_page.dart` |
| Level + memorized-ayah capture | 02, 03 | `presentation/onboarding/` |
| Login, register, forgot-password with validation | 04, 05, 06 | `presentation/auth/` |
| Token/session persistence, logout | — | `data/auth/`, `AuthPrefUtils` |

Registration stores the display name locally, which is what the home greeting
and the profile header read.

### 1.2 Quran corpus

| Feature | Entry point |
| --- | --- |
| All 114 surahs + full text + 30 juz bundled offline (~1.5 MB) | `assets/data/`, `QuranLocalDataSource` |
| Surah list with diacritic-insensitive Arabic search (09) | `presentation/quran/` |
| **Surah reading view** — Uthmani text, basmalah handling, Arabic-Indic ayah markers, tap-to-mark-memorized | `presentation/quran/pages/surah_reader_page.dart` |
| Ayah search API (`searchAyahs`) — **no UI consumes it yet** | `QuranRepository` |

The reader has no design screen; it was added because the memorization loop had
no read step. Tapping a surah opens it, and "تدرّب" in its app bar reaches the
challenge hub that the list used to open directly.

### 1.3 Challenges

Four multiple-choice types on a shared, seedable generator:
أكمل الآية (15), أي سورة هذه؟ (16), الكلمة الناقصة (20), خمّن الجزء (23).
Flow: choose surah → hub (14) → play → result (24).
Entry point: `domain/challenges/services/question_generator.dart`,
`presentation/challenges/`.

Every question names the ayah it tests, and **answering records a review**, so
playing a challenge advances the same spaced-repetition schedule the التقدم tab
reads. An ayah the schedule has never seen is picked up the first time a
challenge asks about it. For أكمل الآية the reviewed ayah is the answer, not
the prompt.

### 1.4 Revision (spaced repetition)

| Feature | Screens | Entry point |
| --- | --- | --- |
| Leitner-box scheduler, seeded from the memorized surahs | — | `domain/revision/services/spaced_repetition.dart` |
| Today's plan + self-graded review sheet | 28 | `presentation/revision/pages/revision_plan_page.dart` |
| Weak-ayah ranking | 31 | `weak_ayahs_page.dart` |
| Review-day heatmap and streaks | 32 | `revision_history_page.dart` |

### 1.5 Memorization tracking

Memorization is stored as **ayah ranges**, not whole surahs, so a long surah can
be partly done. `domain/memorization/` owns the model (`MemorizedAyahs`, merged
and normalized on every edit); the reader marks single ayahs, the surah picker
marks whole ones, and the juz map, home percentages and revision seeding all
count real ayahs. Profiles written by earlier builds migrate on first launch —
each surah they had becomes a full-length range, so no progress is lost.

### 1.6 Progress surfaces

| Feature | Screens | Entry point |
| --- | --- | --- |
| Home: greeting, streak ring, explored-ayahs, juz journey, continue CTA | 07 | `presentation/home/` |
| Hifz map: 30 juz as a path, each with % memorized, locked until the previous completes | 08 | `presentation/map/` |
| Profile: avatar, name, level, streak/XP/surah tiles, logout | 11 | `presentation/profile/pages/profile_page.dart` |
| Edit profile: photo (gallery/camera), name, level, memorized surahs | 35, 03 | `edit_profile_page.dart` |

Every figure is derived from data the app already holds — streak from the review
log, XP at 10/review, juz percentages from the onboarding profile against the
corpus. Nothing on these screens is sample content.

### 1.7 Cross-cutting

Arabic/RTL throughout · light + dark themes defined · design-token system
(colors/dimens/text styles) · 13 shared UI widgets · 5-tab shell with icon
navigation · clean architecture (domain/data/presentation) with BLoC +
get_it/injectable · 112 tests.

---

## 2. Backlog — designed but not built

Ordered by how much each unlocks. The first three are the ones that make
existing features whole rather than adding new surface.

### P1 — completes what already ships

| # | Item | Screens | Why it matters |
| --- | --- | --- | --- |
| 1 | **Result persistence (T069–T072, T098–T101)** | 24, 30 | `ChallengeResult` is shown then discarded, so there is no history of runs and no session summary. XP now moves when you play — reviews recorded by challenges count — but the run itself isn't kept. |
| 2 | **Per-surah progress** | 09, 14 | `SurahChallengesPage` takes a `progress` argument that is never supplied with real data, and the surah list shows none. The numbers now exist — `MemorizedAyahs.countIn` — so this is just wiring. |
| 3 | **Statistics screen** | 10 | The التقدم tab opens the revision plan instead. The aggregate data already exists in `ProgressRepository`. |

### P2 — new features with data already in place

| # | Item | Screens | Notes |
| --- | --- | --- | --- |
| 5 | Ayah search UI | 12 | `QuranRepository.searchAyahs` is implemented and unused. |
| 6 | Bookmarks | 13 | Needs a small store; corpus access already exists. |
| 7 | Daily mission | 29 | Composes today's plan + a challenge; no new data. |
| 8 | Session summary | 30 | Pairs with item 2. |
| 9 | Streak badges / achievements | 25, 33 | Streak and XP already computed. |
| 10 | Settings, language, appearance | 34, 36, 37 | Dark theme exists but `themeMode` is pinned to light (`app.dart:19`); language needs item 15 first. |
| 11 | About / changelog | 40 | Static. |

### P3 — new challenge types

| # | Item | Screens | Notes |
| --- | --- | --- | --- |
| 12 | Ayah ordering (drag) | 17 | First non-MCQ type; needs its own grading path. |
| 13 | First-word / last-word | 21, 22 | Straightforward on the existing generator. |

### P4 — needs new infrastructure or a decision

| # | Item | Screens | Blocked on |
| --- | --- | --- | --- |
| 14 | Audio player, favorite reciters, downloads | 18, 38, 39 | An audio package, a recitation source, and offline storage policy. |
| 15 | Voice check | 19 | Speech recognition for Arabic — significant, and needs a quality bar decision. |
| 16 | Notifications | 27 | Local-notifications package + scheduling permissions. |
| 17 | Leaderboard | 26 | A backend and an account model; nothing local can back it. |
| 18 | Family challenge (section of the profile design) | 11 | **Deliberately omitted when profile was built** — there is no social/family data anywhere, so it would be invented numbers. Needs a product decision before UI. |
| 19 | AI coach | 41 | Model choice, cost, and offline behaviour all undecided. |

---

## 3. Debt in shipped features

| Item | Where | Impact |
| --- | --- | --- |
| **Mock auth is on** (`useMockAuth = true`) | `core/config/app_config.dart:12` | Any credentials succeed and a fake token is stored. The real network path exists behind the flag but is unexercised. |
| **No API base URL / environment setup (T007)** | `app_config.dart` | Pairs with the above. |
| **No localization (T115/T116)** | `core/constants/app_strings.dart` | Arabic strings are a hard-coded table; no ARB/gen-l10n, so screen 36 cannot be built as designed. |
| **Hand-written DI config** | `core/di/injection.config.dart` | Every new `@injectable` must be wired by hand or `build_runner` re-run. Easy to forget. |
| **Scaffold body loose-width trap** | several pages | `Scaffold` hands its body loose width constraints, so a `Column` that is not `stretch` shrink-wraps and hugs an edge. Already bit splash, empty states and the result screen. Worth a lint or a shared page wrapper. |
| **Photo flow unverified on device** | `edit_profile_page.dart` | `image_picker` and the iOS permission prompts have never run on hardware — the emulator has been out of disk space. |

---

## 4. Test coverage

112 tests. Covered: spaced-repetition scheduling, question generation, Quran
data, auth blocs, onboarding logic, progress derivation, profile editing, the surah reader and ayah marking, the ayah-range model and its migration, the challenge→revision link, font bundling, RTL
alignment, splash/nav layout, and page-overflow regressions.

Not covered: navigation flows end to end, the real network path in
`AuthRemoteDataSource`, and anything requiring a device (photo picking).
