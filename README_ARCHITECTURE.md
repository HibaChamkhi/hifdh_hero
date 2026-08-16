# Hifz Hero — Foundation (Sprint 1)

This package is the **foundation layer** for the Hifz Hero app, built to mirror the
Clean Architecture used in `starterflutter-develop` (BLoC + get_it/injectable +
`dartz` Either + `flutter_screenutil`), with the Hifz Hero design system, full
Arabic/RTL support, and one feature implemented end-to-end as a template.

> Package name is **`hifdh_hero`** to match your existing project
> (`com.example.hifdh_hero`). Imports are `package:hifdh_hero/...`.

---

## How to use this in your project

You already have a Flutter project at `hifdh_hero/` with the Android/iOS/etc.
platform folders. This package contains the parts that change:

1. Copy `lib/` and `test/` into your project root (replacing the default `lib/`).
2. Replace `pubspec.yaml` and `analysis_options.yaml` (or merge the deps).
3. Add the fonts (see **Fonts** below), then:

```bash
flutter pub get
# regenerate DI (optional — a hand-written injection.config.dart is included):
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

> ⚠️ `flutter analyze` was **not** run in the build environment (no Flutter SDK
> there). Run it once locally; the code was written to the starter's conventions
> and reviewed by hand, but do a `flutter pub get && flutter analyze` pass first.

---

## Architecture (identical layering to the starter)

```
lib/
├── main.dart                    # ScreenUtilInit + configureDependencies()
├── app.dart                     # MaterialApp: theme, RTL/Arabic locale, router
├── core/                        # shared, feature-agnostic
│   ├── di/                      # get_it + injectable (injection.dart/.config.dart/core_module)
│   ├── error/                   # exceptions + performNetworkRequest / mapExceptionToMessage
│   ├── network/                 # NetworkInfo (connectivity)
│   ├── interceptor/             # AuthenticatedHttpClient + HttpInterceptor
│   ├── input_validation/        # validateEmail / validatePassword / validateField
│   ├── model/                   # UIState<T> base state (starter's `model ` folder, space removed)
│   ├── constants/               # AppStrings (Arabic string table)
│   ├── router/                  # AppRoutes + AppRouter (onGenerateRoute)
│   └── ui/
│       ├── styles/              # colors, dimens, text_styles, theme (light+dark)
│       └── widgets/             # PrimaryButton, AppCard, AppProgressBar, SectionHeader, ChoiceChipTag
├── domain/<feature>/            # models + abstract repositories (no Flutter deps)
├── data/<feature>/              # data_sources (local/remote) + repository impls
└── presentation/<feature>/      # bloc (event/state part files) + pages + widgets
```

**Per-feature pattern** (copy this for every new feature):

```
domain/<f>/models/…                 domain/<f>/repositories/<f>_repository.dart   (abstract)
data/<f>/data_sources/local|remote  data/<f>/repositories/<f>_repository_imp.dart (@Injectable(as: …))
presentation/<f>/bloc/<f>_bloc.dart (+ _event.dart / _state.dart part files)
presentation/<f>/pages/…            presentation/<f>/widgets/…
```

BLoC states extend `UIState<T>` (`status`: initial/loading/success/error, `message`, `data`);
pages use `BlocProvider(create: (_) => getIt<XBloc>())` + `BlocConsumer`.

---

## What's implemented in this foundation

| Backlog | Item | Status |
|--------|------|--------|
| T001–T004 | Project, clean architecture, BLoC, routing | ✅ scaffolded |
| T005 | Design system (colors/type/spacing/theme) | ✅ from screenshots |
| T006 | RTL / Arabic (locale ar, delegates) | ✅ |
| T008 | Git (.gitignore) | ✅ |
| Core | error/network/interceptor/validation/ui_state | ✅ ported |
| T018–T019 | Splash + routing decision | ✅ |
| T020–T022 | Onboarding (level + memorized surahs) **end-to-end** | ✅ template feature |
| T023–T031 | Auth data/domain layer | ✅ stubbed (UI pages pending) |
| T032 | 5-tab bottom-nav shell | ✅ (السور tab wired to Quran) |
| **T009–T017** | **Quran data (verified text, metadata, juz)** | ✅ **Sprint 2** |
| T037–T038 | Choose-Surah list + search | ✅ screen 09 |
| **T046–T057, T062–T072** | **Challenge engine + 4 MCQ types + result** | ✅ **Sprint 3** |
| **T023–T031** | **Auth UI (login/register/forgot) + session** | ✅ **Sprint 4** |
| **T084–T092** | **Revision (spaced repetition, weak ayahs, history)** | ✅ **Sprint 5** |

The **onboarding feature is the reference implementation** — domain model +
local data source + repository + BLoC + page + widget — so every remaining
feature in the backlog can be built by copying its shape.

---

## Design system (sampled from `screenshots 2/`)

| Role | Hex |
|------|-----|
| Primary (Hifz green) | `#5C947C` |
| Deep green (text on mint) | `#226249` |
| Mint surface | `#D9EEE4` |
| Cream background | `#FEFDFB` |
| Card surface | `#F6F5F1` |
| Terracotta accent | `#B47A54` |
| Peach surface | `#FDE6DA` |
| Danger | `#C0433B` |

