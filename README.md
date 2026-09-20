# Lizquet

Lizquet is a Flutter flashcard learning app inspired by Quizlet — users create decks of vocabulary cards and study them through several game-like modes, with progress synced to Firebase.

## Features

- **Authentication** — Email/password sign up & login via Firebase Authentication, with persistent sessions.
- **Deck & Flashcard management** — Create, edit, and organize decks of flashcards; group decks into folders.
- **Multiple study modes**
  - **Flashcard** — Classic flip-card review.
  - **Learn** — Adaptive, question-based learning flow.
  - **Test** — Auto-generated quizzes to check mastery.
  - **Match** — Timed matching game pairing terms with definitions.
  - **Flappy** — A Flappy-Bird-style mini game (built with the [Flame](https://flame-engine.org) engine) that quizzes vocabulary while you play.
- **Explore** — Browse curated vocabulary decks by CEFR level (A1–C2).
- **Study groups** — Create/join groups to share decks and learn together.
- **Streaks & progress tracking** — Daily study streaks with celebration animations, plus learning progress overview on the profile screen.
- **Personalization** — Light/dark theme support and an account/app settings screen.

## Tech Stack

- **Framework:** Flutter (Dart)
- **State management:** Riverpod (`flutter_riverpod`, code-gen via `riverpod_generator`)
- **Navigation:** `go_router`
- **Backend:** Firebase (Authentication, Cloud Firestore)
- **Game engine:** Flame (for the Flappy study mode)
- **Other:** Lottie animations, cached network images, shared_preferences for local caching

## Project Structure

The app follows a feature-first architecture:

```
lib/
├── features/
│   ├── auth/         # Sign up, login, session management
│   ├── deck/          # Deck CRUD
│   ├── card/          # Flashcard model & CRUD
│   ├── folder/        # Folder organization
│   ├── group/          # Study groups
│   ├── explore/       # CEFR-level vocabulary browsing
│   ├── study/          # Study modes: flashcard, learn, test, match, flappy
│   ├── library/        # User's saved decks/folders
│   ├── home/           # Home dashboard
│   ├── profile/        # Profile, streaks, progress
│   └── settings/       # App & account settings
└── shared/              # Shared widgets/utilities used across features
```

## Getting Started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (SDK >= 3.0.0).
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Set up a Firebase project and generate your own `lib/firebase_options.dart` via `flutterfire configure`.
4. Run the app:
   ```bash
   flutter run
   ```

## Testing

```bash
flutter test
```

## About This Project

Lizquet was built as a personal/academic project to practice Flutter app architecture (feature-first structure, Riverpod state management), Firebase integration, and building an interactive learning game with the Flame engine.
