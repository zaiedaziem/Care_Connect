import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String? doctorId;
  final String fullName;
  final String specialty;
  final String clinic;
  final String email;
  final String phone;
  final String? imageUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Doctor({
    this.doctorId,
    required this.fullName,
    required this.specialty,
    required this.clinic,
    required this.email,
    required this.phone,
    this.imageUrl,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
  });

  // For Firestore deserialization
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorId: json['doctorId'] as String?,
      fullName: json['fullName'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      clinic: json['clinic'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String? ?? 'Active',
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // For Firestore serialization
  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'fullName': fullName,
      'specialty': specialty,
      'clinic': clinic,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with new values
  Doctor copyWith({
    String? doctorId,
    String? fullName,
    String? specialty,
    String? clinic,
    String? email,
    String? phone,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      doctorId: doctorId ?? this.doctorId,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      clinic: clinic ?? this.clinic,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for status checking
  bool get isActive => status == 'Active';
  bool get isInactive => status == 'Inactive';
  
  // Factory method to create a new doctor
  factory Doctor.create({
    required String fullName,
    required String specialty,
    required String clinic,
    required String email,
    required String phone,
    String? imageUrl,
    String status = 'Active',
  }) {
    return Doctor(
      fullName: fullName,
      specialty: specialty,
      clinic: clinic,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}