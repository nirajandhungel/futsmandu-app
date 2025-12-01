class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://futsmandu-server.onrender.com/futsmandu/api/v2';
  static const String apiVersion = 'v2';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';
  static const String authRefreshToken = '/auth/refresh-token';

  // Court endpoints
  static const String courtsSearchFutsal = '/courts/public/futsal-courts/search';
  static const String courtsSearch = '/courts/public/courts/search';
  static const String futsalCourtsDetail = '/courts/public/futsal-courts';
  static const String futsalCourtsWithCourts = '/courts/public/futsal-courts'; // /:id/courts
  static const String courtsDetail = '/courts/public/courts';
  static const String courtAvailability = '/courts/public/courts'; // /:id/availability
  static const String ownerCourts = '/courts/owner/my-courts';
  
  // Booking endpoints
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/my';
  static const String bookingJoin = '/bookings'; // /:id/join
  static const String bookingLeave = '/bookings'; // /:id/leave
  static const String bookingInvite = '/bookings'; // /:id/invite
  static const String bookingCancel = '/bookings'; // /:id/cancel
  
  // Owner endpoints
  static const String ownerActivate = '/owner/activate';
  static const String ownerDeactivate = '/owner/deactivate';
  static const String ownerProfile = '/owner/profile';
  static const String ownerCourtsCreate = '/owner/courts';
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerBookingApprove = '/owner/bookings'; // /:id/approve
  static const String ownerBookingReject = '/owner/bookings'; // /:id/reject
  
  // Admin endpoints
  static const String adminDashboard = '/admin/dashboard/stats';
  static const String adminOwnersPending = '/admin/owners/pending';
  static const String adminOwnersApprove = '/admin/owners'; // /:ownerId/approve
  static const String adminOwnersStatus = '/admin/owners'; // /:ownerId/status
  static const String adminUsers = '/admin/users';
  static const String adminUserById = '/admin/users'; // /:userId
  static const String adminUserStatus = '/admin/users'; // /:userId/status
  static const String adminFutsalCourts = '/admin/futsal-courts';
  static const String adminFutsalCourtVerify = '/admin/futsal-courts'; // /:futsalCourtId/verify
  static const String adminFutsalCourtSuspend = '/admin/futsal-courts'; // /:futsalCourtId/suspend
  static const String adminFutsalCourtReactivate = '/admin/futsal-courts'; // /:futsalCourtId/reactivate
  
  // User endpoints
  static const String userProfile = '/users/me';
  static const String userUpdate = '/users/update';
  static const String userChangePassword = '/users/change-password';

  // User Roles
  static const String rolePlayer = 'PLAYER';
  static const String roleOwner = 'OWNER';
  static const String roleAdmin = 'ADMIN';

  // Court Sizes
  static const String size5v5 = '5v5';
  static const String size6v6 = '6v6';
  static const String size7v7 = '7v7';

  // Booking Status
  static const String statusPending = 'PENDING';
  static const String statusConfirmed = 'CONFIRMED';
  static const String statusCancelled = 'CANCELLED';
  static const String statusCompleted = 'COMPLETED';

  // Error Codes
  static const String errorUnauthorized = 'UNAUTHORIZED';
  static const String errorNotFound = 'NOT_FOUND';
  static const String errorValidation = 'VALIDATION_ERROR';
  static const String errorServer = 'SERVER_ERROR';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String courtDetail = '/court-detail';
  static const String booking = '/booking';
  static const String bookingHistory = '/booking-history';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String ownerDashboard = '/owner-dashboard';
  static const String OwnerKycScreen = '/owner-kyc';
  static const String adminDashboard = '/admin-dashboard';
  static const String myCourts = '/my-courts';
  static const String addCourt = '/add-court';
}