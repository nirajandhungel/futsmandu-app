import 'package:flutter/material.dart';
import 'package:futsmandu_flutter/screens/profile/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/venue_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/home_screen.dart';
import 'screens/profile/profile_screen.dart';
// import 'screens/profile/edit_profile.dart';
import 'screens/home/bhaktapur_futsal.dart';
import 'screens/home/kathmandu_futsal.dart';
import 'screens/home/lalitpur_futsal.dart';
import 'screens/dashboard/owner_dashboard.dart';
import 'screens/dashboard/admin_dashboard.dart';
import 'screens/owner/owner_registration_screen.dart';
import 'widgets/court/venuedetail_screen.dart';
import 'models/venue.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService().init();
  ApiService().init();

  runApp(const FutsmanduApp());
}

class FutsmanduApp extends StatelessWidget {
  const FutsmanduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => VenueProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Futsmandu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: GoRouter(
              initialLocation: RouteNames.login,
              redirect: (context, state) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final isAuthenticated = authProvider.isAuthenticated;
                final isAuthRoute = state.matchedLocation == RouteNames.login ||
                    state.matchedLocation == RouteNames.register;

                // If still loading, don't redirect yet
                if (authProvider.status == AuthStatus.loading) {
                  return null;
                }

                // Redirect to home if authenticated and trying to access auth routes
                if (isAuthenticated && isAuthRoute) {
                  return RouteNames.home;
                }

                // Redirect to login if not authenticated and trying to access protected routes
                if (!isAuthenticated && !isAuthRoute) {
                  return RouteNames.login;
                }

                return null;
              },
              routes: [
                GoRoute(
                  path: RouteNames.login,
                  builder: (context, state) => const LoginScreen(),
                ),
                GoRoute(
                  path: RouteNames.register,
                  builder: (context, state) => const RegisterScreen(),
                ),
                GoRoute(
                  path: RouteNames.home,
                  builder: (context, state) => const HomeScreen(),
                ),
                GoRoute(
                  path: RouteNames.profile,
                  builder: (context, state) => const ProfileScreen(),
                ),
                GoRoute(
                  path: '/editProfile',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: '/kathmandu-futsal',
                  builder: (context, state) => const KathmanduFutsalScreen(),
                ),
                GoRoute(
                  path: '/bhaktapur-futsal',
                  builder: (context, state) => const BhaktapurFutsalScreen(),
                ),
                GoRoute(
                  path: '/lalitpur-futsal',
                  builder: (context, state) => const LalitpurFutsalScreen(),
                ),
                GoRoute(
                  path: RouteNames.ownerDashboard,
                  builder: (context, state) => const OwnerDashboardScreen(),
                ),

                GoRoute(
                  path: RouteNames.OwnerKycScreen ,
                  builder: (context, state) => const OwnerKycScreen(),
                ),
                GoRoute(
                  path: RouteNames.adminDashboard,
                  builder: (context, state) => const AdminDashboard(),
                ),
                GoRoute(
                  path: RouteNames.venueDetail,
                  builder: (context, state) {
                    final venue = state.extra as Venue;
                    return VenueDetailScreen(venue: venue);
                  },
                ),


              ],
            ),
          );
        },
      ),
    );
  }
}