import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../utils/theme.dart';
import '../../widgets/common/loading.dart';
import '../../services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;
  
  List<Booking> _allBookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _completedBookings = [];
  List<Booking> _cancelledBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyBookings() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await _bookingService.getUserBookings();

      if (mounted) {
        setState(() {
          _allBookings = bookings;
          _categorizeBookings();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bookings: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _categorizeBookings() {
    _upcomingBookings = _allBookings.where((booking) {
      return (booking.isPending || booking.isConfirmed) && 
             !booking.isCancelled && 
             !booking.isCompleted;
    }).toList();

    _completedBookings = _allBookings.where((booking) {
      return booking.isCompleted;
    }).toList();

    _cancelledBookings = _allBookings.where((booking) {
      return booking.isCancelled;
    }).toList();

    // Sort upcoming bookings by date (nearest first)
    _upcomingBookings.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
    
    // Sort completed/cancelled by date (newest first)
    _completedBookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    _cancelledBookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    _allBookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
  }

  Future<void> _handleCancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColorDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: const Text(
          'Cancel Booking',
          style: TextStyle(
            color: AppTheme.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'No',
              style: TextStyle(color: AppTheme.textSecondaryDark),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cancelling booking...'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }

      await _bookingService.cancelBooking(booking.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _loadMyBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading your bookings...')
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'My Bookings',
        style: TextStyle(
          color: AppTheme.textPrimaryDark,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppTheme.backgroundDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryDark),
        onPressed: () => context.go('/home'),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorColor: AppTheme.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 3,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textTertiaryDark,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
        tabs: [
          Tab(child: _buildTabLabel('All', _allBookings.length)),
          Tab(child: _buildTabLabel('Upcoming', _upcomingBookings.length)),
          Tab(child: _buildTabLabel('Completed', _completedBookings.length)),
          Tab(child: _buildTabLabel('Cancelled', _cancelledBookings.length)),
        ],
      ),
    );
  }

  Widget _buildTabLabel(String label, int count) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(_allBookings, 'No bookings found'),
              _buildBookingsList(_upcomingBookings, 'No upcoming bookings'),
              _buildBookingsList(_completedBookings, 'No completed bookings'),
              _buildBookingsList(_cancelledBookings, 'No cancelled bookings'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: _loadMyBookings,
      backgroundColor: AppTheme.primaryColor,
      color: AppTheme.buttonPrimaryText,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == bookings.length - 1 ? 16 : 12,
            ),
            child: _buildBookingCard(bookings[index]),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColorDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.dividerColorDark.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookingHeader(booking),
          const Divider(
            height: 0,
            thickness: 1,
            color: AppTheme.dividerColorDark,
          ),
          _buildBookingDetails(booking),
          _buildBookingActions(booking),
        ],
      ),
    );
  }

  Widget _buildBookingHeader(Booking booking) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.sports_soccer,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        booking.venue?.name ?? 'Venue Name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildStatusBadge(booking.status),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.stadium,
                      size: 14,
                      color: AppTheme.textTertiaryDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.court?.name ?? 'Court',
                      style: TextStyle(
                        color: AppTheme.textSecondaryDark,
                        fontSize: 13,
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
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'PENDING':
        backgroundColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange;
        displayText = 'Pending';
        icon = Icons.pending;
        break;
      case 'CONFIRMED':
        backgroundColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue;
        displayText = 'Confirmed';
        icon = Icons.check_circle;
        break;
      case 'COMPLETED':
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green;
        displayText = 'Completed';
        icon = Icons.done_all;
        break;
      case 'CANCELLED':
        backgroundColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red;
        displayText = 'Cancelled';
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey;
        displayText = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails(Booking booking) {
    print(booking);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildDetailIcon(Icons.calendar_today),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        color: AppTheme.textTertiaryDark,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(booking.bookingDate),
                      style: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDetailIcon(Icons.access_time),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time',
                      style: TextStyle(
                        color: AppTheme.textTertiaryDark,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.startTime} - ${booking.endTime}',
                      style: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (booking.venue?.city != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDetailIcon(Icons.location_on),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          color: AppTheme.textTertiaryDark,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${booking.venue?.address??"No address"}, ${booking.venue?.city??"No city"}',
                        style: const TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDetailIcon(Icons.note),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          color: AppTheme.textTertiaryDark,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.notes!,
                        style: const TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(color: AppTheme.dividerColorDark),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        color: AppTheme.textTertiaryDark,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${booking.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                _buildPaymentBadge(booking.paymentStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 16,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildPaymentBadge(String paymentStatus) {
    final isPaid = paymentStatus.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid
            ? AppTheme.successColor.withOpacity(0.15)
            : AppTheme.warningColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid
              ? AppTheme.successColor.withOpacity(0.3)
              : AppTheme.warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            size: 14,
            color: isPaid ? AppTheme.successColor : AppTheme.warningColor,
          ),
          const SizedBox(width: 6),
          Text(
            isPaid ? 'Paid' : 'Unpaid',
            style: TextStyle(
              color: isPaid ? AppTheme.successColor : AppTheme.warningColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingActions(Booking booking) {
    final canCancel = !booking.isCancelled &&
        !booking.isCompleted &&
        booking.bookingDate.isAfter(DateTime.now());

    if (!canCancel) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration:const BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusL),
          bottomRight: Radius.circular(AppTheme.radiusL),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.dividerColorDark,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleCancelBooking(booking),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppTheme.errorColor),
                foregroundColor: AppTheme.errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement reschedule or view details
              },
              icon: const Icon(Icons.calendar_today, size: 18),
              label: const Text('Reschedule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.buttonPrimaryText,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.cardColorDark,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.dividerColorDark,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.calendar_today,
                size: 50,
                color: AppTheme.textTertiaryDark,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book a court to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textTertiaryDark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/home');
              },
              icon: const Icon(Icons.sports_soccer),
              label: const Text('Browse Courts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.buttonPrimaryText,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
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
}