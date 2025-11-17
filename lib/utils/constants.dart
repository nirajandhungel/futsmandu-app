class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://192.168.1.73:3000/futsmandu/api/v2';
  static const String apiVersion = 'v1';

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

  static const String courtsSearch = '/courts/public/futsal-courts/search';
  static const String futsalCourtsDetail = '/courts/public/futsal-courts';
  static const String courtsDetail = '/courts/public/courts';
  static const String ownerCourts = '/courts/owner/my-courts';

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
  static const String myCourts = '/my-courts';
  static const String addCourt = '/add-court';
}