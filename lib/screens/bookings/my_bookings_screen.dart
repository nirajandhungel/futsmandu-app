
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../models/court.dart';
import '../../models/venue.dart';
import '../../utils/theme.dart';
import '../../widgets/common/loading.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isLoadingMore = false;

  // Store bookings with their venue info separately
  List<BookingWithVenue> _allBookings = [];
  List<BookingWithVenue> _upcomingBookings = [];
  List<BookingWithVenue> _completedBookings = [];
  List<BookingWithVenue> _cancelledBookings = [];

  int _currentPage = 1;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_onScroll);

    // Load bookings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreBookings();
      }
    }
  }

  Future<void> _loadMyBookings() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call / load mock data
      await Future.delayed(const Duration(milliseconds: 500));
      final mockBookingsWithVenues = _generateMockBookingsWithVenues();

      setState(() {
        _allBookings = mockBookingsWithVenues;
        _categorizeBookings();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bookings: $e'),
            backgroundColor: Colors.red,
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

  Future<void> _loadMoreBookings() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Simulate loading next page
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _currentPage++;
        if (_currentPage > 3) {
          _hasMoreData = false;
        }
      });
    } catch (_) {
      // ignore
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _categorizeBookings() {
    final now = DateTime.now();

    _upcomingBookings = _allBookings.where((bookingWithVenue) {
      final booking = bookingWithVenue.booking;
      return !booking.isCancelled &&
          !booking.isCompleted &&
          booking.bookingDate.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();

    _completedBookings = _allBookings.where((bookingWithVenue) {
      return bookingWithVenue.booking.isCompleted;
    }).toList();

    _cancelledBookings = _allBookings.where((bookingWithVenue) {
      return bookingWithVenue.booking.isCancelled;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading your bookings...')
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // OPTION 1: Explicit back button with custom behavior
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home'); // or your route name
            }
          }
      ),
      // OPTION 2: If you want automatic back button (comment out 'leading' above and uncomment below)
      // automaticallyImplyLeading: true,

      title: const Text('My Bookings'),
      elevation: 0,
      bottom: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorColor: AppTheme.primaryColor,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: _buildTabLabel('All', _allBookings.length),
          ),
          Tab(
            child: _buildTabLabel('Upcoming', _upcomingBookings.length),
          ),
          Tab(
            child: _buildTabLabel('Completed', _completedBookings.length),
          ),
          Tab(
            child: _buildTabLabel('Cancelled', _cancelledBookings.length),
          ),
        ],
      ),
    );
  }

  // FIXED: Use Flexible to prevent Tab label overflow
  Widget _buildTabLabel(String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
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
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildBookingsList(_allBookings, 'No bookings yet'),
        _buildBookingsList(_upcomingBookings, 'No upcoming bookings'),
        _buildBookingsList(_completedBookings, 'No completed bookings'),
        _buildBookingsList(_cancelledBookings, 'No cancelled bookings'),
      ],
    );
  }

  Widget _buildBookingsList(List<BookingWithVenue> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: _loadMyBookings,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppTheme.paddingM),
        itemCount: bookings.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == bookings.length) {
            return _buildLoadingMoreIndicator();
          }
          return _buildBookingCard(bookings[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingWithVenue bookingWithVenue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBookingHeader(bookingWithVenue),
          const Divider(height: 1),
          _buildBookingDetails(bookingWithVenue),
          _buildBookingActions(bookingWithVenue.booking),
        ],
      ),
    );
  }

  Widget _buildBookingHeader(BookingWithVenue bookingWithVenue) {
    final booking = bookingWithVenue.booking;
    final venue = bookingWithVenue.venue;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildVenueIcon(),
          const SizedBox(width: 12),

          // FIXED: make text area take available space and ellipsize
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue?.name ?? 'Venue Name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.court?.name ??
                      'Court ${booking.court?.courtNumber ?? ""}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // FIXED: constrain status badge so it won't push layout
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: _buildStatusBadge(booking.status),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: const Icon(
        Icons.sports_soccer,
        color: AppTheme.primaryColor,
        size: 28,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toUpperCase()) {
      case 'PENDING':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        displayText = 'Pending';
        break;
      case 'CONFIRMED':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        displayText = 'Confirmed';
        break;
      case 'COMPLETED':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        displayText = 'Completed';
        break;
      case 'CANCELLED':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBookingDetails(BookingWithVenue bookingWithVenue) {
    final booking = bookingWithVenue.booking;
    final venue = bookingWithVenue.venue;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.calendar_today,
            'Date',
            DateFormat('EEEE, MMMM d, y').format(booking.bookingDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time,
            'Time',
            '${booking.startTime} - ${booking.endTime}',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.location_on,
            'Location',
            '${venue?.address ?? ''}${venue?.city != null && venue!.city!.isNotEmpty ? ', ${venue.city}' : ''}',
          ),
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.note,
              'Notes',
              booking.notes!,
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${booking.totalAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBadge(String paymentStatus) {
    final isPaid = paymentStatus.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            size: 16,
            color: isPaid ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isPaid ? 'Paid' : 'Unpaid',
            style: TextStyle(
              color: isPaid ? Colors.green : Colors.orange,
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
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusM),
          bottomRight: Radius.circular(AppTheme.radiusM),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _handleCancelBooking(booking),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: const BorderSide(color: Colors.red),
            foregroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
          ),
          child: const Text('Cancel Booking'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to browse courts
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            child: const Text('Browse Courts'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    if (!_hasMoreData) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No more bookings to load',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _isLoadingMore ? const CircularProgressIndicator() : const SizedBox.shrink(),
      ),
    );
  }

  String _formatBookingType(String bookingType) {
    switch (bookingType.toUpperCase()) {
      case 'FULL_TEAM':
        return 'Full Team';
      case 'PARTIAL_TEAM':
        return 'Partial Team';
      case 'SOLO':
        return 'Solo';
      default:
        return bookingType;
    }
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending Confirmation';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Future<void> _handleCancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload bookings
        _loadMyBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Mock data generator (remove in production)
  List<BookingWithVenue> _generateMockBookingsWithVenues() {
    final now = DateTime.now();

    // Mock venues
    final venue1 = Venue(
      id: 'venue_1',
      name: 'City Sports Arena With A Very Long Name To Test Ellipsis',
      address: 'Koteshwor',
      city: 'Kathmandu',
      description: 'Premium futsal courts',
      phoneNumber: '9801234567',
      email: 'info@citysports.com',
      rating: 4.5,
      totalReviews: 120,
      isActive: true,
      ownerId: 'owner_1',
      amenities: ['Parking', 'Changing Room', 'Cafe'],
      images: ['https://example.com/image1.jpg'],
    );

    final venue2 = Venue(
      id: 'venue_2',
      name: 'Green Field Futsal',
      address: 'Pulchowk',
      city: 'Lalitpur',
      description: 'Best futsal in town',
      phoneNumber: '9807654321',
      rating: 4.8,
      totalReviews: 85,
      isActive: true,
      ownerId: 'owner_2',
      amenities: ['Parking', 'Shower'],
      images: ['https://example.com/image2.jpg'],
    );

    // Mock courts
    final court1 = Court(
      id: 'court_1',
      name: 'Court A With A Long Name',
      courtNumber: 'A',
      size: '5v5',
      hourlyRate: 2000,
      isActive: true,
      maxPlayers: 10,
      futsalCourtId: venue1.id,
      description: 'Main court',
    );

    final court2 = Court(
      id: 'court_2',
      name: 'Court B',
      courtNumber: 'B',
      size: '7v7',
      hourlyRate: 3000,
      isActive: true,
      maxPlayers: 14,
      futsalCourtId: venue2.id,
      description: 'Large court',
    );

    // Mock bookings
    final bookings = [
      BookingWithVenue(
        booking: Booking(
          id: '1',
          courtId: court1.id,
          userId: 'user_1',
          bookingDate: now.add(const Duration(days: 2)),
          startTime: '11:00',
          endTime: '12:00',
          totalAmount: 2000,
          status: 'PENDING',
          notes: 'Morning session',
          court: court1,
          createdAt: now,
          updatedAt: now,
        ),
        venue: venue1,
      ),
      BookingWithVenue(
        booking: Booking(
          id: '2',
          courtId: court2.id,
          userId: 'user_1',
          bookingDate: now.subtract(const Duration(days: 5)),
          startTime: '18:00',
          endTime: '19:30',
          totalAmount: 3000,
          status: 'COMPLETED',
          notes: null,
          court: court2,
          createdAt: now.subtract(const Duration(days: 6)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
        venue: venue2,
      ),
      BookingWithVenue(
        booking: Booking(
          id: '3',
          courtId: court1.id,
          userId: 'user_1',
          bookingDate: now.add(const Duration(days: 5)),
          startTime: '15:00',
          endTime: '16:00',
          totalAmount: 2000,
          status: 'CONFIRMED',
          notes: 'Afternoon game',
          court: court1,
          createdAt: now,
          updatedAt: now,
        ),
        venue: venue1,
      ),
      BookingWithVenue(
        booking: Booking(
          id: '4',
          courtId: court2.id,
          userId: 'user_1',
          bookingDate: now.subtract(const Duration(days: 2)),
          startTime: '20:00',
          endTime: '21:00',
          totalAmount: 2500,
          status: 'CANCELLED',
          notes: 'Bad weather',
          court: court2,
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        venue: venue2,
      ),
    ];

    return bookings;
  }
}

// ============================================================================
// Helper class to pair booking with venue data
// ============================================================================
class BookingWithVenue {
  final Booking booking;
  final Venue? venue;

  const BookingWithVenue({
    required this.booking,
    this.venue,
  });
}