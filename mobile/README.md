# SkyComfort - Airline In-Flight Purchase App

## Project Overview
SkyComfort is a hybrid mobile application built with Flutter and native Swift integration for iOS, designed to enhance the in-flight experience by allowing passengers to purchase meals and entertainment services during their flight.

## Features
- In-flight entertainment purchase (movies, TV shows, music)
- In-flight meal purchase
- Secure payment processing
- Order confirmation and tracking
- Offline functionality for in-flight use
- Airplane mode compatibility

## Architecture

### Hybrid Approach (Flutter + Native Swift)
This project employs a hybrid approach combining Flutter for cross-platform UI and business logic with native Swift integrations for iOS-specific functionality:

#### Flutter (Core Application)
- **UI Components**: All shared UI elements, screens, and navigation
- **Business Logic**: Core application logic and state management
- **Network Layer**: API calls and data handling
- **Local Storage**: SQLite database integration via Flutter plugins

#### Native Swift (iOS Integration)
- **Platform-Specific Features**: Payment processing, secure storage
- **Hardware Integration**: NFC payments, airplane mode detection
- **Performance-Critical Components**: Video playback, caching mechanisms
- **Method Channels**: Bridge between Flutter and native code

### System Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│   (Flutter UI Components, Screens, Navigation)       │
└───────────────────────────┬─────────────────────────┘
                            │
┌───────────────────────────┼─────────────────────────┐
│                  Business Logic Layer                │
│   (BLoC/Provider, Services, Models)                  │
└───────────────────────────┬─────────────────────────┘
                            │
┌───────────────────────────┼─────────────────────────┐
│                     Data Layer                       │
│   (Repositories, Local Storage, API Clients)         │
└───────────────────────────┬─────────────────────────┘
                            │
