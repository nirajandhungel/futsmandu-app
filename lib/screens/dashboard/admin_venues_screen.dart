import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/venue.dart';

class AdminVenuesScreen extends StatefulWidget {
  const AdminVenuesScreen({Key? key}) : super(key: key);

  @override
  State<AdminVenuesScreen> createState() => _AdminVenuesScreenState();
}

class _AdminVenuesScreenState extends State<AdminVenuesScreen> {
  final AdminService _adminService = AdminService();
  List<Venue> _venues = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final venues = await _adminService.getAllVenues();
      setState(() {
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
      _loadVenues();
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
      _loadVenues();
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
      await _adminService.reactivateVenue(venueId); // Note: Assumes this method exists in AdminService

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venue reactivated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadVenues();
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
              onPressed: _loadVenues,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVenues,
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
}
