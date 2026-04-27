import 'package:equatable/equatable.dart';

/// Model untuk User
/// Merepresentasikan data pengguna yang diterima dari backend
class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final double? weight;
  final double? height;
  final int? age;
  final bool isBreastfeeding;
  final String activityLevel;
  final String? profileImageUrl;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.weight,
    this.height,
    this.age,
    this.isBreastfeeding = false,
    this.activityLevel = 'sedentary',
    this.profileImageUrl,
    this.timezone = 'WIB',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      age: json['age'] as int?,
      isBreastfeeding: json['is_breastfeeding'] as bool? ?? false,
      activityLevel: json['activity_level'] as String? ?? 'sedentary',
      profileImageUrl: json['profile_image_url'] as String?,
      timezone: json['timezone'] as String? ?? 'WIB',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'weight': weight,
      'height': height,
      'age': age,
      'is_breastfeeding': isBreastfeeding,
      'activity_level': activityLevel,
      'profile_image_url': profileImageUrl,
      'timezone': timezone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    double? weight,
    double? height,
    int? age,
    bool? isBreastfeeding,
    String? activityLevel,
    String? profileImageUrl,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      isBreastfeeding: isBreastfeeding ?? this.isBreastfeeding,
      activityLevel: activityLevel ?? this.activityLevel,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        weight,
        height,
        age,
        isBreastfeeding,
        activityLevel,
        profileImageUrl,
        timezone,
        createdAt,
        updatedAt,
      ];
}
