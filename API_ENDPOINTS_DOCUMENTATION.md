# API Endpoints Documentation

## Overview
This document explains all API endpoints used in the Futsmandu Flutter app, where they are defined, where they are used, and their purposes.

**Base URL:** `https://futsmandu-server.onrender.com/futsmandu/api/v2`

---

## Architecture

### 1. **API Configuration** (`lib/utils/constants.dart`)
All endpoint paths are defined as constants in `AppConstants` class.

### 2. **API Service** (`lib/services/api_service.dart`)
- Central HTTP client using Dio
- Handles authentication tokens automatically
- Manages token refresh on 401 errors
- Provides generic methods: `get()`, `post()`, `put()`, `patch()`, `delete()`

### 3. **Service Layer** (`lib/services/`)
Each service class wraps specific API endpoints:
- `AuthService` - Authentication endpoints
- `BookingService` - Booking management endpoints
- `CourtService` - Court/Futsal court endpoints
- `OwnerService` - Owner-specific endpoints
- `AdminService` - Admin management endpoints
- `UserService` - User profile endpoints

### 4. **Usage in App**
Services are used through:
- **Providers** (`lib/providers/`) - State management
- **Screens** (`lib/screens/`) - UI components

---

## Authentication Endpoints

### `/auth/login` (POST)
- **Purpose:** User login
- **Used in:** `AuthService.login()`
- **Called from:** `AuthProvider`, `LoginScreen`
- **Request:** `{ email, password }`
- **Response:** `{ user, tokens }`

### `/auth/register` (POST)
- **Purpose:** User registration
- **Used in:** `AuthService.register()`
- **Called from:** `AuthProvider`, `RegisterScreen`
- **Request:** `{ email, password, fullName, phoneNumber, role }`
- **Response:** `{ user, tokens }`

### `/auth/logout` (POST)
- **Purpose:** User logout
- **Used in:** `AuthService.logout()`
- **Called from:** `AuthProvider`, logout actions
- **Response:** Success confirmation

### `/auth/refresh-token` (POST)
- **Purpose:** Refresh access token
- **Used in:** `ApiService._refreshToken()` (automatic), `AuthService.refreshToken()`
- **Request:** `{ refreshToken }`
- **Response:** `{ accessToken, refreshToken }`
- **Note:** Automatically called by API interceptor on 401 errors

---

## Court Endpoints

### `/courts/public/futsal-courts/search` (GET)
- **Purpose:** Search futsal courts by city/name
- **Used in:** `CourtService.searchFutsalCourts()`
- **Called from:** `CourtProvider`, city-specific screens (`bhaktapur_futsal.dart`, `kathmandu_futsal.dart`, `lalitpur_futsal.dart`)
- **Query Params:** `city`, `name`
- **Response:** `{ futsalCourts: [...], count }`

### `/courts/public/futsal-courts/:id` (GET)
- **Purpose:** Get futsal court details
- **Used in:** `CourtService.getFutsalCourtDetails()`
- **Called from:** Court detail screens
- **Response:** `{ futsalCourt: {...} }`

### `/courts/public/futsal-courts/:id/courts` (GET)
- **Purpose:** Get all courts for a futsal court
- **Used in:** `CourtService.getFutsalCourtCourts()`
- **Called from:** Court detail screens
- **Response:** `{ futsalCourt: {...}, courts: [...] }`

### `/courts/public/courts/:id` (GET)
- **Purpose:** Get individual court details
- **Used in:** `CourtService.getCourtDetails()`
- **Called from:** Court detail screens
- **Response:** `{ court: {...} }`

### `/courts/public/courts/:id/availability` (GET)
- **Purpose:** Check court availability for a date
- **Used in:** `CourtService.getCourtAvailability()`
- **Called from:** Booking screens
- **Query Params:** `date` (YYYY-MM-DD)
- **Response:** Availability data with time slots

### `/courts/owner/my-courts` (GET)
- **Purpose:** Get owner's futsal courts (OWNER role required)
- **Used in:** `CourtService.getOwnerCourts()`
- **Called from:** Owner dashboard, owner screens
- **Response:** `{ futsalCourts: [...] }`

### `/courts/public/futsal-courts/:id/courts` (POST)
- **Purpose:** Create a new court under a futsal court (OWNER role required)
- **Used in:** `CourtService.createCourt()`
- **Called from:** Owner screens (add court functionality)
- **Request:** `{ name, courtNumber, size, hourlyRate, maxPlayers, description }`
- **Response:** `{ court: {...} }`

---

## Booking Endpoints

### `/bookings` (POST)
- **Purpose:** Create a new booking
- **Used in:** `BookingService.createBooking()`
- **Called from:** `BookingProvider`, booking screens
- **Request:** `CreateBookingRequest` (courtId, date, timeSlot, etc.)
- **Response:** `{ booking: {...} }`

