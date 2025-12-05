import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/owner_service.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../screens/bookings/my_bookings_screen.dart';
import '../bookings/my_bookings_screen.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
    );

    if (!confirmed || !context.mounted) return;

    Helpers.showLoadingDialog(context);

    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!context.mounted) return;

    Navigator.pop(context);
    context.go(RouteNames.login);
    Helpers.showSnackbar(context, 'Logged out successfully');
  }

  // Future<void> _handleActivateOwnerMode(BuildContext context) async {
  //   Navigator.pop(context); // Close drawer first

  //   final authProvider = context.read<AuthProvider>();
  //   final user = authProvider.user;

  //   final ownerStatus = user?.ownerStatus?.toUpperCase();

  //   // Case 1: No owner profile at all (null) - First time user
  //   if (ownerStatus == null) {
  //     if (context.mounted) {
  //       context.push(RouteNames.OwnerKycScreen);
  //     }
  //     return;
  //   }

  //   // Case 2: DRAFT status - Incomplete KYC submission
  //   if (ownerStatus == 'DRAFT') {
  //     if (context.mounted) {
  //       Helpers.showSnackbar(
  //         context,
  //         'Please complete your KYC verification',
  //       );
  //       context.push(RouteNames.OwnerKycScreen);
  //     }
  //     return;
  //   }

  //   // Case 3: PENDING status - Waiting for admin approval
  //   if (ownerStatus == 'PENDING') {
  //     if (context.mounted) {
  //       Helpers.showSnackbar(
  //         context,
  //         'Your verification is pending. Please wait for admin approval.',
  //         isError: true,
  //       );
  //       context.go(RouteNames.home);
  //     }
  //     return;
  //   }

  //   // Case 4: REJECTED status - Allow resubmission
  //   if (ownerStatus == 'REJECTED') {
  //     final resubmit = await Helpers.showConfirmDialog(
  //       context,
  //       title: 'KYC Rejected',
  //       message: 'Your previous KYC was rejected. Would you like to resubmit?',
  //       confirmText: 'Resubmit',
  //       cancelText: 'Cancel',
  //     );

  //     if (resubmit && context.mounted) {
  //       context.push(RouteNames.OwnerKycScreen);
  //     } else if (context.mounted) {
  //       context.go(RouteNames.home);
  //     }
  //     return;
  //   }

  //   // Case 5: APPROVED status - Navigate to owner dashboard
  //   if (ownerStatus == 'APPROVED') {
  //     if (context.mounted) {
  //       context.go(RouteNames.ownerDashboard);
  //     }
  //     return;
  //   }

  //   // Fallback: Unknown status - navigate to KYC
  //   if (context.mounted) {
  //     context.push(RouteNames.OwnerKycScreen);
  //   }
  // }

  Future<void> _handleDeactivateOwnerMode(BuildContext context) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Switch to Player Mode',
      message: 'Are you sure you want to switch to Player Mode? You can switch back anytime.',
      confirmText: 'Switch',
      cancelText: 'Cancel',
    );

    if (!confirmed || !context.mounted) return;

    Helpers.showLoadingDialog(context);

    try {
      final authProvider = context.read<AuthProvider>();
      final ownerService = OwnerService();

      // Call deactivate owner mode API
      final authResponse = await ownerService.activatePlayerMode();

      if (!context.mounted) return;

      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Close drawer

      // Update user in auth provider - this will trigger UI rebuild
      await authProvider.updateUser(authResponse.user);

      // Navigate to home to refresh UI and ensure we're in player mode context
      if (context.mounted) {
        context.go(RouteNames.home);
        // Show success message after a short delay to ensure navigation is complete
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          Helpers.showSnackbar(context, 'Switched to Player Mode successfully');
        }
      }
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close loading dialog
      }
      // Close drawer if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close drawer
      }

      Helpers.showSnackbar(
        context,
        'Failed to switch mode: ${e.toString()}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.fullName.isNotEmpty ?? false
                        ? user!.fullName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                accountName: Text(
                  user?.fullName ?? 'Guest',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(user?.email ?? ''),
              ),

              // Home
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Book a Venue
              ListTile(
                leading: const Icon(Icons.sports_soccer),
                title: const Text('Book a Venue'),
                onTap: () {
                  Navigator.pop(context);
                  Helpers.showSnackbar(context, 'Browse courts to book!');
                },
              ),

              // My Bookings
              ListTile(
                leading: const Icon(Icons.book_online),
                title: const Text('My Bookings'),
                onTap: () {
                  Navigator.pop(context);         // Close the drawer
                  context.go(RouteNames.mybookings); // Navigate to MyBookings screen
                },
              ),



              // Join Teammates
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Join Teammates'),
                onTap: () {
                  Navigator.pop(context);
                  Helpers.showSnackbar(context, 'Find teammates coming soon!');
                },
              ),

              const Divider(),

              // Profile
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.profile);
                },
              ),

              // Settings
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Helpers.showSnackbar(context, 'Settings coming soon!');
                },
              ),

              // Help & Support
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                  Helpers.showSnackbar(context, 'Support coming soon!');
                },
              ),

              const Divider(),

              // Owner Dashboard (show when in owner mode)
              if (user?.isInOwnerMode ?? false)
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Owner Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RouteNames.ownerDashboard);
                  },
                ),

              // Admin Dashboard
              if (user?.isAdmin ?? false)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Admin Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RouteNames.adminDashboard);
                  },
                ),

              const Divider(),
              const SizedBox(height: 8),

              // Logout button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Mode Toggle Buttons
              // Show "Owner Mode" button only when:
              // - User is not admin
              // - User is currently in player mode (regardless of role)
              if (user != null &&
                  !user.isAdmin &&
                  user.isInPlayerMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: ()   {
                        Navigator.pop(context); // Close drawer
                        context.push(RouteNames.OwnerKycScreen); // Go directly to KYC screen
                      },
                      icon: const Icon(Icons.business_center),
                      label: const Text('Owner Mode'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),

              // Show "Player Mode" button when user is in owner mode
              if (user != null && user.isInOwnerMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleDeactivateOwnerMode(context),
                      icon: const Icon(Icons.person),
                      label: const Text('Player Mode'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}