# CN-NETSHARE Flutter Mobile App

WireGuard Exit Node Sharing Platform - Mobile Application

## Overview

CN-NETSHARE is a mobile application that enables users to share and connect to WireGuard exit nodes. The app supports two user roles:
- **Host**: Share your internet connection as a WireGuard exit node
- **Receiver**: Connect to available exit nodes

## Features

### Authentication
- Email-based signup and signin
- Role selection (Host/Receiver)
- Secure token-based authentication
- Persistent login sessions

### Host Mode
- Configure device as exit node
- View connected receivers in real-time
- Monitor data usage per connection
- Enable/disable exit node sharing

### Receiver Mode
- Browse available hosts
- Request connection to hosts
- View WireGuard configuration (QR code + text)
- Copy configuration to clipboard
- Monitor local data usage
- Disconnect from hosts

### Shared Features
- Dark theme UI
- Bottom navigation
- Settings management
- Profile information
- Logout functionality

## Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── constants/
│   ├── app_config.dart      # API URLs and app configuration
│   └── app_theme.dart       # Dark theme definition
├── models/
│   ├── user.dart            # User data model
│   ├── host.dart            # Host data model
│   ├── connection.dart      # Connection data model
│   ├── data_usage.dart      # Data usage model
│   └── wireguard_config.dart # WireGuard configuration model
├── providers/
│   ├── auth_provider.dart   # Authentication state management
│   ├── host_provider.dart   # Host mode state management
│   ├── receiver_provider.dart # Receiver mode state management
│   └── connection_provider.dart # Connections state management
├── services/
│   ├── api_service.dart     # HTTP API calls
│   ├── local_storage_service.dart # SharedPreferences wrapper
│   ├── wireguard_integration_service.dart # WireGuard app integration
│   └── data_tracking_service.dart # Network data tracking
├── screens/
│   ├── auth/
│   │   ├── sign_in_screen.dart
│   │   └── sign_up_screen.dart
│   ├── host/
│   │   ├── host_dashboard_screen.dart
│   │   └── host_config_screen.dart
│   ├── receiver/
│   │   ├── receiver_dashboard_screen.dart
│   │   └── active_connection_screen.dart
│   └── shared/
│       ├── home_screen.dart
│       └── settings_screen.dart
└── widgets/
    ├── loading_indicator.dart
    ├── error_message.dart
    ├── connection_card.dart
    └── host_card.dart
```

## Dependencies

- **provider**: State management
- **http**: API communication
- **shared_preferences**: Local data storage
- **qr_flutter**: QR code generation
- **intl**: Data formatting
- **connectivity_plus**: Network monitoring
- **permission_handler**: Network interface permissions

## Setup

### Prerequisites
- Flutter SDK 3.10.4 or higher
- Dart 3.10.4 or higher
- Android Studio / Xcode for mobile development

### Installation

1. Navigate to the Flutter project directory:
```bash
cd flutter/cn_netshare
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API base URL:
Edit `lib/constants/app_config.dart` or set environment variable:
```dart
const String apiBaseUrl = 'https://your-api-url.com';
```

Or run with environment variable:
```bash
flutter run --dart-define=API_BASE_URL=https://your-api-url.com
```

### Running the App

#### Android
```bash
flutter run
```

#### iOS
```bash
flutter run
```

#### Build Release APK (Android)
```bash
flutter build apk --release
```

#### Build Release IPA (iOS)
```bash
flutter build ios --release
```

## API Integration

The app communicates with the backend server through the following endpoints:

### Authentication
- `POST /api/auth/signup` - Create new account
- `POST /api/auth/signin` - Login
- `GET /api/auth/me` - Get current user

### Host Mode
- `POST /api/host/configure` - Enable/disable exit node
- `GET /api/host/connections` - Get connected receivers

### Receiver Mode
- `GET /api/hosts` - List available hosts
- `POST /api/receiver/request` - Request connection to host
- `GET /api/receiver/connection` - Get active connection

### Data Usage
- `GET /api/data-usage/:connectionId` - Get connection data usage
- `POST /api/connection/:connectionId/disconnect` - Disconnect

## State Management

The app uses Provider for state management with the following providers:

- **AuthProvider**: Manages authentication state and user session
- **HostProvider**: Manages host mode operations and peer connections
- **ReceiverProvider**: Manages receiver mode and host browsing
- **ConnectionProvider**: Manages connection history and data usage

## UI/UX

### Theme
- Dark theme optimized for readability
- Material Design 3 components
- Consistent color scheme
- Responsive layouts

### Navigation
- Bottom navigation bar with 3 tabs
- Role-based dashboard (Host/Receiver)
- Smooth transitions between screens
- Back button support

## Error Handling

- Network failure handling with retry options
- User-friendly error messages
- Loading states for async operations
- Form validation

## Local Storage

User data persisted locally:
- Authentication token
- User profile
- App preferences

## Future Enhancements

- Push notifications for connection requests
- Real-time data usage tracking with actual network monitoring
- Connection history with graphs
- Profile editing
- Password change
- In-app WireGuard configuration import
- Multi-language support

## License

Copyright © 2025 CN-NETSHARE
