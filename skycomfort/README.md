# SkyComfort - Comprehensive In-Flight Service Platform

## Project Overview

SkyComfort is a comprehensive in-flight service platform designed to enhance passenger experience by providing a seamless interface for ordering meals, entertainment, and comfort items during flights. The platform consists of a mobile application (iOS/Android) built with Flutter and native integrations, backed by a robust REST API server and secure authentication system.

This platform supports both online and offline operation modes, ensuring functionality during all phases of flight, with intelligent synchronization when connectivity is available.

![SkyComfort Platform Overview](https://via.placeholder.com/800x400?text=SkyComfort+Platform+Overview)

## Architecture Overview

SkyComfort implements a modern layered architecture spanning both client and server components:

### Application Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                            CLIENT SIDE                               │
├─────────────────┬─────────────────────────┬─────────────────────────┤
│  PRESENTATION   │      BUSINESS LOGIC     │       DATA ACCESS       │
│                 │                         │                         │
│  - Flutter UI   │  - BLoC State Mgmt      │  - Repository Pattern   │
│  - Swift UI     │  - Service Layer        │  - Local SQLite DB      │
│  Components     │  - Method Channels      │  - API Client           │
└─────────────────┴─────────────────────────┴─────────────────────────┘
                                │
                                │ HTTP/REST
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                            SERVER SIDE                               │
├─────────────────┬─────────────────────────┬─────────────────────────┤
│     API LAYER   │   APPLICATION LAYER     │     DATA ACCESS LAYER   │
│                 │                         │                         │
│  - REST Endpoints│ - Service Orchestration │  - TypeORM/Repository  │
│  - Auth Middleware│- Business Rules       │  - SQLite Database      │
│  - API Versioning│- Error Handling        │  - Entity Models        │
└─────────────────┴─────────────────────────┴─────────────────────────┘
                                │
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        PERSISTENCE LAYER                             │
│                                                                     │
│                  - SQLite Database                                  │
│                  - File Storage                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Detailed Component Diagram

```
┌────────────────────────────────────────────────────────────────────────────┐
│                             MOBILE APPLICATION                             │
│                                                                            │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐ │
│  │              │   │              │   │              │   │              │ │
│  │  UI Layer    │──►│  BLoC State  │◄─►│ Repositories │◄─►│ Data Sources │ │
│  │              │   │  Management  │   │              │   │              │ │
│  └──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘ │
│                                                                   │        │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐          │        │
│  │  Swift       │   │              │   │              │          │        │
│  │  Method      │◄─►│ Local SQLite │◄──│ Sync Manager │◄─────────┘        │
│  │  Channel     │   │   Database   │   │              │                   │
│  └──────────────┘   └──────────────┘   └──────────────┘                   │
└───────────────────────────────────┬────────────────────────────────────────┘
                                    │
                                    │ HTTP/REST API
                                    ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                                 BACKEND API                                │
│                                                                            │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐ │
│  │ API Gateway  │   │              │   │              │   │              │ │
│  │ & Versioning │──►│ Controllers  │──►│  Services    │──►│ Repositories │ │
│  │              │   │              │   │              │   │              │ │
│  └──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘ │
│         │                                                         │        │
│         │           ┌──────────────┐   ┌──────────────┐          │        │
│         │           │              │   │              │          │        │
│         └──────────►│   Auth &     │   │Error Handling│◄─────────┘        │
│                     │  Security    │   │              │                   │
│                     │              │   │              │                   │
│                     └──────────────┘   └──────────────┘                   │
└───────────────────────────────────┬────────────────────────────────────────┘
                                    │
                                    │ Database Access
                                    ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                             DATA PERSISTENCE                               │
│                                                                            │
│                     ┌──────────────────────────────┐                       │
│                     │                              │                       │
│                     │          SQLite DB           │                       │
│                     │                              │                       │
│                     └──────────────────────────────┘                       │
└────────────────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
skycomfort/
│
├── mobile/                   # Mobile application (Flutter + Swift)
│   ├── assets/               # App assets (images, fonts, etc.)
│   ├── lib/                  # Dart/Flutter code
│   │   ├── app/              # App initialization
│   │   ├── config/           # App configuration
│   │   ├── data/             # Data layer
│   │   │   ├── datasources/  # Remote and local data sources
│   │   │   ├── models/       # Data models
│   │   │   └── repositories/ # Repository implementations
│   │   ├── domain/           # Domain layer
│   │   │   ├── entities/     # Domain entities
│   │   │   ├── repositories/ # Repository interfaces
│   │   │   └── usecases/     # Business logic use cases
│   │   └── presentation/     # UI layer
│   │       ├── blocs/        # BLoC state management
│   │       ├── pages/        # App screens
│   │       └── widgets/      # Reusable UI components
│   ├── ios/                  # iOS-specific code
│   │   └── Runner/           # iOS app
│   │       └── MethodChannels/  # Swift payment integration
│   └── android/              # Android-specific code
│
├── server/                   # Backend server application
│   ├── src/                  # Source code
│   │   ├── api/              # API endpoints
│   │   │   ├── controllers/  # Route controllers
│   │   │   ├── middlewares/  # API middlewares
│   │   │   └── routes/       # Route definitions
│   │   ├── config/           # Server configuration
│   │   ├── entities/         # Entity definitions
│   │   ├── services/         # Business logic services
│   │   └── db/               # Database migrations and seeds
│
├── docs/                     # Documentation
│   ├── api/                  # API documentation
│   ├── architecture/         # Architecture diagrams
│   └── guides/               # Development guides
│
└── tools/                    # Development and deployment tools
    └── scripts/              # Utility scripts
```

## Application Flow Diagrams

### User Authentication Flow

```
┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐
│         │      │         │      │         │      │         │
│  User   │─────►│ Mobile  │─────►│ Backend │─────►│ SQLite  │
│         │      │   App   │      │   API   │      │   DB    │
│         │      │         │      │         │      │         │
└─────────┘      └─────────┘      └─────────┘      └─────────┘
     │                │                │                │
     │   Enter Flight │                │                │
     │     & Seat     │                │                │
     │───────────────►│                │                │
     │                │                │                │
     │                │  Authenticate  │                │
     │                │───────────────►│                │
     │                │                │  Query User    │
     │                │                │───────────────►│
     │                │                │                │
     │                │                │  Return Data   │
     │                │                │◄───────────────│
     │                │   JWT Token    │                │
     │                │◄───────────────│                │
     │                │                │                │
     │ Authentication │                │                │
     │    Success     │                │                │
     │◄───────────────│                │                │
     │                │                │                │
```

### Service Purchase Flow

```
┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐
│         │      │         │      │         │      │         │      │         │
│  User   │─────►│ Mobile  │─────►│ Local   │─────►│ Backend │─────►│ Server  │
│         │      │   App   │      │ SQLite  │      │   API   │      │ SQLite  │
│         │      │         │      │         │      │         │      │         │
└─────────┘      └─────────┘      └─────────┘      └─────────┘      └─────────┘
     │                │                │                │                │
     │  Browse &      │                │                │                │
     │ Select Services│                │                │                │
     │───────────────►│                │                │                │
     │                │  Load Services │                │                │
     │                │───────────────►│                │                │
     │                │   Return Data  │                │                │
     │                │◄───────────────│                │                │
     │                │                │                │                │
     │  Add to Cart   │                │                │                │
     │───────────────►│                │                │                │
     │                │  Save in Cart  │                │                │
     │                │───────────────►│                │                │
     │                │                │                │                │
     │  Proceed to    │                │                │                │
     │   Payment      │                │                │                │
     │───────────────►│                │                │                │
     │                │                │                │                │
     │                │  Process via   │                │                │
     │                │ Native Payment │                │                │
     │                │────────────────────────────────────────────────┐ │
     │                │                │                │              │ │
     │                │                │                │              │ │
     │                │◄───────────────────────────────────────────────┘ │
     │                │                │                │                │
     │                │ Create Order   │                │                │
     │                │───────────────►│                │                │
     │                │                │                │                │
     │                │                │   Sync Order   │                │
     │                │                │───────────────►│                │
     │                │                │                │  Store Order   │
     │                │                │                │───────────────►│
     │                │                │                │                │
     │  Show Order    │                │                │  Confirmation  │
     │  Confirmation  │                │                │◄───────────────│
     │◄───────────────│                │                │                │
     │                │                │                │                │
```

### Offline/Online Synchronization Flow

```
┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐
│         │      │         │      │         │      │         │
│ Mobile  │─────►│ Local   │─────►│ Sync    │─────►│ Backend │
│  App    │      │ SQLite  │      │ Manager │      │   API   │
│         │      │         │      │         │      │         │
└─────────┘      └─────────┘      └─────────┘      └─────────┘
     │                │                │                │
     │   App Starts   │                │                │
     │───────────────►│                │                │
     │                │   Load Data    │                │
     │                │───────────────►│                │
     │                │                │                │
     │                │                │  Check Network │
     │                │                │───────────────►│
     │                │                │                │
     │                │                │    Network     │
     │                │                │   Available    │
     │                │                │◄───────────────│
     │                │                │                │
     │                │                │ Pull Updates   │
     │                │                │───────────────►│
     │                │                │                │
     │                │                │  Return Data   │
     │                │                │◄───────────────│
     │                │ Update Local DB│                │
     │                │◄───────────────│                │
     │                │                │                │
     │  App Functions │                │                │
     │    Offline     │                │                │
     │◄───────────────│                │                │
     │                │                │                │
     │  Create Order  │                │                │
     │───────────────►│                │                │
     │                │  Store Locally │                │
     │                │───────────────►│                │
     │                │                │                │
     │                │                │  Network Check │
     │                │                │───────────────►│
     │                │                │                │
     │                │                │  No Network    │
     │                │                │◄───────────────│
     │                │                │                │
     │                │                │  Flag for Sync │
     │                │◄───────────────│                │
     │                │                │                │
     │  Later: Network│                │                │
     │   Available    │                │                │
     │───────────────►│                │                │
     │                │  Find Pending  │                │
     │                │───────────────►│                │
     │                │                │                │
     │                │                │   Sync Data    │
     │                │                │───────────────►│
     │                │                │                │
     │                │                │ Confirm Synced │
     │                │                │◄───────────────│
     │                │ Update Status  │                │
     │                │◄───────────────│                │
     │                │                │                │
```

## Technology Stack

### Mobile App
- **Framework**: Flutter
- **State Management**: Provider, Bloc
- **Database**: SQLite
- **Network**: Dio
- **Authentication**: JWT tokens, Secure Storage
- **Dependencies Management**: pub.dev

### Backend Server
- **Framework**: Express.js with TypeScript
- **Database**: SQLite with TypeORM
- **Authentication**: JWT
- **API Documentation**: Swagger/OpenAPI
- **Validation**: Express validators

## Architecture

### Mobile Architecture (Flutter)
- **UI Layer**: Flutter widgets, screens, and components
- **Business Logic Layer**: BLoC pattern for state management
- **Repository Layer**: Bridge between UI/BLoC and data sources
- **Data Layer**: Local SQLite database and API services

### Server Architecture (Node.js)
- **API Layer**: Express routes and controllers
- **Service Layer**: Business logic and data processing
- **Data Access Layer**: TypeORM entities and repositories
- **Database**: SQLite

## Sync & Offline Capabilities
The application features robust offline capabilities:
- Local SQLite database for data persistence
- Sync queue for pending operations
- Background synchronization when connectivity is restored
- Conflict resolution strategies

## Project Progress

### ✅ Phase A: Project Structure Setup (Completed)
- ✅ Created the new project structure with `mobile`, `server`, `docs`, and `tools` directories
- ✅ Moved existing Flutter code to the `mobile` directory
- ✅ Set up the server application framework with Node.js and TypeScript
- ✅ Created basic server configuration and error handling middleware

### ✅ Phase B: Mobile App Refactoring (Completed)
- ✅ Enhanced the `DatabaseHelper` class to implement the full SQLite schema
- ✅ Updated repositories to use the database
- ✅ Added synchronization capabilities
- ✅ Prepared the mobile app to connect with the backend API

### ✅ Phase C: Backend Server Implementation (Completed)
- ✅ Implemented API endpoints for services, orders, payments, and authentication
- ✅ Set up database models using SQLite and TypeORM
- ✅ Created authentication middleware
- ✅ Added validation for API requests
- ✅ Implemented error handling

### ✅ Phase D: Mobile-Backend Integration (Completed)
- ✅ Created a robust network service with Dio for API communication
- ✅ Implemented token management for authentication
- ✅ Added API response models for consistent data handling
- ✅ Enhanced synchronization with offline queue processing
- ✅ Created API clients for services, orders, payments, and authentication
- ✅ Updated repositories to work with both local and remote data sources
- ✅ Added network status monitoring

### 🔄 Phase E: Admin Dashboard (In Progress)
- [] Create an admin web interface for flight attendants
- [] Implement order management
- [] Add inventory management
- [] Create analytics dashboards

### 🔄 Phase F: Testing & Deployment (Planned)
- [] Implement automated testing
- [] Set up CI/CD pipeline
- [] Prepare deployment documentation
- [] Create user guides

## Testing the Implementation

To verify that the refactored application works correctly, follow these steps:

### 1. Server Setup

```bash
# Navigate to server directory
cd skycomfort/server

# Install dependencies
npm install

# Create .env file (use the template from the README)
# Make sure DB_PATH is set correctly

# Start the server
npm run dev
```

The server should start and display:
- "Data Source has been initialized!" 
- "SQLite database location: [path]"
- "Server running on port 3000"

You can test the server health endpoint by visiting `http://localhost:3000/health` in your browser.

### 2. Mobile App Setup

```bash
# Navigate to mobile directory
cd skycomfort/mobile

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 3. Testing Features

#### User Registration and Authentication
1. Register a new user in the app
2. Log out and try logging back in
3. Verify your authentication persists when closing and reopening the app

#### Offline Capability
1. Turn off internet connection on your device
2. Browse services and add items to cart
3. Place an order
4. Verify the order is stored locally

#### Synchronization
1. Turn internet back on
2. Open the app and verify it attempts to sync with the server
3. Check the server logs to confirm sync requests

#### Data Persistence
1. Close and reopen the app
2. Verify your data (user profile, orders, etc.) persists

### 4. Troubleshooting

#### Server Issues
- Check the terminal for any error messages
- Verify the SQLite database file exists and has permissions
- Confirm the `.env` file contains correct settings

#### Mobile App Issues
- Check the Flutter console for any errors
- Verify the API URL in `app_config.dart` points to your server
- Clear app data and reinstall if necessary

---

This README provides a comprehensive overview of the expanded SkyComfort platform, including both mobile and backend components. The next steps would involve implementing this architecture, starting with the backend API and enhancing the mobile app to integrate with it while maintaining offline functionality. 