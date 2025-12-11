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
        final isAdmin = user?.isAdmin ?? false;

        return ListView(
          padding: EdgeInsets.zero, // Remove top padding, let header handle it
          children: [
            // Custom Drawer Header to fix layout issues
            Container(
              height: 180, // Fixed height to prevent overflow
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
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 48, // Safe area for status bar
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar and Name Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Text(
                            user?.fullName.isNotEmpty ?? false
                                ? user!.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'Guest',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Mode Badge
                    Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isOwnerMode ? '👔' : '⚽',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isOwnerMode ? 'Owner Mode' : 'Player Mode',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // OWNER MODE NAVIGATION
            if (isOwnerMode) ...[
              _buildListTile(
                icon: Icons.dashboard,
                title: 'Owner Dashboard',
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  context.go(RouteNames.ownerDashboard);
                },
              ),
              _buildListTile(
                icon: Icons.stadium,
                title: 'My Venues',
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.myVenues);
                },
              ),
              _buildListTile(
                icon: Icons.calendar_today,
                title: 'Manage Bookings',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to owner bookings screen
                },
              ),
              _buildListTile(
                icon: Icons.analytics,
                title: 'Analytics',
                onTap: () {
                  Navigator.pop(context);
                  Helpers.showSnackbar(context, 'Analytics coming soon!');
                },
              ),
            ]
            // PLAYER MODE NAVIGATION
            else ...[
              _buildListTile(
                icon: Icons.home,
                title: 'Home',
                onTap: () {
                  Navigator.pop(context);
                  context.go(RouteNames.home);
                },
              ),
              _buildListTile(
                icon: Icons.sports_soccer,
                title: 'Browse Courts',
                onTap: () {
                  Navigator.pop(context);
                  context.go(RouteNames.home);
                },
              ),
              _buildListTile(
                icon: Icons.book_online,
                title: 'My Bookings',
                onTap: () {
                  Navigator.pop(context);
                  context.go(RouteNames.mybookings);
                },
              ),
              _buildListTile(
                icon: Icons.group,
                title: 'Join Teammates',
                onTap: () {
                  Navigator.pop(context);
                  context.go(RouteNames.joinTeammates);
                },
              ),
            ],

            const Divider(color: AppTheme.dividerColorDark, height: 1),

            // COMMON NAVIGATION
            _buildListTile(
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                context.push(RouteNames.profile);
              },
            ),
            _buildListTile(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Helpers.showSnackbar(context, 'Settings coming soon!');
              },
            ),
            _buildListTile(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                Helpers.showSnackbar(context, 'Support coming soon!');
              },
            ),

            // Admin Dashboard
            if (isAdmin) ...[
              const Divider(color: AppTheme.dividerColorDark, height: 1),
              _buildListTile(
                icon: Icons.admin_panel_settings,
                title: 'Admin Dashboard',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.adminDashboard);
                },
              ),
            ],

            const Divider(color: AppTheme.dividerColorDark, height: 1),
            const SizedBox(height: 12),

            // MODE TOGGLE BUTTON
            if (user != null && !isAdmin) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52, // Reduced height for better spacing
                  child: ElevatedButton.icon(
                    onPressed: isOwnerMode
                        ? () => _handleDeactivateOwnerMode(context)
                        : () => _handleActivateOwnerMode(context),
                    icon: Icon(isOwnerMode ? Icons.person : Icons.business_center),
                    label: Text(
                      isOwnerMode ? 'Switch to Player Mode' : 'Switch to Owner Mode',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
              const SizedBox(height: 8), // Reduced spacing
            ],

            // LOGOUT BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52, // Reduced height for better spacing
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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

            const SizedBox(height: 20), // Final bottom spacing
          ],
        );
      },
    ),
  );
}

// Helper method for consistent ListTile styling
Widget _buildListTile({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color color = AppTheme.textPrimaryDark,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    leading: Icon(icon, color: color),
    title: Text(
      title,
      style: TextStyle(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    onTap: onTap,
  );
}

  
}