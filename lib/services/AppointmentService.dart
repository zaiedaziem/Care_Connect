import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Books a new appointment and returns the document ID
  Future<String> bookAppointment(Appointment appointment) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Create a new appointment with the user ID
      final appointmentWithUserId = Appointment(
        id: appointment.id,
        doctorName: appointment.doctorName,
        hospitalName: appointment.hospitalName,
        time: appointment.time,
        date: appointment.date,
        status: appointment.status,
        userId: userId, // Set the user ID
        patientName: appointment.patientName,
        patientEmail: appointment.patientEmail,
        patientPhone: appointment.patientPhone,
        notes: appointment.notes,
        createdAt: appointment.createdAt,
        isPaid: appointment.isPaid,
        amount: appointment.amount,
      );

      final docRef = await _firestore
          .collection('appointments')
          .add(appointmentWithUserId.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to book appointment: ${e.toString()}');
    }
  }

  /// Gets all appointments for the current user with optional filters
  Future<List<Appointment>> getUserAppointments({
    bool? isPaid,
    String? status,
    String? doctorName,
    int limit = 50,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      Query query = _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (isPaid != null) {
        query = query.where('isPaid', isEqualTo: isPaid);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (doctorName != null) {
        query = query.where('doctorName', isEqualTo: doctorName);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Appointment.fromMap({
          ...data,
          'id': doc.id, // Include the document ID
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get appointments: ${e.toString()}');
    }
  }

  /// Gets unpaid appointments for the current user
  Future<List<Appointment>> getUnpaidAppointments() async {
    return getUserAppointments(
      isPaid: false,
      status: 'unpaid',
    );
  }

  /// Updates specific fields of an appointment
  Future<void> updateAppointment({
    required String appointmentId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update appointment: ${e.toString()}');
    }
  }

  /// Marks an appointment as paid
  Future<void> markAsPaid({
    required String appointmentId,
    required double amount,
  }) async {
    try {
      await updateAppointment(
        appointmentId: appointmentId,
        updates: {
          'isPaid': true,
          'status': 'confirmed',
          'amount': amount,
        },
      );
    } catch (e) {
      throw Exception('Failed to mark appointment as paid: ${e.toString()}');
    }
  }

  /// Cancels an appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await updateAppointment(
        appointmentId: appointmentId,
        updates: {
          'status': 'cancelled',
        },
      );
    } catch (e) {
      throw Exception('Failed to cancel appointment: ${e.toString()}');
    }
  }

  /// Gets a single appointment by ID
  Future<Appointment> getAppointmentById(String appointmentId) async {
    try {
      final doc =
          await _firestore.collection('appointments').doc(appointmentId).get();

      if (!doc.exists) {
        throw Exception('Appointment not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      return Appointment.fromMap({
        ...data,
        'id': doc.id, // Include the document ID
      });
    } catch (e) {
      throw Exception('Failed to get appointment: ${e.toString()}');
    }
  }

  /// Deletes an appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: ${e.toString()}');
    }
  }

  /// Stream of appointments for real-time updates
  Stream<List<Appointment>> streamUserAppointments({
    bool? isPaid,
    String? status,
    int limit = 50,
  }) {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      Query query = _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (isPaid != null) {
        query = query.where('isPaid', isEqualTo: isPaid);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Appointment.fromMap({
            ...data,
            'id': doc.id, // Include the document ID
          });
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to stream appointments: ${e.toString()}');
    }
  }

  // Add this method to your AppointmentService class
  Future<List<Appointment>> getAppointmentsByEmail(String email) async {
    try {
      final query = _firestore
          .collection('appointments')
          .where('patientEmail', isEqualTo: email)
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Appointment.fromMap({
          ...data,
          'id': doc.id, // Include the document ID
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get appointments by email: ${e.toString()}');
    }
  }

  /// Gets appointments by specific doctor
  Future<List<Appointment>> getAppointmentsByDoctor(String doctorName) async {
    return getUserAppointments(doctorName: doctorName);
  }
}
