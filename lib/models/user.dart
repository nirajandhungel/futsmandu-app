import 'package:equatable/equatable.dart';

class OwnerProfile extends Equatable {
  final String? panNumber;
  final String? address;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final String? citizenshipFrontUrl;
  final String? citizenshipBackUrl;
  final Map<String, dynamic>? additionalKyc;
  final String? status;
  final DateTime? lastSubmittedAt;

  const OwnerProfile({
    this.panNumber,
    this.address,
    this.phoneNumber,
    this.profilePhotoUrl,
    this.citizenshipFrontUrl,
    this.citizenshipBackUrl,
    this.additionalKyc,
    this.status,
    this.lastSubmittedAt,
  });

  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    return OwnerProfile(
      panNumber: json['panNumber'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      profilePhotoUrl: json['profilePhotoUrl'],
      citizenshipFrontUrl: json['citizenshipFrontUrl'],
      citizenshipBackUrl: json['citizenshipBackUrl'],
      additionalKyc: json['additionalKyc'] != null
          ? Map<String, dynamic>.from(json['additionalKyc'])
          : null,
      status: json['status'],
      lastSubmittedAt: json['lastSubmittedAt'] != null
          ? DateTime.parse(json['lastSubmittedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'panNumber': panNumber,
      'address': address,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': profilePhotoUrl,
      'citizenshipFrontUrl': citizenshipFrontUrl,
      'citizenshipBackUrl': citizenshipBackUrl,
      'additionalKyc': additionalKyc,
      'status': status,
      'lastSubmittedAt': lastSubmittedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        panNumber,
        address,
        phoneNumber,
        profilePhotoUrl,
        citizenshipFrontUrl,
        citizenshipBackUrl,
        additionalKyc,
        status,
        lastSubmittedAt,
      ];
}

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String mode; // PLAYER, OWNER, ADMIN
  final String? phoneNumber;
  final String? ownerStatus; // DRAFT, PENDING, APPROVED, REJECTED, INACTIVE
  final OwnerProfile? ownerProfile;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.mode,
    this.phoneNumber,
    this.ownerStatus,
    this.ownerProfile,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory User.empty() {
    return const User(
      id: '',
      email: '',
      fullName: '',
      role: 'PLAYER',
      mode: 'PLAYER',
      isActive: false,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'PLAYER',
      mode: json['mode']?.toString().toUpperCase() ??
          (json['role']?.toString().toUpperCase() == 'ADMIN'
              ? 'ADMIN'
              : (json['role']?.toString().toUpperCase() == 'OWNER'
                  ? 'OWNER'
                  : 'PLAYER')),
      phoneNumber: json['phoneNumber'],
      ownerStatus: json['ownerStatus']?.toString().toUpperCase(),
      ownerProfile: json['ownerProfile'] != null
          ? OwnerProfile.fromJson(json['ownerProfile'])
          : null,
      isActive: json['isActive'] ?? true,
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
      'email': email,
      'fullName': fullName,
      'role': role,
      'mode': mode,
      'phoneNumber': phoneNumber,
      'ownerStatus': ownerStatus,
      'ownerProfile': ownerProfile?.toJson(),
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? mode,
    String? phoneNumber,
    String? ownerStatus,
    OwnerProfile? ownerProfile,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      mode: mode ?? this.mode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      ownerStatus: ownerStatus ?? this.ownerStatus,
      ownerProfile: ownerProfile ?? this.ownerProfile,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPlayer => role == 'PLAYER';
  bool get isOwner => role == 'OWNER';
  bool get isAdmin => role == 'ADMIN';
  
  // Mode-based getters (separate from role)
  bool get isInPlayerMode => mode == 'PLAYER';
  bool get isInOwnerMode => mode == 'OWNER';
  bool get isInAdminMode => mode == 'ADMIN';
  
  // Owner status getters
  bool get hasOwnerProfile => ownerStatus != null;
  bool get isOwnerApproved => ownerStatus == 'APPROVED';
  bool get isOwnerPending => ownerStatus == 'PENDING';
  bool get isOwnerRejected => ownerStatus == 'REJECTED';
  bool get isOwnerDraft => ownerStatus == 'DRAFT';
  bool get isOwnerNotVerified => ownerStatus == null || 
                                  ownerStatus == 'PENDING' || 
                                  ownerStatus == 'DRAFT' || 
                                  ownerStatus == 'REJECTED';

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    role,
    mode,
    phoneNumber,
    ownerStatus,
    ownerProfile,
    isActive,
    createdAt,
    updatedAt,
  ];
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class AuthResponse {
  final User user;
  final AuthTokens tokens;

  const AuthResponse({
    required this.user,
    required this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      tokens: AuthTokens.fromJson(json['tokens']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
    };
  }
}