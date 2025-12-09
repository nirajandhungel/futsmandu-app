import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../models/booking.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading.dart';

class OwnerBookingsScreen extends StatefulWidget {
  final int initialTabIndex; // 0: All, 1: Pending, 2: Confirmed, etc.

  const OwnerBookingsScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  late TabController _tabController;
  
  // Cache for bookings
  List<Booking>? _allBookings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTabIndex);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await _bookingService.getOwnerBookings();
      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showSnackbar(context, 'Failed to load bookings: $e', isError: true);
      }
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String action, {String? reason}) async {
    try {
      if (action == 'APPROVE') {
        await _bookingService.approveBooking(bookingId);
      } else if (action == 'REJECT') {
        await _bookingService.rejectBooking(bookingId, reason: reason);
      }
      
      // Reload
      _loadBookings();
      if (mounted) {
        Helpers.showSnackbar(context, 'Booking ${action.toLowerCase()}ed successfully');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackbar(context, 'Failed to update status: $e', isError: true);
      }
    }
  }

  List<Booking> _filterBookings(String? status) {
    if (_allBookings == null) return [];
    if (status == null) return _allBookings!; // All
    return _allBookings!.where((b) => b.status.toUpperCase() == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading bookings...')
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(_filterBookings(null)),
                _buildBookingList(_filterBookings('PENDING')),
                _buildBookingList(_filterBookings('CONFIRMED')),
                _buildBookingList(_filterBookings('CANCELLED')),
              ],
            ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text('No bookings found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildBookingCard(bookings[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final isPending = booking.status.toUpperCase() == 'PENDING';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.courtName ?? 'Unknown Court',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      booking.venueName ?? 'Unknown Venue',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                _buildStatusChip(booking.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(booking.date), // Assumes YYYY-MM-DD
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('${booking.startTime} - ${booking.endTime}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('User: ${booking.user?.fullName ?? "Unknown"}'),
                Text(
                  'Rs. ${booking.totalAmount}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            if (isPending) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _showRejectDialog(booking.id),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _updateBookingStatus(booking.id, 'APPROVE'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(String bookingId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Reason for rejection (optional)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateBookingStatus(bookingId, 'REJECT', reason: reasonController.text);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'CONFIRMED': color = Colors.green; break;
      case 'PENDING': color = Colors.orange; break;
      case 'CANCELLED': color = Colors.red; break;
      default: color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
