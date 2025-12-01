import 'package:flutter/material.dart';
import '../../models/venue.dart';
import '../../models/court.dart';
import '../../utils/theme.dart';
import 'package:intl/intl.dart';

// HOW TO USE:
// In your VenueDetailScreen's "Book Now" button:
//
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => BookingScreen(venue: venue),
//   ),
// );

class BookingScreen extends StatefulWidget {
  final Venue venue;

  const BookingScreen({
    super.key,
    required this.venue,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0;

  // Form data
  Court? _selectedCourt;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _bookingType = 'FULL_TEAM';
  String _groupType = 'private';
  int _maxPlayers = 10;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Court'),
        elevation: 0,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                    ),
                    child: Text(
                      _currentStep == 3 ? 'Confirm Booking' : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Step 1: Select Court
          Step(
            title: const Text('Select Court'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildCourtSelection(),
          ),
          // Step 2: Select Date & Time
          Step(
            title: const Text('Date & Time'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildDateTimeSelection(),
          ),
          // Step 3: Booking Type
          Step(
            title: const Text('Booking Details'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: _buildBookingTypeSelection(),
          ),
          // Step 4: Review
          Step(
            title: const Text('Review'),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
            content: _buildReviewSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtSelection() {
    if (widget.venue.courts == null || widget.venue.courts!.isEmpty) {
      return const Center(
        child: Text('No courts available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.venue.courts!.map((court) {
        final isSelected = _selectedCourt?.id == court.id;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCourt = court;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sports_soccer,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        court.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (court.size != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          court.size!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${court.hourlyRate.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      'per hour',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selection
        Text(
          'Select Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Time Selection
        Text(
          'Select Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Start Time
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime ?? const TimeOfDay(hour: 18, minute: 0),
                  );
                  if (time != null) {
                    setState(() {
                      _startTime = time;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _startTime?.format(context) ?? 'Select',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // End Time
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime ?? const TimeOfDay(hour: 19, minute: 0),
                  );
                  if (time != null) {
                    setState(() {
                      _endTime = time;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _endTime?.format(context) ?? 'Select',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Booking Type
        Text(
          'Booking Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildBookingTypeOption(
          'FULL_TEAM',
          'Full Team',
          'Book the entire court for your team',
          Icons.groups,
        ),
        _buildBookingTypeOption(
          'PARTIAL_TEAM',
          'Partial Team',
          'Book with partial team, others can join',
          Icons.group_add,
        ),
        _buildBookingTypeOption(
          'SOLO',
          'Solo',
          'Book individually and join others',
          Icons.person,
        ),
        const SizedBox(height: 24),

        // Group Type (if not SOLO)
        if (_bookingType != 'SOLO') ...[
          Text(
            'Group Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGroupTypeOption(
                  'private',
                  'Private',
                  Icons.lock,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGroupTypeOption(
                  'public',
                  'Public',
                  Icons.public,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // Max Players (if FULL_TEAM or PARTIAL_TEAM)
        if (_bookingType == 'FULL_TEAM' || _bookingType == 'PARTIAL_TEAM') ...[
          Text(
            'Maximum Players',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_maxPlayers > 2) {
                    setState(() {
                      _maxPlayers--;
                    });
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: AppTheme.primaryColor,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Text(
                    '$_maxPlayers players',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_maxPlayers < 22) {
                    setState(() {
                      _maxPlayers++;
                    });
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBookingTypeOption(
      String value,
      String title,
      String subtitle,
      IconData icon,
      ) {
    final isSelected = _bookingType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _bookingType = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTypeOption(String value, String title, IconData icon) {
    final isSelected = _groupType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _groupType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    final hours = _calculateHours();
    final totalAmount = _selectedCourt != null ? _selectedCourt!.hourlyRate * hours : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem(
          'Venue',
          widget.venue.name,
          Icons.location_city,
        ),
        _buildReviewItem(
          'Court',
          _selectedCourt?.name ?? 'Not selected',
          Icons.sports_soccer,
        ),
        _buildReviewItem(
          'Date',
          DateFormat('EEEE, MMMM d, y').format(_selectedDate),
          Icons.calendar_today,
        ),
        _buildReviewItem(
          'Time',
          '${_startTime?.format(context) ?? '--:--'} - ${_endTime?.format(context) ?? '--:--'}',
          Icons.access_time,
        ),
        _buildReviewItem(
          'Duration',
          '$hours hour${hours != 1 ? 's' : ''}',
          Icons.timer,
        ),
        _buildReviewItem(
          'Booking Type',
          _getBookingTypeLabel(),
          Icons.people,
        ),
        if (_bookingType != 'SOLO')
          _buildReviewItem(
            'Group Type',
            _groupType == 'private' ? 'Private' : 'Public',
            _groupType == 'private' ? Icons.lock : Icons.public,
          ),
        if (_bookingType != 'SOLO')
          _buildReviewItem(
            'Max Players',
            '$_maxPlayers players',
            Icons.group,
          ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Rs. ${totalAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      // Validate court selection
      if (_selectedCourt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a court')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      // Validate date and time
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end time')),
        );
        return;
      }
      if (_isEndTimeBeforeStartTime()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
        return;
      }
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      // Final step - Create booking
      _createBooking();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  bool _isEndTimeBeforeStartTime() {
    if (_startTime == null || _endTime == null) return false;
    final start = _startTime!.hour * 60 + _startTime!.minute;
    final end = _endTime!.hour * 60 + _endTime!.minute;
    return end <= start;
  }

  double _calculateHours() {
    if (_startTime == null || _endTime == null) return 0;
    final start = _startTime!.hour * 60 + _startTime!.minute;
    final end = _endTime!.hour * 60 + _endTime!.minute;
    return (end - start) / 60;
  }

  String _getBookingTypeLabel() {
    switch (_bookingType) {
      case 'FULL_TEAM':
        return 'Full Team';
      case 'PARTIAL_TEAM':
        return 'Partial Team';
      case 'SOLO':
        return 'Solo';
      default:
        return '';
    }
  }

  Future<void> _createBooking() async {
    setState(() {
      _isLoading = true;
    });

    // Prepare booking data - EXACTLY matching backend requirements
    final bookingData = {
      'courtId': _selectedCourt!.id,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'startTime': '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
      'endTime': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
      'bookingType': _bookingType,
      'groupType': _groupType,
      'maxPlayers': _maxPlayers,
    };

    print('Booking Data: $bookingData'); // For debugging

    // TODO: Call your API here
    // Example:
    // try {
    //   final response = await ApiService.createBooking(bookingData);
    //   if (response.success) {
    //     // Show success dialog
    //   }
    // } catch (e) {
    //   // Show error message
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Error: ${e.toString()}')),
    //     );
    //   }
    // }

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          title: const Text('Booking Created!'),
          content: const Text(
            'Your booking has been created successfully. Please complete the payment to confirm your booking.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate back to home or bookings page
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }
}