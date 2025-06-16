class Appointment {
  final String?
      id; // Make id optional since it won't exist before saving to Firestore
  final String doctorName;
  final String hospitalName;
  final String time;
  final String date;
  final String status;
  final String userId;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String notes;
  final DateTime createdAt;
  final bool isPaid;
  final double amount;

  Appointment({
    this.id,
    required this.doctorName,
    required this.hospitalName,
    required this.time,
    required this.date,
    required this.status,
    required this.userId,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
    required this.notes,
    required this.createdAt,
    required this.isPaid,
    required this.amount,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'doctorName': doctorName,
      'hospitalName': hospitalName,
      'time': time,
      'date': date,
      'status': status,
      'userId': userId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientPhone': patientPhone,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isPaid': isPaid,
      'amount': amount,
    };
  }

  // Create from Firestore document
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      doctorName: map['doctorName'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? '',
      userId: map['userId'] ?? '',
      patientName: map['patientName'] ?? '',
      patientEmail: map['patientEmail'] ?? '',
      patientPhone: map['patientPhone'] ?? '',
      notes: map['notes'] ?? '',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isPaid: map['isPaid'] ?? '',
      amount: map['amount'] ?? '',
    );
  }
}

class ViewAppointment {
  final String doctorName;
  final String hospitalName;
  final String time;

  ViewAppointment({
    required this.doctorName,
    required this.hospitalName,
    required this.time,
  });

  factory ViewAppointment.fromAppointment(ViewAppointment a) {
    return ViewAppointment(
      doctorName: a.doctorName,
      hospitalName: a.hospitalName,
      time: a.time,
    );
  }
}
