import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String mode; // PLAYER, OWNER, ADMIN
  final String? phoneNumber;
  final String? ownerStatus; // DRAFT, PENDING, APPROVED, REJECTED, INACTIVE
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
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'PLAYER',
      // Use mode from response, or default based on role
      // Note: mode can be PLAYER even if role is OWNER (when owner mode is deactivated)
      mode: json['mode']?.toString().toUpperCase() ?? 
            (json['role']?.toString().toUpperCase() == 'ADMIN' ? 'ADMIN' : 
             (json['role']?.toString().toUpperCase() == 'OWNER' ? 'OWNER' : 'PLAYER')),
      phoneNumber: json['phoneNumber'],
      ownerStatus: json['ownerStatus']?.toString().toUpperCase(),
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