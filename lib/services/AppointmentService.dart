import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart'; // Import your Appointment model

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> bookAppointment(Appointment appointment) async {
    try {
      // Get the current user ID
      String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add the appointment to Firestore
      await _firestore.collection('appointments').add(appointment.toMap());
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }
}
