import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart'; // Adjust path accordingly

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _doctorCollection =
      FirebaseFirestore.instance.collection('doctors');

  // Create a doctor profile
  Future<void> createDoctor(Doctor doctor) async {
    try {
      await _doctorCollection.doc(doctor.id.toString()).set(doctor.toJson());
    } catch (e) {
      throw Exception('Failed to create doctor: ${e.toString()}');
    }
  }

  // Get a doctor profile by ID
  Future<Doctor?> getDoctor(int id) async {
    try {
      DocumentSnapshot doc = await _doctorCollection.doc(id.toString()).get();
      if (doc.exists) {
        return Doctor.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get doctor: ${e.toString()}');
    }
  }

  // Update doctor profile
  Future<void> updateDoctor(Doctor doctor) async {
    try {
      await _doctorCollection.doc(doctor.id.toString()).update(doctor.toJson());
    } catch (e) {
      throw Exception('Failed to update doctor: ${e.toString()}');
    }
  }

  // Stream a specific doctor
  Stream<Doctor?> doctorStream(int id) {
    return _doctorCollection.doc(id.toString()).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Doctor.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Stream all doctors (e.g., for listing)
  Stream<List<Doctor>> getAllDoctorsStream() {
    return _doctorCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Doctor.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