### `/bookings/my` (GET)
- **Purpose:** Get current user's bookings
- **Used in:** `BookingService.getUserBookings()`
- **Called from:** `BookingProvider`, booking history screens
- **Query Params:** `status`, `startDate`, `endDate`
- **Response:** `{ bookings: [...], count }`

### `/bookings/:id` (GET)
- **Purpose:** Get booking details
- **Used in:** `BookingService.getBookingDetails()`
- **Called from:** Booking detail screens
- **Response:** `{ booking: {...} }`

### `/bookings/:id/join` (POST)
- **Purpose:** Join an existing booking
- **Used in:** `BookingService.joinBooking()`
- **Called from:** Booking screens (join match functionality)
- **Response:** `{ booking: {...}, autoConfirmed }`

### `/bookings/:id/leave` (POST)
- **Purpose:** Leave a booking
- **Used in:** `BookingService.leaveBooking()`
- **Called from:** Booking screens
- **Response:** `{ booking: {...} }`

### `/bookings/:id/invite` (POST)
- **Purpose:** Invite players to a booking
- **Used in:** `BookingService.invitePlayers()`
- **Called from:** Booking screens
- **Request:** `{ userIds: [...] }`
- **Response:** `{ booking: {...} }`

### `/bookings/:id/cancel` (PATCH)
- **Purpose:** Cancel a booking
- **Used in:** `BookingService.cancelBooking()`
- **Called from:** Booking screens
- **Response:** `{ booking: {...} }`

### `/owner/bookings` (GET)
- **Purpose:** Get owner's bookings (OWNER role required)
- **Used in:** `BookingService.getOwnerBookings()`
- **Called from:** Owner dashboard
- **Query Params:** `status`, `futsalCourtId`
- **Response:** `{ bookings: [...], count }`

### `/owner/bookings/:id/approve` (PATCH)
- **Purpose:** Approve a booking (OWNER role required)
- **Used in:** `BookingService.approveBooking()`
- **Called from:** Owner dashboard
- **Response:** `{ booking: {...} }`

### `/owner/bookings/:id/reject` (PATCH)
- **Purpose:** Reject a booking (OWNER role required)
- **Used in:** `BookingService.rejectBooking()`
- **Called from:** Owner dashboard
- **Request:** `{ reason? }` (optional)
- **Response:** `{ booking: {...} }`

---

## Owner Endpoints

### `/owner/activate` (POST)
- **Purpose:** Activate owner mode (become an owner)
- **Used in:** `OwnerService.activateOwnerMode()`
- **Called from:** `OwnerRegistrationScreen`
- **Request:** `{ panNumber, address, additionalKyc?, documentPaths? }`
- **Response:** Owner activation confirmation

### `/owner/deactivate` (POST)
- **Purpose:** Deactivate owner mode
- **Used in:** `OwnerService.deactivateOwnerMode()`
- **Called from:** Owner settings
- **Response:** Deactivation confirmation

### `/owner/profile` (GET)
- **Purpose:** Get owner profile information
- **Used in:** `OwnerService.getOwnerProfile()`
- **Called from:** Owner dashboard
- **Response:** Owner profile data

### `/owner/courts` (POST)
- **Purpose:** Create a new futsal court (OWNER role required)
- **Used in:** `OwnerService.createFutsalCourt()`
- **Called from:** Owner screens (add futsal court)
- **Request:** `{ name, address, city, description?, phoneNumber?, email?, latitude?, longitude?, amenities?, imagePaths? }`
- **Response:** `{ futsalCourt: {...} }`

### `/owner/dashboard` (GET)
- **Purpose:** Get owner dashboard analytics
- **Used in:** `OwnerService.getDashboardAnalytics()`
- **Called from:** `OwnerDashboard`
- **Response:** Dashboard statistics (bookings, revenue, etc.)

---

## Admin Endpoints

### `/admin/dashboard/stats` (GET)
- **Purpose:** Get admin dashboard statistics
- **Used in:** `AdminService.getDashboardStats()`
- **Called from:** `AdminDashboard`
- **Response:** Admin statistics (users, owners, courts, bookings)

### `/admin/owners/pending` (GET)
- **Purpose:** Get pending owner requests
- **Used in:** `AdminService.getPendingOwnerRequests()`
- **Called from:** Admin dashboard
- **Query Params:** `page`, `limit`, `status`, `search`, `sort`
- **Response:** List of pending owner requests

### `/admin/owners/:ownerId/approve` (PATCH)
- **Purpose:** Approve an owner request
- **Used in:** `AdminService.approveOwnerRequest()`
- **Called from:** Admin dashboard
- **Request:** `{ status, notes? }`
- **Response:** Updated owner data

### `/admin/owners/:ownerId/status` (PATCH)
- **Purpose:** Update owner status (activate/deactivate)
- **Used in:** `AdminService.updateOwnerStatus()`
- **Called from:** Admin dashboard
- **Request:** `{ isActive, reason? }`
- **Response:** Updated owner data

