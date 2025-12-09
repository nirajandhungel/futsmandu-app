# 📌 FutsMandu App — Architecture & User Flow Documentation

## 1. Application Initialization

**Entry Point**: `main.dart`

### Initialization Flow:
1. **Services Initialization**:
   - `StorageService().init()`: Initializes local storage (shared preferences)
   - `ApiService().init()`: Sets up HTTP client with base configurations

2. **Dependency Injection**:
   - Uses `MultiProvider` to manage app-wide state
   - Core providers:
     - `AuthProvider`: Manages authentication state
     - `VenueProvider`: Handles venue-related state
     - `BookingProvider`: Manages booking state
     - `ThemeProvider`: Handles theme management

3. **Routing**:
   - Uses `GoRouter` for navigation
   - Route guards for authentication
   - Initial route: `RouteNames.login`

## 2. Navigation Structure

### Route Definitions (in `main.dart`):
- `/login` → `LoginScreen()`
- `/register` → `RegisterScreen()`
- `/home` → `HomeScreen()`
- `/profile` → `ProfileScreen()`
- `/venue/:id` → `VenueDetailScreen()`
- `/book/:venueId` → `BookScreen()`
- `/bookings` → `MyBookingsScreen()`
- `/join-team` → `JoinTeammatesScreen()`
- `/owner/register` → `OwnerRegistrationScreen()`
- `/owner/dashboard` → `OwnerDashboard()`
- `/admin/dashboard` → `AdminDashboard()`

### Navigation Flow:
```
App Start → Auth Check → [If Logged In: Home] → [Else: Login/Register]
```

## 3. State Management

**Approach**: Provider + ChangeNotifier

### Key State Managers:
1. **AuthProvider**:
   - Manages user authentication state
   - Handles login/logout
   - Persists auth tokens

2. **VenueProvider**:
   - Manages venue data
   - Handles CRUD operations for venues
   - Caches venue data

3. **BookingProvider**:
   - Manages booking state
   - Handles booking creation/updates
   - Manages booking history

4. **ThemeProvider**:
   - Manages app theme (light/dark mode)
   - Persists theme preference

## 4. Directory Structure

```
lib/
├── main.dart           # App entry point
├── models/            # Data models
├── providers/         # State management
│   ├── auth_provider.dart
│   ├── venue_provider.dart
│   ├── booking_provider.dart
│   └── theme_provider.dart
├── screens/           # App screens
│   ├── auth/         # Authentication flows
│   ├── dashboard/    # Main app screens
│   ├── owner/        # Owner-specific screens
│   └── admin/        # Admin screens
├── services/         # Business logic
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── venue_service.dart
│   └── booking_service.dart
├── utils/            # Utilities and constants
└── widgets/          # Reusable UI components
```

## 5. Reusable Components

### Core Widgets:
1. **AppBarCustom**: Custom app bar with theme support
2. **LoadingIndicator**: Standard loading widget
3. **ErrorWidget**: Standard error display
4. **VenueCard**: Displays venue information
5. **BookingCard**: Shows booking details
6. **FormInputField**: Reusable form input
7. **PrimaryButton**: Styled button component

### Form Components:
- `EmailInput`
- `PasswordInput`
- `PhoneInput`
- `DatePickerField`
- `TimeSlotSelector`

## 6. Key User Flows

### 1. Authentication Flow
```
Splash Screen → [If authenticated: Home] → [Else: Login/Register] → Verify Email (if needed) → Home
```

### 2. Booking Flow
1. User browses venues
2. Selects venue → `VenueDetailScreen`
3. Clicks "Book Now" → `BookScreen`
4. Selects date/time → `TimeSlotSelector`
5. Confirms booking → `BookingConfirmation`
6. Redirect to `MyBookingsScreen`

### 3. Venue Management Flow (Owner)
1. Owner Dashboard → "Add Venue"
2. Fills venue details → `AddVenueScreen`
3. Submits form → API call to create venue
4. Redirect to venue list with new venue

## 7. Error Handling

### Global Error Handling:
- API errors caught by `ApiService`
- Network errors show snackbar
- 401 errors trigger token refresh
- Failed refresh logs user out

### Form Validation:
- Client-side validation
- Server error display
- Loading states during submission

## 8. Security

### Data Protection:
- JWT token-based auth
- Token refresh mechanism
- Secure storage for sensitive data
- HTTPS for all API calls

### Access Control:
- Role-based access
- Protected routes
- Owner-only features
- Admin dashboard restrictions
