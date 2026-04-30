# PPOS - Flutter POS System

A Flutter Point of Sale (POS) application built with Clean Architecture, BLoC pattern, Floor database, and GetIt dependency injection.

## Offline-first & Firebase

- **Local source of truth**: Data lives in **SQLite** (Floor). Repositories use SQLite implementations by default.
- **Firebase**: **Firebase Auth** signs users in. **Firestore** syncs products through `ProductSyncService` and `SyncManager` (pull remote + push dirty rows). Sync runs after login, when the app returns to the foreground (if logged in), and from the POS drawer (“ซิงก์ข้อมูล”).
- **Toggle**: In `lib/core/config/app_data_source.dart`, `AppConfig.dataSource` is `AppDataSource.sqlite` (recommended). Set `AppDataSource.firebase` only if you need repositories to talk to Firestore directly (legacy/demo), without the offline-first SQLite path.

See `docs/firebase_setup_todo.md` and `docs/firebase_design.md` for Firebase setup.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with the following layers:

- **Presentation Layer**: UI components, BLoC state management
- **Domain Layer**: Business logic, entities, use cases, repository interfaces
- **Data Layer**: Data sources, models, repository implementations

## 🛠️ Tech Stack

- **Flutter**: UI framework
- **BLoC**: State management (`flutter_bloc`)
- **Floor**: Local database (SQLite)
- **GetIt**: Dependency injection
- **Injectable**: Code generation for DI
- **Dartz**: Functional programming utilities
- **Equatable**: Value equality
- **JSON Serialization**: Data model serialization

## 📁 Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── error/             # Error handling (Failures)
│   ├── usecase/           # Base UseCase interface
│   ├── utils/             # Constants and utilities
│   └── di/                # Dependency injection
│
├── features/               # Feature modules
│   ├── sales/             # Sales feature
│   │   ├── data/          # Data layer
│   │   ├── domain/        # Domain layer
│   │   └── presentation/  # UI layer
│   ├── members/           # Members feature
│   ├── stock/             # Stock feature
│   ├── payment/           # Payment feature
│   └── loyalty/           # Loyalty feature
│
└── database/              # Database configuration
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.2.0)
- Dart SDK (>=3.2.0)

### Installation

1. Clone the repository
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Generate code (required for first run):

   ```bash
   flutter packages pub run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## 🔧 Code Generation

This project uses code generation for:

- **Injectable**: Dependency injection configuration
- **Floor**: Database entities and DAOs
- **JSON Serialization**: Model serialization

After making changes to annotated classes, run:

```bash
flutter packages pub run build_runner build
```

Or for continuous generation:

```bash
flutter packages pub run build_runner watch
```

## 📱 Features

### Sales Management

- View sales list
- Create new sales
- Update existing sales
- Delete sales

### Clean Architecture Benefits

- **Separation of Concerns**: Clear boundaries between layers
- **Testability**: Easy to unit test business logic
- **Maintainability**: Code is organized and easy to understand
- **Scalability**: Easy to add new features

## 🧪 Testing

The project is structured to support:

- Unit tests for use cases and business logic
- Repository tests for data layer
- BLoC tests for state management
- Widget tests for UI components

## 📚 Dependencies

### Core Dependencies

- `flutter_bloc`: State management
- `get_it`: Dependency injection
- `floor`: Local database
- `dartz`: Functional programming

### Development Dependencies

- `build_runner`: Code generation
- `injectable_generator`: DI code generation
- `floor_generator`: Database code generation

## 🤝 Contributing

1. Follow Clean Architecture principles
2. Use BLoC for state management
3. Implement proper error handling
4. Write tests for new features
5. Follow the existing code structure

## 📄 License

This project is private and proprietary to DoHome.

## 🆘 Support

For questions or issues, please contact the development team.