All in `core/ui/styles/colors.dart`. Never hard-code hex in screens — reference `AppColors`.

---

## Fonts / Typography

- **Poppins** (bundled, Latin numerals/labels) — copy the 4 `.ttf` files referenced
  in `pubspec.yaml` into `assets/fonts/poppins/` (they're in the starter's
  `assets/fonts/poppins/`).
- **Arabic UI font** — the mockups use a geometric Arabic face. Bundle
  **Tajawal** or **Cairo** into `assets/fonts/`, register it, and set
  `AppTextStyles.uiFont = 'Tajawal'`. Until then it falls back to the platform
  Arabic font (still renders correctly RTL).
- **Quran font** — bundle **Amiri Quran** (or `KFGQPC Uthmanic`) for ayah text and
  set `AppTextStyles.quranFont`. Ayah rendering (`AppTextStyles.ayah`) is ready.

---

## Sprint 2 — Quran data (done)

`domain/quran` (Surah, Ayah, Juz, RevelationType, AyahSearchResult) +
`data/quran` (local data source reading `assets/data/*.json`, repository impl) +
`QuranBloc` + the **اختر السورة** screen (search over all 114 surahs, wired into
the السور tab). Verified corpus bundled in `assets/data/` — see
`assets/data/DATA_SOURCE.md` for provenance and integrity checks. Diacritic-
insensitive Arabic search lives in `core/utils/arabic_text.dart`.

> The full text (~1.5 MB) is loaded and cached lazily by the singleton
> `QuranLocalDataSource`. For very large lists consider per-surah asset files
> later; fine as-is for now.

## Sprint 3 — Challenge engine (done)

`domain/challenges` (ChallengeType, ChallengeQuestion, ChallengeResult +
`QuestionGenerator` service), `data/challenges` (ChallengeRepository bridging
`QuranRepository` + generator), `ChallengeBloc`, and three screens:
**تحديات السورة** hub (screen 14) → MCQ play (screens 15/16/20/23) →
**أحسنت!** result (screen 24). Flow: Choose-Surah → hub → play → result.

Four working challenge types, all multiple-choice so grading is uniform:
- **أكمل الآية** (complete-the-ayah) — pick the true next ayah
- **أي سورة هذه؟** (find-the-surah) — identify the surah from an ayah
- **الكلمة الناقصة** (missing-word) — fill the blank
- **خمّن الجزء** (guess-the-juz) — identify the juz from an ayah

`QuestionGenerator` is a pure, seedable (`Random`) domain service — see
`test/challenge_generator_test.dart` (verifies every generated question is
valid, guess-juz maps to the true juz, complete-ayah answer is the real next
ayah). Not yet implemented: drag-order (رتّب الآية), free-text/voice, and
per-question reveal — straightforward to add on this engine.

## Sprint 4 — Auth UI (done)

`presentation/auth` — **login** (screen 04), **register** (screen 05), and
**forgot-password** (screen 06) pages with `LoginBloc`/`RegisterBloc`/
`ForgotPasswordBloc`, form validation (`core/input_validation`), a shared
`AuthTextField` + `AuthLogo`, and inter-page links. Boot flow is now
**splash → onboarding (if new) → register/login → home**; splash routes on
`AuthRepository.isLoggedIn`.

`core/config/app_config.dart` has `useMockAuth` (default **true**) so
login/register/forgot succeed offline for demo. Set it to `false` and point
`apiBaseUrl` at a real backend — the real network path in `AuthRemoteDataSource`
(via `performNetworkRequest`) then takes over, storing tokens through
`AuthPrefUtils`. `test/auth_bloc_test.dart` covers the loading→success and
loading→error transitions with a fake repository.

## Sprint 5 — Revision system (done)

`domain/revision` (AyahReviewState, RevisionPlan, RevisionItem, RevisionHistory
+ `SpacedRepetition` — a pure Leitner-box scheduler), `data/revision`
(SharedPreferences persistence + `RevisionRepository` that seeds from the
onboarding memorized surahs, ranks weak/due ayahs, records reviews, computes
streaks), `RevisionBloc`, and three screens wired into the **التقدم** tab:
**المراجعة الذكية** plan (screen 28) → **الآيات الضعيفة** (screen 31) →
**سجل المراجعة** heatmap (screen 32). Reviews are self-graded via a bottom sheet
(أتقنتها / لم أتقنها) that shows the real ayah text and updates the box +
schedule + day-log. `test/spaced_repetition_test.dart` covers promotion,
demotion, lapses, and box bounds. `core/utils/day.dart` handles epoch-day math.

## Suggested next slices (in backlog order)

1. **Challenge ↔ revision integration (T092)** — carry surah/ayah numbers on
   `ChallengeQuestion` and call `recordReview` per answered question so playing
   challenges feeds the spaced-repetition schedule automatically.
2. **Home dashboard (T033–T034)** — wire streak, XP, and juz progress to real
   data; then the remaining shell tabs (الرئيسية, الخريطة).
3. **Result persistence + XP/streak (T069–T072, T098–T101)**.
4. **Profile & Settings (T112–T118)** — edit profile, language, theme (screens
   34–37); logout wiring lands here.

Each is a self-contained feature folder; tell me which to build next and I'll
follow this exact pattern.
