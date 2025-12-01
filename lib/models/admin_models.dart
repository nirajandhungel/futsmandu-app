class DashboardStats {
  final int totalUsers;
  final int totalOwners;
  final int totalVenues;
  final int totalBookings;
  final int pendingOwnerRequests;

  DashboardStats({
    required this.totalUsers,
    required this.totalOwners,
    required this.totalVenues,
    required this.totalBookings,
    required this.pendingOwnerRequests,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalOwners: json['totalOwners'] ?? 0,
      totalVenues: json['totalVenues'] ?? 0,
      totalBookings: json['totalBookings'] ?? 0,
      pendingOwnerRequests: json['pendingOwnerRequests'] ?? 0,
    );
  }
}

class PendingOwner {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? panNumber;
  final String? address;
  final String? profilePhotoUrl;
  final String? citizenshipFrontUrl;
  final String? citizenshipBackUrl;
  final String status;

  PendingOwner({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.panNumber,
    this.address,
    this.profilePhotoUrl,
    this.citizenshipFrontUrl,
    this.citizenshipBackUrl,
    required this.status,
  });

  factory PendingOwner.fromJson(Map<String, dynamic> json) {
    return PendingOwner(
      id: json['id'] ?? json['_id'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      panNumber: json['panNumber'],
      address: json['address'],
      profilePhotoUrl: json['profilePhotoUrl'],
      citizenshipFrontUrl: json['citizenshipFrontUrl'],
      citizenshipBackUrl: json['citizenshipBackUrl'],
      status: json['status'] ?? 'PENDING',
    );
  }
}

class UserData {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final bool isActive;

  UserData({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.isActive,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? json['_id'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      isActive: json['isActive'] ?? true,
    );
  }
}

class VenueData {
  final String id;
  final String name;
  final VenueLocation location;
  final bool isVerified;
  final bool isActive;
  final double? rating;

  VenueData({
    required this.id,
    required this.name,
    required this.location,
    required this.isVerified,
    required this.isActive,
    this.rating,
  });

  factory VenueData.fromJson(Map<String, dynamic> json) {
    return VenueData(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      location: VenueLocation.fromJson(json['location']),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      rating: json['rating']?.toDouble(),
    );
  }
}

class VenueLocation {
  final String address;
  final String city;
  final String? state;

  VenueLocation({
    required this.address,
    required this.city,
    this.state,
  });

  factory VenueLocation.fromJson(Map<String, dynamic> json) {
    return VenueLocation(
      address: json['address'],
      city: json['city'],
      state: json['state'],
    );
  }
}