### `/admin/users` (GET)
- **Purpose:** Get all users
- **Used in:** `AdminService.getAllUsers()`
- **Called from:** Admin dashboard
- **Query Params:** `page`, `limit`, `role`, `isActive`, `search`, `sort`
- **Response:** List of users

### `/admin/users/:userId` (GET)
- **Purpose:** Get user by ID
- **Used in:** `AdminService.getUserById()`
- **Called from:** Admin dashboard
- **Response:** `{ user: {...} }`

### `/admin/users/:userId` (DELETE)
- **Purpose:** Delete a user
- **Used in:** `AdminService.deleteUser()`
- **Called from:** Admin dashboard
- **Response:** Success confirmation

### `/admin/users/:userId/status` (PATCH)
- **Purpose:** Update user status (activate/deactivate)
- **Used in:** `AdminService.updateUserStatus()`
- **Called from:** Admin dashboard
- **Request:** `{ isActive, reason? }`
- **Response:** `{ user: {...} }`

### `/admin/futsal-courts` (GET)
- **Purpose:** Get all futsal courts
- **Used in:** `AdminService.getAllFutsalCourts()`
- **Called from:** Admin dashboard
- **Query Params:** `page`, `limit`, `isVerified`, `isActive`, `search`, `sort`
- **Response:** List of futsal courts

### `/admin/futsal-courts/:futsalCourtId/verify` (PATCH)
- **Purpose:** Verify a futsal court
- **Used in:** `AdminService.verifyFutsalCourt()`
- **Called from:** Admin dashboard
- **Response:** `{ futsalCourt: {...} }`

### `/admin/futsal-courts/:futsalCourtId/suspend` (PATCH)
- **Purpose:** Suspend a futsal court
- **Used in:** `AdminService.suspendFutsalCourt()`
- **Called from:** Admin dashboard
- **Response:** `{ futsalCourt: {...} }`

### `/admin/futsal-courts/:futsalCourtId/reactivate` (PATCH)
- **Purpose:** Reactivate a suspended futsal court
- **Used in:** `AdminService.reactivateFutsalCourt()`
- **Called from:** Admin dashboard
- **Response:** `{ futsalCourt: {...} }`

---

## User Endpoints

### `/users/me` (GET)
- **Purpose:** Get current user profile
- **Used in:** `UserService.getMyProfile()`
- **Called from:** Profile screens, `ProfileScreen`
- **Response:** `{ user: {...} }`

### `/users/update` (PATCH)
- **Purpose:** Update user profile
- **Used in:** `UserService.updateProfile()`
- **Called from:** `EditProfileScreen`
- **Request:** `{ fullName?, phoneNumber?, address? }`
- **Response:** `{ user: {...} }`

### `/users/change-password` (POST)
- **Purpose:** Change user password
- **Used in:** `UserService.changePassword()`
- **Called from:** Profile settings
- **Request:** `{ currentPassword, newPassword }`
- **Response:** Success confirmation

---

## Usage Flow

### Example: User Login Flow
1. User enters credentials in `LoginScreen`
2. `LoginScreen` calls `AuthProvider.login()`
3. `AuthProvider` calls `AuthService.login()`
4. `AuthService` uses `ApiService.post()` with endpoint `/auth/login`
5. `ApiService` automatically adds auth token to headers
6. Response is parsed and tokens/user data saved to storage
7. UI updates via provider state

### Example: Search Courts Flow
1. User navigates to city screen (e.g., `KathmanduFutsal`)
2. Screen calls `CourtProvider.searchFutsalCourts(city: 'Kathmandu')`
3. `CourtProvider` calls `CourtService.searchFutsalCourts()`
4. `CourtService` uses `ApiService.get()` with endpoint `/courts/public/futsal-courts/search`
5. Results displayed in UI

---

## Authentication Flow

All authenticated endpoints automatically include the Bearer token in the `Authorization` header via `ApiService` interceptors.

**Token Management:**
- Tokens stored in local storage via `StorageService`
- Access token added to all requests automatically
- On 401 error, refresh token is attempted automatically
- If refresh fails, user is logged out and storage cleared

---

## Error Handling

All endpoints use standardized error responses:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error message",
    "details": {}
  }
}
```

Common error codes:
- `AUTH_1001` - Invalid credentials
- `AUTH_1002` - Token expired
- `USER_2001` - User not found
- `BOOKING_4001` - Booking not found
- `BOOKING_4005` - Slot unavailable

---

## Notes

1. **Base URL:** Defined in `AppConstants.baseUrl`
2. **All endpoints** are relative to the base URL
3. **Dynamic segments** (like `:id`) are replaced in service methods
4. **Query parameters** are passed as maps to service methods
5. **Request/Response** formats are standardized across all endpoints
6. **Role-based access:** Some endpoints require specific roles (OWNER, ADMIN)







