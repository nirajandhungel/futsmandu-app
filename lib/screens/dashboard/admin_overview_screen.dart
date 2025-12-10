import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../utils/theme.dart';

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({Key? key}) : super(key: key);

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final stats = await _adminService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColorDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.dividerColorDark.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height:8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.darkPrimaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Admin Portal',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.buttonPrimaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your platform with ease',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.buttonPrimaryText.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.admin_panel_settings,
            size: 60,
            color: AppTheme.buttonPrimaryText,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColorDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading data',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadStats,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_stats == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.cardColorDark,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 16),
            const Text(
              'Platform Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _buildStatCard(
                  title: 'Total Users',
                  value: (_stats!['totalUsers'] ?? 0).toString(),
                  icon: Icons.people,
                  color: const Color(0xFF2196F3),
                ),
                _buildStatCard(
                  title: 'Total Owners',
                  value: (_stats!['totalOwners'] ?? 0).toString(),
                  icon: Icons.business_center,
                  color: const Color(0xFF4CAF50),
                ),
                _buildStatCard(
                  title: 'Total Venues',
                  value: (_stats!['totalVenues'] ?? 0).toString(),
                  icon: Icons.location_city,
                  color: const Color(0xFF9C27B0),
                ),
                _buildStatCard(
                  title: 'Pending Requests',
                  value: (_stats!['pendingOwnerRequests'] ?? 0).toString(),
                  icon: Icons.pending_actions,
                  color: const Color(0xFFFF9800),
                ),
                _buildStatCard(
                  title: 'Total Bookings',
                  value: (_stats!['totalBookings'] ?? 0).toString(),
                  icon: Icons.calendar_today,
                  color: const Color(0xFF00BCD4),
                ),
                _buildStatCard(
                  title: 'Active Today',
                  value: (_stats!['activeToday'] ?? 0).toString(),
                  icon: Icons.trending_up,
                  color: const Color(0xFFE91E63),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}