# 🔌 FutsMandu App — API Integration & Data Flow Documentation

## 1. API Service Architecture

**Base URL**: Defined in `AppConstants.baseUrl`

### Core Components:
- **ApiService**: Singleton class handling all HTTP requests
- **Dio**: HTTP client with interceptors
- **Interceptors**:
  - Request: Adds auth token
  - Response: Logging
  - Error: Handles token refresh

## 2. API Endpoints

### Authentication
| Endpoint | Method | Service | Used In |
|----------|--------|---------|---------|
| `/auth/login` | POST | `AuthService` | `LoginScreen` |
| `/auth/register` | POST | `AuthService` | `RegisterScreen` |
| `/auth/refresh-token` | POST | `ApiService` | Token refresh interceptor |
| `/auth/logout` | POST | `AuthService` | `ProfileScreen` |

### Venues
| Endpoint | Method | Service | Used In |
|----------|--------|---------|---------|
| `/venues` | GET | `VenueService` | `HomeScreen` |
| `/venues/:id` | GET | `VenueService` | `VenueDetailScreen` |
| `/venues` | POST | `VenueService` | `AddVenueScreen` |
| `/venues/:id` | PUT | `VenueService` | `EditVenueScreen` |
| `/venues/:id` | DELETE | `VenueService` | `OwnerDashboard` |

### Bookings
| Endpoint | Method | Service | Used In |
|----------|--------|---------|---------|
| `/bookings` | GET | `BookingService` | `MyBookingsScreen` |
| `/bookings` | POST | `BookingService` | `BookScreen` |
| `/bookings/:id` | GET | `BookingService` | `BookingDetailScreen` |
| `/bookings/:id` | PUT | `BookingService` | `EditBookingScreen` |
| `/bookings/:id` | DELETE | `BookingService` | `MyBookingsScreen` |

## 3. Data Models

### User
```dart
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 'user', 'owner', 'admin'
  // ...
}
```

### Venue
```dart
class Venue {
  final String id;
  final String name;
  final String location;
  final double rating;
  final List<String> images;
  final List<Court> courts;
  // ...
}
```

### Booking
```dart
class Booking {
  final String id;
  final String venueId;
  final String userId;
  final DateTime date;
  final TimeSlot slot;
  final String status; // 'pending', 'confirmed', 'cancelled'
  // ...
}
```

## 4. API Call Flow Examples

### User Login Flow
1. `LoginScreen` collects credentials
2. Calls `AuthService.login(email, password)`
3. `AuthService` makes POST to `/auth/login`
4. On success:
   - Saves tokens via `StorageService`
   - Updates `AuthProvider` state
   - Navigates to `HomeScreen`

### Venue Booking Flow
1. User selects venue → `VenueDetailScreen`
2. Clicks "Book Now" → `BookScreen`
3. Selects date/time → Calls `BookingService.createBooking()`
4. On success:
   - Updates `BookingProvider`
   - Shows success message
   - Navigates to `MyBookingsScreen`

## 5. Error Handling

### Standard Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message"
  }
}
```

### Common Error Codes:
- `AUTH_REQUIRED`: 401 Unauthorized
- `INVALID_CREDENTIALS`: 400 Bad Request
- `VALIDATION_ERROR`: 422 Unprocessable Entity
- `NOT_FOUND`: 404 Not Found
- `PERMISSION_DENIED`: 403 Forbidden

## 6. Rate Limiting & Throttling

- 100 requests per minute per IP
- 1000 requests per hour per user
- 429 Too Many Requests response when exceeded

## 7. WebSocket Endpoints (Real-time)

| Endpoint | Description | Used In |
|----------|-------------|---------|
| `/ws/booking-updates` | Real-time booking updates | `BookingScreen` |
| `/ws/notifications` | Push notifications | `NotificationService` |

## 8. Testing Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Service health check |
| `/test/error` | GET | Force error for testing |

## 9. Deprecated Endpoints

| Endpoint | Alternative | Removal Date |
|----------|-------------|--------------|
| `/api/v1/old-endpoint` | `/api/v2/new-endpoint` | 2024-06-01 |
