import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading.dart';
import '../../models/booking.dart';
import 'package:intl/intl.dart';

class JoinTeammatesScreen extends StatefulWidget {
  const JoinTeammatesScreen({super.key});

  @override
  State<JoinTeammatesScreen> createState() => _JoinTeammatesScreenState();
}

class _JoinTeammatesScreenState extends State<JoinTeammatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJoinableBookings();
    });
  }

  Future<void> _loadJoinableBookings() async {
    await context.read<BookingProvider>().getJoinableBookings();
  }

  Future<void> _joinBooking(String bookingId) async {
    try {
      Helpers.showLoadingDialog(context);
      
      // Use BookingService directly as requested
      final bookingService = BookingService();
      await bookingService.joinBooking(bookingId);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Helpers.showSnackbar(context, 'Joined booking successfully!');
        // Refresh the list through provider to update UI
        _loadJoinableBookings();
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context); // Close loading dialog
        
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        // Check for specific backend error messages implying already joined
        if (errorMessage.toLowerCase().contains('already') || 
            errorMessage.toLowerCase().contains('exist')) {
          errorMessage = 'You have already booked this game!';
        }
        
        Helpers.showSnackbar(
          context, 
          errorMessage,
          isError: true,
        );
      }
    }
  }

  Future<void> _leaveBooking(String bookingId) async {
     final success = await context.read<BookingProvider>().leaveBooking(bookingId);
    if (mounted) {
      if (success) {
        Helpers.showSnackbar(context, 'Left booking successfully!');
      } else {
        Helpers.showSnackbar(
          context, 
          context.read<BookingProvider>().errorMessage ?? 'Failed to leave booking',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Join Teammates'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJoinableBookings,
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.joinableBookings.isEmpty) {
            return const LoadingWidget(message: 'Finding active games...');
          }

          if (provider.joinableBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No open games to join at the moment.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                     onPressed: _loadJoinableBookings,
                     child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingM),
            itemCount: provider.joinableBookings.length,
            itemBuilder: (context, index) {
              final booking = provider.joinableBookings[index];
              return _buildBookingCard(booking, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, BuildContext context) {
    final userId = context.read<AuthProvider>().user?.id;
    final isAlreadyJoined = booking.connectedBookingUsers?.any((u) => u.id == userId) ?? false;
    final isCreator = booking.userId == userId;
    final maxPlayers = booking.maxPlayers ?? 10; // Default or from model
    final currentPlayers = (booking.connectedBookingUsers?.length ?? 0); // +1 for creator usually, but API depends
    final isFull = currentPlayers >= maxPlayers;

    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a'); // Assuming startTime is String HH:mm, we might parse it manually or if it is DateTime

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.venue?.name ?? 'Unknown Venue',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            booking.venue?.city ?? 'City',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFull ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isFull ? Colors.red : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isFull ? 'FULL' : 'OPEN',
                    style: TextStyle(
                      color: isFull ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today, 
                    dateFormat.format(booking.bookingDate),
                    'Date',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.access_time, 
                    '${booking.startTime} - ${booking.endTime}',  // Using raw strings as per model
                    'Time',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.group, 
                    '$currentPlayers / $maxPlayers',
                    'Players',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: isCreator 
                ? OutlinedButton(
                    onPressed: null,
                    child: const Text('You created this game'),
                  )
                : isAlreadyJoined
                  ? OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => _leaveBooking(booking.id),
                      child: const Text('Leave Game'),
                    )
                  : ElevatedButton(
                      onPressed: isFull ? null : () => _joinBooking(booking.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isFull ? 'Game Full' : 'Join Team'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
