# Masarefy 💸

A private, offline expense & budget planner for your month — with a dark,
neon-glow UI and no login of any kind. Everything is stored only on your
device.

## Features

- Set a **monthly budget**, watched live on an animated neon progress ring.
- Your month is automatically split into **weeks**, and weeks into **days**
  — drill down: Month → Week → Day.
- Create a **spending plan per week** (defaults to an even split of the
  monthly budget, fully editable).
- Log expenses with a **title**, **amount**, **date**, and an optional
  **description**; edit or swipe-to-delete any time.
- **No login, no account, no server** — data lives entirely on your phone
  via local storage (Hive).
- Dark theme with a neon-glow visual style and animated transitions
  throughout (see [`docs/design_pattern.md`](docs/design_pattern.md) for
  exactly where each animation lives).

## Architecture

Masarefy follows **MVVM + Repository**, using `provider` for state and
`hive` for on-device storage. Full rationale and a diagram are in
[`docs/design_pattern.md`](docs/design_pattern.md) — start there if you're
new to the codebase.

```
lib/
├── main.dart / app.dart      # Entry point, Hive setup, MaterialApp
├── core/                     # Theme, date/currency helpers, constants
├── models/                   # BillingItem, MonthlyBudget, WeekPlan
├── data/repositories/        # Hive-backed CRUD, the only Hive-aware code
├── viewmodels/                # ChangeNotifier state for screens
├── screens/                  # home, week, day, item_form, budget
└── widgets/                  # NeonCard, BudgetRing, AnimatedListItem, ...
```

## Getting started

This repository ships the app's Dart source (`lib/`), `pubspec.yaml`, and
tests — **not** the generated native platform folders (`android/`, `ios/`,
etc.), since those are produced by your local Flutter SDK and shouldn't be
hand-maintained in source control review. Generate them once with:

```bash
cd masarefy
flutter create .        # adds android/, ios/ (and any other platforms) —
                         # safe to run even though lib/ and pubspec.yaml
                         # already exist; it will not overwrite your code
flutter pub get
flutter run              # or: flutter run -d chrome / -d windows, etc.
```

Run the tests:

```bash
flutter test
```

## Project status

Built as a first version covering the full spec: budgets, weekly plans,
Month/Week/Day drill-down, and full CRUD on expense items. See
[`docs/build_log.pdf`](docs/build_log.pdf) for a complete, step-by-step
record of how this project was created.
