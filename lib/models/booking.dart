import 'package:equatable/equatable.dart';
import 'user.dart';
import 'court.dart';
import 'venue.dart';

class Booking extends Equatable {
  final String id;
  final String courtId;
  final String userId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String? notes;
  final Court? court;
  final Venue? venue;
  final User? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.courtId,
    required this.userId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.status,
    this.paymentStatus = 'unpaid',
    this.notes,
    this.court,
    this.venue,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? json['_id'] ?? '',
      courtId: json['courtId'] ?? '',
      userId: json['userId'] ?? json['createdBy'] ?? '',
      bookingDate: DateTime.parse(json['date'] ?? json['bookingDate']),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      paymentStatus: json['paymentStatus'] ?? 'unpaid',
      notes: json['notes'],
      court: json['court'] != null ? Court.fromJson(json['court']) : null,
      venue: json['venue'] != null ? Venue.fromJson(json['venue']) : null,
      user: json['user'] != null 
          ? User.fromJson(json['user']) 
          : (json['creator'] != null ? User.fromJson(json['creator']) : null),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courtId': courtId,
      'userId': userId,
      'date': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'court': court?.toJson(),
      'venue': venue?.toJson(),
      'user': user?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? courtId,
    String? userId,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    double? totalAmount,
    String? status,
    String? paymentStatus,
    String? notes,
    Court? court,
    Venue? venue,
    User? user,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      courtId: courtId ?? this.courtId,
      userId: userId ?? this.userId,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      court: court ?? this.court,
      venue: venue ?? this.venue,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isCompleted => status == 'COMPLETED';

  @override
  List<Object?> get props => [
    id,
    courtId,
    userId,
    bookingDate,
    startTime,
    endTime,
    totalAmount,
    status,
    notes,
    court,
    venue,
    user,
    createdAt,
    updatedAt,
  ];
}

class CreateBookingRequest {
  final String courtId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final String bookingType;
  final String? groupType;
  final int? maxPlayers;
  final String? notes;

  const CreateBookingRequest({
    required this.courtId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.bookingType,
    this.groupType,
    this.maxPlayers,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'courtId': courtId,
      'date': bookingDate.toIso8601String(), // Send full ISO string to include time component if possible
      'startTime': startTime,
      'endTime': endTime,
      'bookingType': bookingType,
      'groupType': groupType,
      'maxPlayers': maxPlayers,
      'notes': notes,
    };
  }
}