// ============================================
// FILE: lib/screens/dashboard/admin_dashboard.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../models/user.dart';
import '../../models/venue.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();

  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _pendingOwners = [];
  List<User> _users = [];
  List<Venue> _venues = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final stats = await _adminService.getDashboardStats();
      final pendingOwners = await _adminService.getPendingOwnerRequests();
      final users = await _adminService.getAllUsers();
      final venues = await _adminService.getAllVenues();

      setState(() {
        _stats = stats;
        _pendingOwners = pendingOwners;
        _users = users;
        _venues = venues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.person_add), text: 'Owner Requests (${_pendingOwners.length})'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.location_city), text: 'Venues'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildOwnerRequestsTab(),
          _buildUsersTab(),
          _buildVenuesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_stats == null) return const Center(child: Text('No data available'));

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Users',
                  (_stats!['totalUsers'] ?? 0).toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Total Owners',
                  (_stats!['totalOwners'] ?? 0).toString(),
                  Icons.business_center,
                  Colors.green,
                ),
                _buildStatCard(
                  'Total Venues',
                  (_stats!['totalVenues'] ?? 0).toString(),
                  Icons.location_city,
                  Colors.purple,
                ),
                _buildStatCard(
                  'Pending Requests',
                  (_stats!['pendingOwnerRequests'] ?? 0).toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Total Bookings',
                  (_stats!['totalBookings'] ?? 0).toString(),
                  Icons.calendar_today,
                  Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerRequestsTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: _pendingOwners.isEmpty
          ? const Center(child: Text('No pending owner requests'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingOwners.length,
        itemBuilder: (context, index) {
          final owner = _pendingOwners[index];
          final user = owner['user'] as Map<String, dynamic>?;
          final ownerProfile = owner['ownerProfile'] as Map<String, dynamic>?;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundImage: ownerProfile?['profilePhotoUrl'] != null
                    ? NetworkImage(ownerProfile!['profilePhotoUrl'])
                    : null,
                child: ownerProfile?['profilePhotoUrl'] == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(user?['fullName'] ?? 'N/A'),
              subtitle: Text(user?['email'] ?? 'N/A'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Phone', user?['phoneNumber'] ?? 'N/A'),
                      _buildInfoRow('PAN Number', ownerProfile?['panNumber'] ?? 'N/A'),
                      _buildInfoRow('Address', ownerProfile?['address'] ?? 'N/A'),
                      _buildInfoRow('Status', ownerProfile?['status'] ?? 'N/A'),
                      const SizedBox(height: 16),
                      const Text(
                        'Documents:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (ownerProfile?['citizenshipFrontUrl'] != null)
                            ElevatedButton.icon(
                              onPressed: () => _showDocument(
                                context,
                                ownerProfile!['citizenshipFrontUrl'],
                                'Citizenship Front',
                              ),
                              icon: const Icon(Icons.image, size: 18),
                              label: const Text('Front'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          if (ownerProfile?['citizenshipBackUrl'] != null)
                            ElevatedButton.icon(
                              onPressed: () => _showDocument(
                                context,
                                ownerProfile!['citizenshipBackUrl'],
                                'Citizenship Back',
                              ),
                              icon: const Icon(Icons.image, size: 18),
                              label: const Text('Back'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _approveOwner(owner['_id'] ?? owner['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.check),
                              label: const Text('Approve'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _rejectOwner(owner['_id'] ?? owner['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.close),
                              label: const Text('Reject'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsersTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: _users.isEmpty
          ? const Center(child: Text('No users found'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(user.fullName[0].toUpperCase()),
              ),
              title: Text(user.fullName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          user.role,
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.blue[100],
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          user.isActive ? 'ACTIVE' : 'SUSPENDED',
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: user.isActive
                            ? Colors.green[100]
                            : Colors.red[100],
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        user.isActive ? Icons.block : Icons.check_circle,
                        size: 20,
                      ),
                      title: Text(
                        user.isActive ? 'Suspend' : 'Activate',
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _updateUserStatus(user.id, !user.isActive);
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete, color: Colors.red, size: 20),
                      title: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _deleteUser(user.id);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenuesTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: _venues.isEmpty
          ? const Center(child: Text('No venues found'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _venues.length,
        itemBuilder: (context, index) {
          final venue = _venues[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.sports_soccer, size: 40, color: Colors.indigo),
              title: Text(venue.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${venue.city}, ${venue.address}'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          venue.isActive ? 'ACTIVE' : 'SUSPENDED',
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: venue.isActive
                            ? Colors.blue[100]
                            : Colors.red[100],
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      if (venue.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(' ${venue.rating!.toStringAsFixed(1)}'),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.verified, size: 20),
                      title: const Text('Verify', style: TextStyle(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context);
                        _verifyVenue(venue.id);
                      },
                    ),
                  ),
                  if (venue.isActive)
                    PopupMenuItem(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.block, color: Colors.orange, size: 20),
                        title: const Text(
                          'Suspend',
                          style: TextStyle(fontSize: 14, color: Colors.orange),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _suspendVenue(venue.id);
                        },
                      ),
                    )
                  else
                    PopupMenuItem(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        title: const Text(
                          'Reactivate',
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _reactivateVenue(venue.id);
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDocument(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Failed to load image'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveOwner(String ownerId) async {
    try {
      await _adminService.approveOwnerRequest(
        ownerId,
        status: 'APPROVED',
        notes: 'Documents verified and approved',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Owner approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDashboardData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectOwner(String ownerId) async {
    // Show dialog to get rejection reason
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Owner Request'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Reason for rejection',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (reason == null || reason.isEmpty) return;

    try {
      await _adminService.updateOwnerStatus(
        ownerId,
        isActive: false,
        reason: reason,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Owner request rejected'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadDashboardData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateUserStatus(String userId, bool isActive) async {
    try {
      await _adminService.updateUserStatus(
        userId,
        isActive: isActive,
        reason: isActive ? 'User reactivated' : 'User suspended by admin',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${isActive ? 'activated' : 'suspended'} successfully'),
          backgroundColor: isActive ? Colors.green : Colors.orange,
        ),
      );
      _loadDashboardData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _adminService.deleteUser(userId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
      _loadDashboardData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyVenue(String venueId) async {
    try {
      await _adminService.verifyVenue(venueId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venue verified successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDashboardData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _suspendVenue(String venueId) async {
    try {
      await _adminService.suspendVenue(venueId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venue suspended successfully'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadDashboardData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reactivateVenue(String venueId) async {
    try {
      await _adminService.reactivateVenue(venueId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venue reactivated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDashboardData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}