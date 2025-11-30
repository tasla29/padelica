import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a UserModel from Supabase Auth User and public.users profile data
  factory UserModel.fromSupabase(User user, Map<String, dynamic> profile) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      firstName: profile['first_name'] as String? ?? '',
      lastName: profile['last_name'] as String? ?? '',
      phone: profile['phone'] as String? ?? '',
      role: profile['role'] as String? ?? 'player',
      createdAt: profile['created_at'] != null 
          ? DateTime.parse(profile['created_at'] as String)
          : DateTime.now(),
      updatedAt: profile['updated_at'] != null 
          ? DateTime.parse(profile['updated_at'] as String)
          : DateTime.now(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '$firstName $lastName';
  
  bool get isAdmin => role == 'admin';
  bool get isStaff => role == 'staff' || role == 'admin';
}

