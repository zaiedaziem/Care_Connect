import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/doctor.dart';
import '../models/user_profile.dart';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _doctorCollection =
      FirebaseFirestore.instance.collection('doctors');
  final CollectionReference _counterCollection =
      FirebaseFirestore.instance.collection('counters');

// Generate next doctor ID   
Future<String> _generateDoctorId() async {
  final DocumentReference counterDoc = _counterCollection.doc('doctorCounter');
       
  try {
    return await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(counterDoc);
               
      int currentCount = 0;
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        currentCount = data['count'] ?? 0;
      }
               
      final int newCount = currentCount + 1;
      final String newDoctorId = 'DR${newCount.toString().padLeft(3, '0')}';
               
      // Update the counter
      transaction.set(counterDoc, {'count': newCount}, SetOptions(merge: true));
               
      return newDoctorId;
    });
  } catch (e) {
    throw Exception('Failed to generate doctor ID: ${e.toString()}');
  }
}

// Convert XFile image to base64 string
Future<String?> _uploadImage(String userId, XFile? imageFile) async {
  try {
    if (imageFile == null) return null;
    
    // Read image as bytes
    final bytes = await imageFile.readAsBytes();
    
    // Convert to base64 string
    final base64Image = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64Image';
  } catch (e) {
    throw Exception('Failed to convert image to base64: ${e.toString()}');
  }
}

  // Register doctor with authentication and profile
  Future<UserCredential?> registerDoctor({
    required String email,
    required String password,
    required String fullName,
    required String specialty,
    required String clinic,
    required String phone,
    XFile? imageFile,
    String status = 'Active',
  }) async {
    try {
      // Create Firebase Auth account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Generate doctor ID
        String doctorId = await _generateDoctorId();
        
        // Convert image to base64 if provided
        String? imageUrl;
        if (imageFile != null) {
          imageUrl = await _uploadImage(result.user!.uid, imageFile);
        }

        // Create doctor profile
        final doctor = Doctor.create(
          fullName: fullName,
          specialty: specialty,
          clinic: clinic,
          email: email,
          phone: phone,
          imageUrl: imageUrl,
          status: status,
        ).copyWith(doctorId: doctorId);

        // Save doctor profile to doctors collection
        await _doctorCollection.doc(result.user!.uid).set(doctor.toJson());

        // Create user profile with doctor type
        final userProfile = UserProfile(
          name: fullName,
          contact: phone,
          profilePictureUrl: imageUrl,
          userType: 'doctor',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save user profile to users collection
        await _firestore.collection('users').doc(result.user!.uid).set(userProfile.toJson());
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // If user was created but profile creation failed, delete the user
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }
      throw Exception('Failed to create doctor profile: ${e.toString()}');
    }
  }

  // Create a doctor profile (without authentication)
  Future<void> createDoctor(Doctor doctor, {XFile? imageFile}) async {
    try {
      String doctorId = await _generateDoctorId();
      
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(doctorId, imageFile);
      }
      
      Doctor doctorWithId = doctor.copyWith(
        doctorId: doctorId,
        imageUrl: imageUrl,
      );
      await _doctorCollection.add(doctorWithId.toJson());
    } catch (e) {
      throw Exception('Failed to create doctor: ${e.toString()}');
    }
  }

  // Get a doctor profile by user ID (Firebase Auth UID)
  Future<Doctor?> getDoctorByUserId(String userId) async {
    try {
      DocumentSnapshot doc = await _doctorCollection.doc(userId).get();
      if (doc.exists) {
        return Doctor.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get doctor: ${e.toString()}');
    }
  }

  // Get a doctor profile by doctor ID
  Future<Doctor?> getDoctorByDoctorId(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await _doctorCollection
          .where('doctorId', isEqualTo: doctorId)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return Doctor.fromJson(querySnapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get doctor: ${e.toString()}');
    }
  }

  // Update doctor profile
  Future<void> updateDoctor(String userId, Doctor doctor, {XFile? imageFile}) async {
    try {
      String? imageUrl = doctor.imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(userId, imageFile);
      }
      
      Doctor updatedDoctor = doctor.copyWith(
        updatedAt: DateTime.now(),
        imageUrl: imageUrl,
      );
      await _doctorCollection.doc(userId).update(updatedDoctor.toJson());
    } catch (e) {
      throw Exception('Failed to update doctor: ${e.toString()}');
    }
  }

  // Get current doctor profile (if current user is doctor)
  Future<Doctor?> getCurrentDoctorProfile() async {
    if (_auth.currentUser != null) {
      return await getDoctorByUserId(_auth.currentUser!.uid);
    }
    return null;
  }

  // Stream a specific doctor by user ID
  Stream<Doctor?> doctorStreamByUserId(String userId) {
    return _doctorCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Doctor.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Stream all doctors
  Stream<List<Doctor>> getAllDoctorsStream() {
    return _doctorCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Doctor.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Stream active doctors only
  Stream<List<Doctor>> getActiveDoctorsStream() {
    return _doctorCollection
        .where('status', isEqualTo: 'Active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Doctor.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get doctors by specialty
  Future<List<Doctor>> getDoctorsBySpecialty(String specialty) async {
    try {
      QuerySnapshot querySnapshot = await _doctorCollection
          .where('specialty', isEqualTo: specialty)
          .where('status', isEqualTo: 'Active')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Doctor.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get doctors by specialty: ${e.toString()}');
    }
  }

  // Update doctor status
  Future<void> updateDoctorStatus(String userId, String status) async {
    try {
      await _doctorCollection.doc(userId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update doctor status: ${e.toString()}');
    }
  }

  // Delete doctor (set status to inactive)
  Future<void> deactivateDoctor(String userId) async {
    try {
      await updateDoctorStatus(userId, 'Inactive');
    } catch (e) {
      throw Exception('Failed to deactivate doctor: ${e.toString()}');
    }
  }

  // Get total number of doctors
  Future<int> getTotalDoctorsCount() async {
    try {
      QuerySnapshot querySnapshot = await _doctorCollection.get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get doctors count: ${e.toString()}');
    }
  }

  // Get active doctors count
  Future<int> getActiveDoctorsCount() async {
    try {
      QuerySnapshot querySnapshot = await _doctorCollection
          .where('status', isEqualTo: 'Active')
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get active doctors count: ${e.toString()}');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}