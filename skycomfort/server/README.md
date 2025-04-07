# SkyComfort Server

The SkyComfort server provides the backend RESTful API for the SkyComfort in-flight purchase mobile application. It's built with Node.js, Express, TypeScript, and SQLite.

## Table of Contents
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Environment Variables](#environment-variables)
- [Database](#database)
  - [Schema](#schema)
  - [Migrations](#migrations)
  - [Seeding](#seeding)
- [API Documentation](#api-documentation)
  - [Authentication](#authentication)
  - [Services](#services)
  - [Orders](#orders)
  - [Payments](#payments)
  - [Sync](#sync)
- [Development](#development)
  - [Running Locally](#running-locally)
  - [Testing](#testing)

## Features

- **RESTful API**: Well-structured API with proper authentication and error handling
- **Authentication**: JWT-based authentication with role-based access control
- **Database Integration**: SQLite database with TypeORM
- **Real-time Sync**: Support for offline/online synchronization
- **Payment Processing**: API endpoints for payment processing
- **Service Management**: API for managing in-flight services (meals, beverages, entertainment)
- **Order Management**: Complete order lifecycle management
- **Documentation**: Comprehensive API documentation

## Project Structure

```
server/
├── src/                   # Source code
│   ├── api/               # API routes and controllers
│   │   ├── controllers/   # API controllers
│   │   ├── middlewares/   # API middlewares
│   │   └── routes/        # API routes
│   ├── config/            # Configuration files
│   ├── db/                # Database-related files
│   │   ├── migrations/    # Database migrations
│   │   └── seeds/         # Database seed data
│   ├── entities/          # TypeORM entity definitions
│   ├── interfaces/        # TypeScript interfaces
│   ├── middlewares/       # Application middlewares
│   ├── services/          # Business logic services
│   ├── app.ts             # Express application setup
│   └── index.ts           # Application entry point
├── dist/                  # Compiled JavaScript files
├── tests/                 # Test files
├── .env                   # Environment variables
├── tsconfig.json          # TypeScript configuration
└── package.json           # Project dependencies
```

## Getting Started

### Prerequisites

- Node.js (>= 16.x)
- npm or yarn

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/skycomfort.git
cd skycomfort/server
```

2. Install dependencies
```bash
npm install
```

3. Set up your environment variables (see section below)

4. Set up the database
```bash
# Run migrations
npm run migrate:up

# Seed initial data
npm run seed:run
```

5. Start the development server
```bash
npm run dev
```

### Environment Variables

Create a `.env` file in the server directory with the following variables:

```
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
DB_PATH=skycomfort.sqlite

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRES_IN=1d
JWT_REFRESH_EXPIRES_IN=7d

# Logging
LOG_LEVEL=debug
```

## Database

### Schema

The database schema includes the following tables:

- **Users**: Store passenger and staff information
- **Services**: Store available in-flight services
- **Orders**: Store order information
- **OrderItems**: Store individual items in orders
- **Payments**: Store payment transaction information

### Migrations

Database migrations are managed using TypeORM.

```bash
# Run migrations
npm run migrate:up

# Revert migrations (if needed)
npm run migration:revert
```

### Seeding

Seed data is provided for development purposes.

```bash
# Run all seed files
npm run seed:run
```

## API Documentation

### Authentication

- `POST /api/auth/login` - Authenticate user
- `POST /api/auth/register` - Register new user
- `POST /api/auth/refresh` - Refresh authentication token
- `POST /api/auth/validate` - Validate authentication token

### Services

- `GET /api/services` - List all services
- `GET /api/services/:id` - Get service details
- `GET /api/services/type/:type` - Get services by type
- `GET /api/services/category/:category` - Get services by category
- `POST /api/services` - Create new service (staff only)
- `PUT /api/services/:id` - Update service (staff only)
- `DELETE /api/services/:id` - Delete service (staff only)
- `PATCH /api/services/:id/availability` - Update service availability (staff only)

### Orders

- `POST /api/orders` - Create new order
- `GET /api/orders/:id` - Get order details
- `GET /api/orders/user` - Get current user's orders
- `GET /api/orders` - List all orders (staff only)
- `GET /api/orders/flight/:flightId` - Get orders by flight (staff only)
- `PATCH /api/orders/:id/status` - Update order status (staff only)

### Payments

- `POST /api/payments` - Process payment
- `GET /api/payments/transaction/:transactionId` - Get payment by transaction ID
- `GET /api/payments/order/:orderId` - Get payments for an order
- `GET /api/payments` - List all payments (staff only)
- `PATCH /api/payments/:id/status` - Update payment status (staff only)

### Sync

- `POST /api/sync` - Synchronize offline data
- `GET /api/sync/services` - Get updated services since timestamp

## Development

### Running Locally

```bash
# Development mode with hot reloading
npm run dev

# Production mode
npm run build
npm start
```

### Testing

```bash
# Run tests
npm test
```