# Social Connect Hub

<div align="center">

<img src="generated-icon.png" width="100" height="100" alt="Social Connect Hub App Icon">

Social Connect Hub is a sophisticated Flutter-powered social communication platform that combines intelligent networking with rich media sharing and dynamic user interactions.

[![Provider Architecture](https://img.shields.io/badge/Architecture-Provider-blue?style=flat-square&logo=flutter&logoColor=white)](https://pub.dev/packages/provider)
[![Firestore](https://img.shields.io/badge/Cloud-Firestore-orange?style=flat-square&logo=firebase&logoColor=white)](https://firebase.google.com/products/firestore)
[![Hive](https://img.shields.io/badge/Local_Storage-Hive-yellow?style=flat-square&logo=database&logoColor=white)](https://docs.hivedb.dev/)
[![Clean Architecture](https://img.shields.io/badge/Design-Clean_Architecture-green?style=flat-square&logo=flutter&logoColor=white)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

<!-- Architecture Diagram -->
<p align="center">
  <img src="https://raw.githubusercontent.com/ResoCoder/flutter-tdd-clean-architecture-course/master/architecture-proposal.png" width="500" alt="Clean Architecture Diagram">
</p>

<!-- Technology Stack Visual -->
<p align="center">
  <img src="https://firebase.google.com/static/images/brand-guidelines/logo-built_white.png" height="50" alt="Firebase">
  <img src="https://docs.hivedb.dev/logo.svg" height="50" alt="Hive Database">
</p>

</div>


<div align="center">
  <a href="https://play.google.com/store/apps/details?id=com.vipulsoftwares.social_connect_hub">
    <img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png" alt="Get it on Google Play" width="200"/>
  </a>
</div>

## Overview

Social Connect Hub is a sophisticated Flutter-powered social communication platform that combines intelligent networking with rich media sharing and dynamic user interactions. The application follows clean architecture principles and is built with a focus on maintainability, scalability, and testability.

## Features

### Authentication
- Email and password-based registration and login
- User profile creation and management
- Secure authentication using Firebase Auth
- Password reset functionality

### User Profile Management
- Comprehensive profile customization
- Profile picture and banner image upload
- Bio, location, website, and contact information
- User online status tracking

### Friend System
- Send, accept, and reject friend requests
- View friend requests in dedicated section
- Real-time status updates for friend actions
- Friend list management

### Messaging
- One-to-one real-time chat
- Support for text messages
- Message status indicators (sent, delivered, read)
- Typing indicators
- Read receipts

### Search
- Find users by name or email
- Quick access to chat with existing friends
- User discovery system

### Notifications
- Push notifications for new messages
- Friend request notifications
- Real-time updates using Firebase Cloud Messaging
- Customizable notification settings

### User Interface
- Material Design 3 components
- Dark mode support
- Responsive layout for different device sizes
- Animated UI elements for better user experience
- Onboarding flow for new users

## Technical Architecture

### Clean Architecture

The application is built following Clean Architecture principles, divided into three main layers:

1. **Domain Layer** (`lib/domain`)
   - Entities: Core business objects independent of any database or framework
   - Use Cases: Application-specific business rules
   - Repository Interfaces: Abstract definitions of data operations

2. **Data Layer** (`lib/data`)
   - Models: Data classes that implement entities
   - Repositories: Implementations of domain repository interfaces
   - Data Sources: Classes that interact with external systems (Firebase, local storage)

3. **Presentation Layer** (`lib/features`)
   - Pages: User interface screens
   - Widgets: Reusable UI components
   - Services: Classes that coordinate between UI and domain layer

### Key Technologies and Libraries

- **State Management**: Provider pattern for reactive state management
- **Dependency Injection**: GetIt for service locator pattern
- **Routing**: Go Router for declarative routing
- **Local Storage**: Hive for persistence and offline support
- **Remote Database**: Firebase Firestore for cloud storage
- **Authentication**: Firebase Authentication
- **Storage**: Firebase Storage for media files
- **Notifications**: Firebase Cloud Messaging for push notifications
- **JSON Handling**: json_serializable for code generation
- **UI Components**: Material Design 3 with custom theming

## Project Structure

```
lib/
├── core/                  # Core utilities and services
│   ├── di/                # Dependency injection setup
│   ├── services/          # Core services (Firebase, etc.)
│   ├── themes/            # App theming
│   └── utils/             # Utility functions
├── data/                  # Data layer
│   ├── datasources/       # Data sources for external systems
│   ├── models/            # Data models
│   └── repositories/      # Repository implementations
├── domain/                # Domain layer
│   ├── core/              # Domain-level utilities
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Use cases for business logic
├── features/              # Feature modules
│   ├── auth/              # Authentication feature
│   ├── chat/              # Chat and messaging feature
│   ├── friends/           # Friend management feature
│   ├── home/              # Home screen and navigation
│   ├── notification/      # Notification handling
│   ├── onboarding/        # User onboarding
│   ├── profile/           # User profile management
│   ├── search/            # User search functionality
│   ├── settings/          # App settings
│   └── welcome/           # Welcome screens
├── main.dart              # Application entry point
└── router.dart            # Application routing
```

## Setup Instructions

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase project with:
  - Authentication enabled (Email/Password)
  - Firestore database
  - Storage
  - Cloud Messaging

### Firebase Setup

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download the configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
4. Enable Email/Password authentication in the Authentication section
5. Create Firestore database in production mode
6. Set up Firebase Storage for file uploads
7. Configure Cloud Messaging for push notifications

### Flutter Setup

1. Clone the repository
   ```
   git clone https://github.com/yourusername/social_connect_hub.git
   cd social_connect_hub
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Run code generation for JSON serialization and Hive adapters
   ```
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the application
   ```
   flutter run
   ```

## Development Notes

### Code Generation

The project uses code generation for:
- JSON serialization with `json_serializable`
- Hive type adapters with `hive_generator`

When making changes to model classes, run:
```
flutter pub run build_runner build --delete-conflicting-outputs
```

### State Management

The application uses the Provider pattern for state management:
- Each feature has its own service class that extends `ChangeNotifier`
- Services are injected using GetIt and provided using `MultiProvider`
- UI components listen to these services using `Consumer` or `Provider.of`

### Routing

Navigation is handled using GoRouter:
- Routes are defined in `router.dart`
- Authentication state is synchronized with the router
- Named routes are used for navigation

### Firebase Integration

Firebase services are initialized in `main.dart` and accessed through repository implementations:
- Firebase Authentication for user management
- Firestore for database operations
- Firebase Storage for file uploads
- Firebase Cloud Messaging for push notifications

## Future Enhancements

- Group chat functionality
- Media sharing (images, videos, files)
- Voice and video calling
- End-to-end encryption
- Message reactions and replies
- User blocking capabilities
- Enhanced notification preferences
- Social media integration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.