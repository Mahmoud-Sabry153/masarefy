# Masarefy — Architecture & Design Pattern

This document explains **why** the codebase is organized the way it is, not
just what's in each folder. It's the single source of truth referenced from
comments throughout `lib/`.

## The pattern: MVVM + Repository, wired with Provider

Masarefy uses **MVVM (Model-View-ViewModel)** for its screens, with a thin
**Repository** layer underneath the ViewModels for persistence. State is
exposed to the widget tree using the `provider` package, which is Google's
own recommended lightweight state-management approach for Flutter.

```
┌──────────────┐      watches / calls methods on      ┌────────────────────┐
│  View         │ ───────────────────────────────────▶ │  ViewModel          │
│  (Screens &   │                                       │  (ChangeNotifier)   │
│   Widgets)    │ ◀─────────────────────────────────── │  BillingViewModel,   │
└──────────────┘      notifyListeners() → rebuild       │  BudgetViewModel     │
                                                          └─────────┬──────────┘
                                                                    │ uses
                                                                    ▼
                                                          ┌────────────────────┐
                                                          │  Repository         │
                                                          │  BillingRepository, │
                                                          │  BudgetRepository   │
                                                          └─────────┬──────────┘
                                                                    │ reads/writes
                                                                    ▼
                                                          ┌────────────────────┐
                                                          │  Hive boxes          │
                                                          │  (on-device storage) │
                                                          └────────────────────┘
                                                                    ▲
                                                          ┌─────────┴──────────┐
                                                          │  Model               │
                                                          │  BillingItem,        │
                                                          │  MonthlyBudget,      │
                                                          │  WeekPlan            │
                                                          └────────────────────┘
```

### Why this layering, specifically

- **Model** (`lib/models/`) — plain data classes that also know how to
  serialize themselves to Hive (via a `TypeAdapter`). They have zero
  knowledge of the UI or of `provider`.
- **Repository** (`lib/data/repositories/`) — the *only* code that imports
  `package:hive`. If Masarefy ever needed to swap local storage for
  something else (SQLite, a future sync backend, etc.), only these two
  files would change — screens and ViewModels wouldn't notice.
- **ViewModel** (`lib/viewmodels/`) — a `ChangeNotifier` per feature area
  (billing items, budget/plans). Holds UI-ready state (sorted lists,
  computed totals) and calls `notifyListeners()` after every mutation so
  every widget watching it rebuilds automatically. This is where
  "business logic" like "what's the total spent this week" lives — it's
  unit-testable without spinning up any widgets.
- **View** (`lib/screens/`, `lib/widgets/`) — purely declarative. A screen
  calls `context.watch<BillingViewModel>()` to read state and rebuild on
  change, and `context.read<BillingViewModel>().addItem(...)` to trigger
  an action. Screens never import Hive and never contain persistence
  logic.

### Why Provider (over Riverpod / BLoC)

`provider` was chosen because:

1. It's the state-management approach Flutter's own documentation
   recommends for apps of this size.
2. It requires the least boilerplate per feature — a `ChangeNotifier`
   class and one `ChangeNotifierProvider` line — which keeps the "design
   pattern" easy to read end-to-end for someone new to the codebase.
3. `context.watch` / `context.read` map directly onto "View reacts to
   ViewModel" and "View calls ViewModel", which is exactly MVVM's
   contract — there's no extra indirection (streams, events) to explain.

### Why Hive (over sqflite/SQLite)

- No SQL, no schema migrations for a data shape this simple (three small
  record types, no relational queries needed).
- Pure Dart, no native platform code — works identically on every Flutter
  target.
- Fast enough that reads never need to be `async` from the ViewModel's
  perspective once a box is open (`main.dart` opens every box before
  `runApp`, so no screen ever needs a loading spinner just to read data).
- Adapters are written by hand in this project (see the doc-comment atop
  `lib/models/billing_item.dart`) instead of generated by `build_runner`,
  specifically so the project runs with nothing more than
  `flutter pub get` — no extra code-generation step.

## Folder-by-folder map

