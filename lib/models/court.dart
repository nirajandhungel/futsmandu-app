import 'package:equatable/equatable.dart';

class Court extends Equatable {
  final String id;
  final String name;
  final String courtNumber;
  final String size;
  final double hourlyRate;
  final bool isActive;
  final int maxPlayers;
  final String? futsalCourtId;
  final String? description;
  final DateTime? createdAt;
  final List<String>? amenities;
  final List<String>? images;

  const Court({
    required this.id,
    required this.name,
    required this.courtNumber,
    required this.size,
    required this.hourlyRate,
    required this.isActive,
    required this.maxPlayers,
    this.futsalCourtId,
    this.description,
    this.createdAt,
    this.amenities,
    this.images,
  });

  factory Court.empty() {
    return const Court(
      id: '',
      name: '',
      courtNumber: '',
      size: '5v5',
      hourlyRate: 0.0,
      isActive: false,
      maxPlayers: 10,
    );
  }

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      courtNumber: json['courtNumber'] ?? '',
      size: json['size'] ?? '5v5',
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      maxPlayers: json['maxPlayers'] ?? 10,
      futsalCourtId: json['futsalCourtId'],
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courtNumber': courtNumber,
      'size': size,
      'hourlyRate': hourlyRate,
      'isActive': isActive,
      'maxPlayers': maxPlayers,
      'futsalCourtId': futsalCourtId,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'amenities': amenities,
      'images': images,
    };
  }

  Court copyWith({
    String? id,
    String? name,
    String? courtNumber,
    String? size,
    double? hourlyRate,
    bool? isActive,
    int? maxPlayers,
    String? futsalCourtId,
    String? description,
    DateTime? createdAt,
    List<String>? amenities,
    List<String>? images,
  }) {
    return Court(
      id: id ?? this.id,
      name: name ?? this.name,
      courtNumber: courtNumber ?? this.courtNumber,
      size: size ?? this.size,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isActive: isActive ?? this.isActive,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      futsalCourtId: futsalCourtId ?? this.futsalCourtId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    courtNumber,
    size,
    hourlyRate,
    isActive,
    maxPlayers,
    futsalCourtId,
    description,
    createdAt,
    amenities,
    images,
  ];
}

class CourtAvailability {
  final String courtId;
  final DateTime date;
  final List<TimeSlot> availableSlots;

  const CourtAvailability({
    required this.courtId,
    required this.date,
    required this.availableSlots,
  });

  factory CourtAvailability.fromJson(Map<String, dynamic> json) {
    return CourtAvailability(
      courtId: json['courtId'] ?? '',
      date: DateTime.parse(json['date']),
      availableSlots: (json['availableSlots'] as List?)
          ?.map((slot) => TimeSlot.fromJson(slot))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courtId': courtId,
      'date': date.toIso8601String(),
      'availableSlots': availableSlots.map((slot) => slot.toJson()).toList(),
    };
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isAvailable;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }
}