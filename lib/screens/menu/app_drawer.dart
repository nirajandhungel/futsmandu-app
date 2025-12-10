import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/owner_service.dart';
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

  Future<void> _handleActivateOwnerMode(BuildContext context) async {
    Navigator.pop(context); // Close drawer
    
    // Navigate to KYC screen which handles the status check
    context.push(RouteNames.ownerKycScreen);
  }

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

      final authResponse = await ownerService.activatePlayerMode();

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Close drawer

      await authProvider.updateUser(authResponse.user);

      if (context.mounted) {
        context.go(RouteNames.home);
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          Helpers.showSnackbar(context, 'Switched to Player Mode successfully');
        }
      }
    } catch (e) {
      if (!context.mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
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
      backgroundColor: AppTheme.backgroundDark,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          final isOwnerMode = user?.isInOwnerMode ?? false;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.darkPrimaryColor,
                    ],
                  ),
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
                accountEmail: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.email ?? ''),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isOwnerMode ? '👔 Owner Mode' : '⚽ Player Mode',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // OWNER MODE NAVIGATION
              if (isOwnerMode) ...[
                ListTile(
                  leading: const Icon(Icons.dashboard, color: AppTheme.primaryColor),
                  title: const Text('Owner Dashboard', style: TextStyle(color: AppTheme.textPrimaryDark)),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouteNames.ownerDashboard);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.stadium, color: AppTheme.textPrimaryDark),
                  title: const Text('My Venues', style: TextStyle(color: AppTheme.textPrimaryDark)),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RouteNames.myVenues);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: AppTheme.textPrimaryDark),
                  title: const Text('Manage Bookings', style: TextStyle(color: AppTheme.textPrimaryDark)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to owner bookings screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics, color: AppTheme.textPrimaryDark),
                  title: const Text('Analytics', style: TextStyle(color: AppTheme.textPrimaryDark)),
                  onTap: () {
                    Navigator.pop(context);
                    Helpers.showSnackbar(context, 'Analytics coming soon!');
                  },
                ),
              ]
              // PLAYER MODE NAVIGATION
              else ...[
                ListTile(
                  leading: const Icon(Icons.home, color: AppTheme.textPrimaryDark),
                  title: const Text('Home', style: TextStyle(color: AppTheme.textPrimaryDark)),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouteNames.home);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sports_soccer, color: AppTheme.textPrimaryDark),
                  title: const Text('Browse Courts', style: TextStyle(color: AppTheme.textPrimaryDark)),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouteNames.home);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.book_online, color: AppTheme.textPrimaryDark),
                  title: const Text('My Bookings', style: TextStyle(color: AppTheme.textPrimaryDark)),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouteNames.mybookings);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group, color: AppTheme.textPrimaryDark),
                  title: const Text('Join Teammates', style: TextStyle(color: AppTheme.textPrimaryDark)),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouteNames.joinTeammates);
                  },
                ),
              ],

              const Divider(color: AppTheme.dividerColorDark),

              // COMMON NAVIGATION
              ListTile(
                leading: const Icon(Icons.person, color: AppTheme.textPrimaryDark),
                title: const Text('Profile', style: TextStyle(color: AppTheme.textPrimaryDark)),
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.profile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: AppTheme.textPrimaryDark),
                title: const Text('Settings', style: TextStyle(color: AppTheme.textPrimaryDark)),
                onTap: () {
                  Navigator.pop(context);
                  Helpers.showSnackbar(context, 'Settings coming soon!');
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: AppTheme.textPrimaryDark),
                title: const Text('Help & Support', style: TextStyle(color: AppTheme.textPrimaryDark)),
                onTap: () {
                  Navigator.pop(context);
                  Helpers.showSnackbar(context, 'Support coming soon!');
                },
              ),

              // Admin Dashboard
              if (user?.isAdmin ?? false) ...[
                const Divider(color: AppTheme.dividerColorDark),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                  title: const Text('Admin Dashboard', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RouteNames.adminDashboard);
                  },
                ),
              ],

              const Divider(color: AppTheme.dividerColorDark),
              const SizedBox(height: 8),

              // MODE TOGGLE BUTTON
              if (user != null && !user.isAdmin) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: isOwnerMode
                          ? () => _handleDeactivateOwnerMode(context)
                          : () => _handleActivateOwnerMode(context),
                      icon: Icon(isOwnerMode ? Icons.person : Icons.business_center),
                      label: Text(isOwnerMode ? 'Switch to Player Mode' : 'Switch to Owner Mode'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOwnerMode ? Colors.green : Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // LOGOUT BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
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
            ],
          );
        },
      ),
    );
  }
}