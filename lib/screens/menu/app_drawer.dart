import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';

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
                  Navigator.pop(context);
                  context.push(RouteNames.bookingHistory);
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

              // Owner Dashboard
              if (user?.isOwner ?? false)
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
              SizedBox(
                width: double.infinity,
                height: 57,
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

              const SizedBox(height: 16),

              // Owner Mode Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // close drawer
                    context.push('/owner-kyc'); // navigate to Owner KYC screen
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

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