```
lib/
├── main.dart                 # Hive setup, then runApp(MasarefyApp())
├── app.dart                  # MultiProvider + MaterialApp + AppTheme
├── core/
│   ├── theme/                # Dark neon ThemeData, color palette, glow shadows
│   ├── utils/                # Pure functions: date math, currency formatting
│   └── constants/            # Hive box names & typeIds (single source of truth)
├── models/                   # BillingItem, MonthlyBudget, WeekPlan (+ adapters)
├── data/repositories/        # BillingRepository, BudgetRepository
├── viewmodels/               # BillingViewModel, BudgetViewModel (ChangeNotifier)
├── screens/                  # One folder per screen: home, week, day, item_form, budget
└── widgets/                  # Shared "neon" building blocks (NeonCard, BudgetRing, ...)
```

## The Month → Week → Day hierarchy

This is pure date math, not stored data: `DateHelper.weeksInMonth(month)`
(in `lib/core/utils/date_helper.dart`) computes Monday-start calendar weeks
for any month, clipped to that month's actual days (so the first/last week
of a month can be shorter than 7 days). `HomeScreen` shows the weeks of the
current month; `WeekScreen` shows the days of one week; `DayScreen` shows
the billing items logged on one day. Only the *billing items, budgets and
week plans* are persisted — the calendar structure itself is always
recomputed from `DateTime`, so it's correct for any month without needing
its own storage or migrations.

## Where the animations live

- `widgets/neon_card.dart` — every glowing card "powers on" (fades/grows
  its glow in) on first build via `TweenAnimationBuilder`.
- `widgets/animated_list_item.dart` — staggers each list item's entrance
  (fade + slide-up) by a small delay per index, used on Home/Week/Day
  lists.
- `widgets/budget_ring.dart` — the budget-vs-spent ring animates its fill
  from its previous value to its new one on every change, via an explicit
  `AnimationController`, and switches color into the danger neon color
  once spending exceeds budget.
- `screens/home/widgets/month_header.dart` — the month label cross-fades
  and slides when switching months (`AnimatedSwitcher`).
- `screens/item_form/item_form_screen.dart` — the whole form fades/slides
  in on open (`AnimatedOpacity` + `AnimatedSlide`).
- `screens/splash/splash_screen.dart` — the launch animation; see its own
  section below.

## App icon

`assets/icon/icon.png` and `assets/icon/icon_foreground.png` are the two
master images: the same glowing cyan-to-purple "M" mark with a pink coin
resting in its valley, at 1024×1024. `icon.png` is full-bleed (used for
iOS and legacy Android icons); `icon_foreground.png` is the mark alone on
a transparent background, sized to fit Android's adaptive-icon safe zone,
paired with the `adaptive_icon_background` color in `pubspec.yaml` so the
OS can mask/animate it per-launcher.

These are turned into every actual platform icon file by the
`flutter_launcher_icons` dev dependency — run once after `flutter pub get`:

```bash
dart run flutter_launcher_icons
```

This writes the real Android `mipmap-*` and `ic_launcher` files and the
iOS `AppIcon.appiconset`, so nothing about the icon needs hand-editing
per platform.

## Splash screen

`screens/splash/splash_screen.dart` is shown first (see `app.dart`) purely
for a branded launch animation — by the time it builds, `main.dart` has
already finished opening every Hive box, so it's not gating on any real
loading state. It plays, in order: the M mark drawing itself in neon
stroke-by-stroke (via `Path.computeMetrics()` + `extractPath`, animated by
an `AnimationController`), a coin dropping into the mark's valley with a
little overshoot (`Curves.elasticOut`), the "MASAREFY" wordmark fading up,
and a continuous slow glow "breathe" for as long as the splash holds —
then a fade transition into `HomeScreen`.

The mark is drawn live with a `CustomPainter` (`_MLogoPainter`) using the
exact same proportions as the app icon, rather than embedding an image —
so the icon you tap and the animation that greets you feel like one
continuous piece of motion, at any screen density, with zero extra image
assets.

## No login, no server — by design

There is no authentication screen, no network client, and no user account
model anywhere in this codebase. `main.dart` opens local Hive boxes and
then shows `SplashScreen`, which hands off to `HomeScreen`. This matches
the app's requirement: a private, single-user tool that stores everything
only on the device it runs on.
