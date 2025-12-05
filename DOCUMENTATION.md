# Futsmandu App Documentation

This document provides a technical overview of the Futsmandu application, covering file structure, button functionalities, and API interactions.

## 📂 File Directory Overview

The `lib` directory is organized as follows:

- **`main.dart`**: Entry point of the application. Sets up providers and routing.
- **`models/`**: Data models (e.g., `User`, `Venue`, `Booking`) parsing JSON responses.
- **`providers/`**: State management classes using the Provider package.
  - `auth_provider.dart`: Manages user authentication state.
  - `venue_provider.dart`: Manages venue data and search state.
  - `booking_provider.dart`: Manages booking actions and history.
- **`screens/`**: UI screens for the application.
  - `auth/`: Login and Registration screens.
  - `dashboard/`: Main landing pages (Home, Owner Dashboard).
  - `bookings/`: User booking history interaction.
  - `home/`: Futsal specific pages (if any).
- **`services/`**: Handles HTTP requests to the backend API.
  - `api_service.dart`: Base service for Dio setup and interceptors.
  - `auth_service.dart`: Auth-related API calls.
  - `venue_service.dart`: Venue fetching and searching.
  - `booking_service.dart`: Booking creation and management.
- **`utils/`**: Helper functions, constants, and theme definitions.
- **`widgets/`**: Reusable UI components (buttons, text fields, cards).

---

## 📱 Screens & Button Functionality

### 1. Login Screen (`screens/auth/login_screen.dart`)
- **Login Button**: Validates form and calls `AuthProvider.login()`.
- **Register Link**: Navigates to `RegisterScreen`.

### 2. Register Screen (`screens/auth/register_screen.dart`)
- **Register Button**: Validates form and calls `AuthProvider.register()`.
- **Login Link**: Navigates back to `LoginScreen`.

### 3. Home Screen (`screens/dashboard/home_screen.dart`)
- **Search Bar**: Triggers `VenueProvider.searchVenues()` to filter venues by name.
- **City Chips (Kathmandu, Lalitpur, etc.)**: Filters venues by city.
- **Venue Cards**: Tapping a card navigates to `VenueDetailScreen`.
- **Profile Icon**: Navigates to `ProfileScreen`.
- **Drawer Menu**: Opens the side navigation drawer.

### 4. My Bookings Screen (`screens/bookings/my_bookings_screen.dart`)
- **Tabs (All, Upcoming, Completed, Cancelled)**: Filters the displayed list of bookings locally.
- **Cancel Booking Button**:
  - Visible only for upcoming, non-cancelled bookings.
  - Triggers a confirmation dialog.
  - On confirm, calls `BookingService.cancelBooking()`.

### 5. Owner Dashboard (`screens/dashboard/owner_dashboard.dart`)
- **Refresh Icon**: Manually reloads dashboard analytics via `OwnerService.getDashboardAnalytics()`.
- **Add Court Button**: (Placeholder) Intended to navigate to court creation.

---

## 🔌 API Reference

The app communicates with the backend using the `Dio` HTTP client.

### Authentication (`AuthService`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Authenticates user and returns tokens. |
| POST | `/auth/register` | Creates a new user account. |
| POST | `/auth/logout` | Logs out the user (server-side invalidation). |
| POST | `/auth/refresh-token` | Refreshes expired access tokens. |

### Venues (`VenueService`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/venues` | Fetches a list of all venues. |
| GET | `/venues/search` | Searches venues by name or city parameters. |
| GET | `/venues/:id` | Fetches details for a specific venue. |
| GET | `/venues/:id/courts` | Fetches courts available at a specific venue. |
| GET | `/courts/:id/availability` | Checks availability for a specific court and date. |

### Bookings (`BookingService`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/bookings` | Creates a new booking. |
| GET | `/bookings/my-bookings` | Fetches the current user's booking history. |
| GET | `/bookings/:id` | Fetches details of a specific booking. |
| PATCH | `/bookings/:id/cancel` | Cancels an existing booking. |

### Owner Actions (`OwnerService`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/owner/dashboard` | Fetches analytics (revenue, bookings count). |
| GET | `/owner/bookings` | Fetches all bookings for owned venues. |
| PATCH | `/owner/bookings/:id/approve` | Approves a pending booking. |
| PATCH | `/owner/bookings/:id/reject` | Rejects a booking request. |
