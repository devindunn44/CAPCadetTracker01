# CAP Cadet Progress Tracker

A Flutter app that tracks Civil Air Patrol cadet promotions against the requirements in the
**Cadet Super Chart (CAP VA 60-100, May 2025)** and the Personal Cadet Tracker (VA 60-101a/b).

## Purpose

Cadets and cadet staff can see, at a glance, what stands between a cadet and their next
achievement: tests, drill, aerospace, fitness (Healthy Fitness Zone), character activities,
special requirements, and time in grade (TIG).

## Features

- Full 21-step promotion ladder (Achievement 1 through the Spaatz Award)
- Promotion engine that checks leadership, aerospace, drill, HFZ, activities, special requirements and TIG
- HFZ calculated from age/sex standards (PACER or mile **plus** 2 of 3 of curl-ups, push-ups, sit & reach), valid 180 days
- **CAP mode** (8-week TIG) and **JROTC mode** (4-week TIG), switchable in Settings and persisted
- Dashboard with progress bars, TIG countdown, and an "Eligible" badge
- Cadet detail screen: tap-to-update requirement checklist, TIG countdown, HFZ breakdown, activity log, one-tap promotion
- Local persistence with `shared_preferences`; Riverpod state management
- Sample data (3 cadets) seeded on first launch

## Screenshots

| Dashboard | Cadet detail | Settings |
|-----------|--------------|----------|
| _screenshots/dashboard.png_ | _screenshots/detail.png_ | _screenshots/settings.png_ |

## Build and run

```bash
# 1. Generate platform folders (android/, ios/, web/ ...) in this directory
flutter create --project-name cap_cadet_progress_tracker .

# 2. Fetch packages
flutter pub get

# 3. Run tests
flutter test

# 4. Launch
flutter run
```

Requires Flutter 3.22+ (Dart 3).

## Project structure

```
lib/
  main.dart                    app entry, opens SharedPreferences
  app.dart                     MaterialApp + theme
  models/                      Cadet, Achievement, FitnessStandards, AppSettings, Activity, catalog
  services/                    PromotionEngine, SettingsService, CadetService, providers, sample data
  screens/                     Dashboard, CadetDetail, Settings
  widgets/                     ProgressBar, RequirementTile
assets/icons/
test/promotion_engine_test.dart
```

## Customizing TIG

- **Toggle at runtime:** Settings > JROTC Mode (8 weeks off, 4 weeks on). The `promotionEngineProvider`
  watches the settings provider, so every screen updates instantly.
- **Change the defaults:** edit `AppSettings.capTigWeeks` / `AppSettings.jrotcTigWeeks` in
  `lib/models/app_settings.dart`.
- **Per-achievement TIG:** each `Achievement` has a `tigWeeks` field (default 8). Achievement 1 uses the
  3-week trial period. In JROTC mode the engine uses `min(tigWeeks, jrotcTigWeeks)`; see
  `PromotionEngine.tigWeeksFor`.

## Adding or editing achievements

Open `lib/models/achievement_catalog.dart` and add an `Achievement` to `capAchievements`:

```dart
Achievement(
  number: 22,                      // next sequential step
  name: 'Achievement 17',
  rank: 'C/Col',
  leadership: 'L2L Ch. 17 test',   // null = no requirement
  aerospace: null,
  drill: null,
  hfzRequired: true,               // HFZ within 180 days
  requiredFitnessActivities: 1,
  requiredCharacterActivities: 1,
  special: null,                   // e.g. 'Graduate from Encampment'
  tigWeeks: 8,
),
```

Completed tests are stored per cadet, keyed by `Achievement.number`, so numbers must be unique and sequential.

## Data notes

- `Cadet.currentAchievement` is the `number` of the last achievement earned (0 = none).
- `Cadet.tigStart` is the last promotion's effective date; activities count toward the next promotion only if dated on/after it.
- Requirements come from the May 2025 Super Chart. Always verify against CAPR 60-1 for official promotion decisions (e.g. accelerated promotions are not modeled).