┌───────────────────────────┼─────────────────────────┐
│              Platform Integration Layer              │
│   (Method Channels, Native Swift Integration)        │
└─────────────────────────────────────────────────────┘
```

## Technology Stack

### Frontend
- **Flutter**: Main UI framework
- **Dart**: Programming language for Flutter
- **Swift**: Native iOS development
- **BLoC Pattern**: State management
- **GetX**: Navigation and dependency injection (optional)

### Backend Integration
- **RESTful APIs**: For server communication when online
- **GraphQL**: Option for efficient data fetching (if needed)

### Database
- **SQLite**: Local database for storing:
  - User preferences
  - Purchase history
  - Cached content information
  - Order tracking

### Authentication & Security
- **JWT**: Token-based authentication
- **Secure Storage**: For payment credentials
- **Encryption**: For sensitive user data

## Workflow

### User Journey
1. **Launch & Loading**:
   - App opens with SkyComfort splash screen
   - Loads flight information (Flight AB123, Seat 12A)
   - Confirms airplane mode is active

2. **Service Selection**:
   - User browses available services (Entertainment, Meals)
   - Selects desired items
   - Views running total and item count

3. **Payment Processing**:
   - User selects saved payment method or adds new card
   - Reviews payment details
   - Completes secure transaction

4. **Order Confirmation**:
   - Receives confirmation of successful payment
   - Views order details and delivery information
   - Returns to home or browses more services

### Technical Workflow
1. **App Initialization**:
   - Load configuration from local storage
   - Check connectivity status
   - Validate flight status

2. **Data Synchronization**:
   - Load available services from pre-cached data
   - Update if connectivity allows
   - Apply passenger-specific pricing and availability

3. **Transaction Processing**:
   - Secure local payment processing
   - Queue successful transactions for server sync
   - Store transaction records in SQLite

4. **Service Delivery**:
   - Unlock digital content for entertainment
   - Generate meal delivery notification to cabin crew
   - Update inventory availability

## API Requirements

### Internal APIs
1. **Authentication Service**:
   - `POST /api/auth/validate` - Validate passenger credentials
   - `GET /api/auth/refresh` - Refresh authentication token

2. **Catalog Service**:
   - `GET /api/catalog/entertainment` - List available entertainment
   - `GET /api/catalog/meals` - List available meals
   - `GET /api/catalog/pricing` - Get pricing information

3. **Order Service**:
   - `POST /api/orders/create` - Create new order
   - `GET /api/orders/{id}` - Get order details
   - `PUT /api/orders/{id}/status` - Update order status

4. **Payment Service**:
   - `POST /api/payments/process` - Process payment
   - `GET /api/payments/methods` - Get saved payment methods
   - `POST /api/payments/methods` - Save new payment method

### External APIs
1. **Payment Gateway**:
   - Integration with secure payment processor
   - Tokenization of payment details
   - Transaction verification

2. **Content Delivery Network**:
   - Streaming URLs for entertainment content
   - Content metadata and thumbnails

## Project Structure

```
skycomfort/
├── android/                  # Android native code
├── ios/                      # iOS native code and Swift integrations
├── lib/
│   ├── app/                  # Application setup
│   │   ├── app.dart          # App entry point
│   │   └── routes.dart       # Route definitions
│   ├── config/               # Configuration files
│   │   ├── constants.dart    # App constants
│   │   └── themes.dart       # UI themes
│   ├── core/                 # Core functionality
│   │   ├── error/            # Error handling
│   │   ├── network/          # Network utilities
│   │   └── utils/            # Utility functions
│   ├── data/
│   │   ├── models/           # Data models
│   │   ├── repositories/     # Repository implementations
│   │   ├── sources/
│   │   │   ├── local/        # Local data sources (SQLite)
│   │   │   └── remote/       # Remote data sources (APIs)
│   │   └── providers/        # Data providers
│   ├── domain/
│   │   ├── entities/         # Business entities
│   │   ├── repositories/     # Repository interfaces
│   │   └── usecases/         # Business logic use cases
│   ├── presentation/
│   │   ├── blocs/            # BLoC state management
│   │   ├── pages/            # App screens
│   │   │   ├── splash/       # Splash screen
│   │   │   ├── services/     # Service selection
│   │   │   ├── payment/      # Payment processing
│   │   │   └── confirmation/ # Order confirmation
│   │   ├── widgets/          # Reusable UI components
│   │   └── navigation/       # Navigation helpers
│   └── main.dart             # Entry point
├── test/                     # Unit and widget tests
├── integration_test/         # Integration tests
├── assets/                   # Static assets
│   ├── images/               # Image assets
│   ├── fonts/                # Custom fonts
│   └── data/                 # Static data files
├── pubspec.yaml              # Flutter dependencies
└── README.md                 # Project documentation
```

## Native Swift Integration

### iOS Directory Structure

```
ios/
├── Runner/
│   ├── AppDelegate.swift     # Main app delegate
│   ├── NativeModules/        # Custom native modules
│   │   ├── PaymentModule/    # Native payment processing
│   │   ├── SecurityModule/   # Security features
│   │   └── MediaModule/      # Media playback enhancements
│   └── MethodChannels/       # Flutter-Swift communication
├── Pods/                     # CocoaPods dependencies
└── Runner.xcworkspace        # Xcode workspace
```

## Database Schema (SQLite)

### Tables

1. **users**
   - user_id (Primary Key)
   - flight_number
   - seat_number
   - preferences (JSON)

2. **catalog_items**
   - item_id (Primary Key)
   - type (entertainment/meal)
   - name
   - description
   - price
   - image_path
   - availability

3. **orders**
   - order_id (Primary Key)
   - user_id (Foreign Key)
   - order_date
   - status
   - total_amount

4. **order_items**
   - id (Primary Key)
   - order_id (Foreign Key)
   - item_id (Foreign Key)
   - quantity
   - price

5. **payment_methods**
   - id (Primary Key)
   - user_id (Foreign Key)
   - card_number (encrypted)
   - expiry_date (encrypted)
   - cardholder_name (encrypted)
   - card_type
   - last_four_digits

## Development Recommendations

1. **Offline-First Approach**: Design for offline functionality from the start
2. **Airplane Mode Testing**: Test extensively in airplane mode
3. **Battery Optimization**: Minimize battery usage for long flights
4. **Caching Strategy**: Pre-cache catalog data before takeoff
5. **Sync Strategy**: Implement efficient sync when connectivity is restored
6. **Security**: Implement strong security for payment processing
7. **Testing**: Create comprehensive test suite for offline scenarios
8. **Error Handling**: Robust error handling for connectivity issues
9. **UI/UX**: Simple, intuitive interface for all passenger demographics
10. **Accessibility**: Ensure the app is accessible to all users

## Next Steps
1. Set up Flutter project structure
2. Configure native Swift modules
3. Implement SQLite database schema
4. Create UI components based on wireframes
5. Implement core business logic
6. Set up method channels for Flutter-Swift communication
7. Develop offline functionality
8. Implement secure payment processing
9. Create comprehensive testing suite
10. Optimize for airplane mode and battery efficiency 