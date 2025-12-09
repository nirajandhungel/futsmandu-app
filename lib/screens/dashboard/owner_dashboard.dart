import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/owner_service.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final OwnerService _ownerService = OwnerService();
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _ownerService.getDashboardAnalytics();
      print("Owner dashboard data by nirajan on owner_dashboard.dart${data}");
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      print("Error on owner_dashboard get dashboard api ${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading dashboard...')
          : _errorMessage != null
              ? _buildErrorView()
              : _buildDashboard(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboard,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    if (_dashboardData == null) {
      return const Center(child: Text('No data available'));
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildRecentBookings(),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${authProvider.user?.fullName ?? 'Owner'}!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your futsal courts and bookings',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    final stats = _dashboardData!;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Courts',
          '${stats['totalCourts'] ?? 0}',
          Icons.sports_soccer,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Bookings',
          '${stats['totalBookings'] ?? 0}',
          Icons.calendar_today,
          Colors.green,
        ),
        _buildStatCard(
          'Pending Bookings',
          '${stats['pendingBookings'] ?? 0}',
          Icons.pending,
          Colors.orange,
        ),
        _buildStatCard(
          'Revenue',
          'Rs. ${stats['totalRevenue'] ?? 0}',
          Icons.attach_money,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
        minHeight: 100,  // Fixed height
      ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 12,  
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookings() {
    final bookings = _dashboardData!['recentBookings'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Bookings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (bookings.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No recent bookings'),
              ),
            ),
          )
        else
          ...bookings.take(5).map((booking) {
            final bookingData = booking as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(bookingData['status'] as String? ?? 'PENDING'),
                  child: Icon(
                    _getStatusIcon(bookingData['status'] as String? ?? 'PENDING'),
                    color: Colors.white,
                  ),
                ),
                title: Text(bookingData['courtName'] as String? ?? 'Unknown Court'),
                subtitle: Text(
                  '${bookingData['bookingDate'] ?? ''} • ${bookingData['startTime'] ?? ''} - ${bookingData['endTime'] ?? ''}',
                ),
                trailing: Text(
                  'Rs. ${bookingData['totalAmount'] ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Helpers.showSnackbar(context, 'Add court feature coming soon!');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Court'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Helpers.showSnackbar(context, 'View bookings feature coming soon!');
                },
                icon: const Icon(Icons.list),
                label: const Text('View Bookings'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

