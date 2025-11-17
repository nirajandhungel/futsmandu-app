import 'package:equatable/equatable.dart';
import 'user.dart';
import 'court.dart';

class Booking extends Equatable {
  final String id;
  final String courtId;
  final String userId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final String status;
  final String? notes;
  final Court? court;
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
    this.notes,
    this.court,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      courtId: json['courtId'] ?? '',
      userId: json['userId'] ?? '',
      bookingDate: DateTime.parse(json['bookingDate']),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      notes: json['notes'],
      court: json['court'] != null ? Court.fromJson(json['court']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
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
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'totalAmount': totalAmount,
      'status': status,
      'notes': notes,
      'court': court?.toJson(),
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
    String? notes,
    Court? court,
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
      notes: notes ?? this.notes,
      court: court ?? this.court,
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
  final String? notes;

  const CreateBookingRequest({
    required this.courtId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'courtId': courtId,
      'bookingDate': bookingDate.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes,
    };
  }
}