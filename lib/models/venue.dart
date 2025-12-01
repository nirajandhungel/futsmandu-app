import 'package:equatable/equatable.dart';
import 'court.dart';

class Venue extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String? description;
  final String? phoneNumber;
  final String? email;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int? totalReviews;
  final bool isActive;
  final String ownerId;
  final List<String>? amenities;
  final List<String>? images;
  final List<Court>? courts;
  final DateTime? createdAt;

  const Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.description,
    this.phoneNumber,
    this.email,
    this.latitude,
    this.longitude,
    this.rating,
    this.totalReviews,
    required this.isActive,
    required this.ownerId,
    this.amenities,
    this.images,
    this.courts,
    this.createdAt,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      description: json['description'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      rating: json['rating']?.toDouble(),
      totalReviews: json['totalReviews'],
      isActive: json['isActive'] ?? true,
      ownerId: json['ownerId'] ?? '',
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      courts: json['courts'] != null
          ? (json['courts'] as List).map((c) => Court.fromJson(c)).toList()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'description': description,
      'phoneNumber': phoneNumber,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'totalReviews': totalReviews,
      'isActive': isActive,
      'ownerId': ownerId,
      'amenities': amenities,
      'images': images,
      'courts': courts?.map((c) => c.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Venue copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? description,
    String? phoneNumber,
    String? email,
    double? latitude,
    double? longitude,
    double? rating,
    int? totalReviews,
    bool? isActive,
    String? ownerId,
    List<String>? amenities,
    List<String>? images,
    List<Court>? courts,
    DateTime? createdAt,
  }) {
    return Venue(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      description: description ?? this.description,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isActive: isActive ?? this.isActive,
      ownerId: ownerId ?? this.ownerId,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      courts: courts ?? this.courts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    city,
    description,
    phoneNumber,
    email,
    latitude,
    longitude,
    rating,
    totalReviews,
    isActive,
    ownerId,
    amenities,
    images,
    courts,
    createdAt,
  ];
}