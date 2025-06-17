import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String? name;
  final String? contact;
  final String? profilePictureUrl;
  final String userType; // Made required and not nullable
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    this.name,
    this.contact,
    this.profilePictureUrl,
    required this.userType, // Required parameter
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String?,
      contact: json['contact'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      userType: json['userType'] as String? ?? 'patient', // Default to patient if null
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact': contact,
      'profilePictureUrl': profilePictureUrl,
      'userType': userType,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? contact,
    String? profilePictureUrl,
    String? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      contact: contact ?? this.contact,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to create a new patient profile
  factory UserProfile.createPatient({
    String? name,
    String? contact,
    String? profilePictureUrl,
  }) {
    return UserProfile(
      name: name,
      contact: contact,
      profilePictureUrl: profilePictureUrl,
      userType: 'patient',
    );
  }

  // Helper methods for user type checking
  bool get isPatient => userType == 'patient';
  bool get isDoctor => userType == 'doctor';
  bool get isAdmin => userType == 'admin';
}