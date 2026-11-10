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
- [ ] Exercise library
- [ ] Workout logging
- [ ] Workout history and personal records
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
 