import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminOwnerRequestsScreen extends StatefulWidget {
  const AdminOwnerRequestsScreen({Key? key}) : super(key: key);

  @override
  State<AdminOwnerRequestsScreen> createState() => _AdminOwnerRequestsScreenState();
}

class _AdminOwnerRequestsScreenState extends State<AdminOwnerRequestsScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _pendingOwners = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final pendingOwners = await _adminService.getPendingOwnerRequests();
      setState(() {
        _pendingOwners = pendingOwners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
      _loadRequests();
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
      _loadRequests();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
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
}
