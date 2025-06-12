class Appointment {
  final String doctorName;
  final String hospitalName;
  final String time;
  final String date;
  final String status; // This could be 'Upcoming' initially.
  final String userId; // User ID who booked the appointment.
  final String patientName; // Patient's full name
  final String patientEmail; // Patient's email
  final String patientPhone; // Patient's phone number
  final String notes; // Additional notes from patient
  final DateTime createdAt; // When the appointment was created

  Appointment({
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
  });

  // Convert Appointment to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
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
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert from Firestore snapshot
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
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}