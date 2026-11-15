# Myfitness Journal

A personal fitness tracking application built with Flutter to track workouts, nutrition, body weight, and overall fitness progress.

## Overview

Myfitness Journal aims to provide a simple and organized way to maintain a personal fitness journal, monitor training progress, and track nutrition.

The application is being developed with a focus on clean architecture, maintainable code, local data persistence, and an intuitive user experience.

## Features

### Workout Tracking
- Log workouts and exercises
- Track sets, repetitions, and weights
- View workout history
- Track previous exercise performance
- Monitor personal records

### Nutrition Tracking
- Log daily meals
- Track calories and macronutrients
- Monitor daily protein intake
- Maintain food and meal history

### Body Weight & Progress
- Record body weight
- View weight history
- Track fitness progress through charts
- Monitor workout statistics

### Dashboard
- View weekly workout activity
- Track daily nutrition summaries
- Monitor body weight trends
- Access frequently used features quickly

## Tech Stack

- **Flutter** – Cross-platform application development
- **Dart** – Programming language
- **Shared Preferences / Local Storage** – Local persistence
- **Supabase** – Planned authentication and cloud synchronization
- **Git & GitHub** – Version control and collaboration

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android SDK (for Android development)

### Installation

Clone the repository:

```bash
git clone git@github.com:UDITH-SUDHAKAR/myfitness-journal..git
```

Navigate to the project directory:

```bash
cd myfitness-journal.
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Development

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Google Sign-In and local account storage

Authentication is optional. Build with Supabase settings to enable Google
Sign-In; without them, users can choose **Continue Offline** and keep using
the original device-only Isar database.

Pass the project URL, client-side publishable key, and Google Web OAuth client
ID at build time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

The Supabase publishable key is intended for client applications. Never put a
Supabase service-role or secret key in the Flutter app. Do not commit real
project configuration or OAuth secrets to source control.

### Supabase and Google Cloud setup

1. In Google Cloud Console, configure the OAuth consent screen and create an
   Android OAuth client using the Android application ID
   `com.example.myfitness_journal` and the SHA-1 signing certificate
   fingerprint(s) for each build type you use (debug, local release, and store
   signing as applicable).
2. Create a Google **Web application** OAuth client. Add the callback URL shown
   on the Supabase Google provider page to that client's authorized redirect
   URIs. Enable Google under Supabase Authentication → Sign In / Providers,
   enter the Web client ID and client secret, and register the Android client ID
   in the provider's client ID list. The client secret stays in Supabase; the
   Flutter app only needs the Web client ID.
3. Supply the Supabase project URL and publishable key, plus that Web client ID,
   to Flutter using the `--dart-define` values above.
4. Android internet permission is declared in the app manifest. Native Google
   ID-token sign-in exchanges credentials with Supabase and does not require a
   browser redirect or app deep-link callback.

On restart, Supabase restores its persisted session. Signing out clears that
Supabase session on this device and returns to the authentication screen. The
existing offline database is retained; each authenticated Supabase user ID
opens a separate local Isar database. Existing offline entries are not copied
into an account database, and no cloud backup or synchronization is performed.

## Project Structure

```text
lib/
├── main.dart
├── app/
├── features/
│   ├── dashboard/
│   ├── workouts/
│   ├── nutrition/
│   └── progress/
└── core/
    ├── models/
    ├── storage/
    └── widgets/
```

## Roadmap

- [ ] Workout data models
- [ ] Local data persistence
- [x] Exercise library
- [ ] Workout logging
- [x] Workout history
- [x] Personal records
- [ ] Dashboard improvements
- [ ] Nutrition tracking
- [ ] Body weight tracking
- [ ] Progress charts
- [ ] Supabase authentication
- [ ] Cloud synchronization
- [ ] Automated testing

Feature development is tracked through [GitHub Issues](https://github.com/UDITH-SUDHAKAR/myfitness-journal./issues).

## Contributing

This project follows an issue-driven development workflow:

1. Create or select a GitHub Issue.
2. Create a feature branch.
3. Implement the feature.
4. Run analysis and tests.
5. Submit a Pull Request.
6. Review and merge the changes.

## License

License to be determined.
