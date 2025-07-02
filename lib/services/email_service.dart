import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _serviceId = 'service_5mdrbep';
  static const String _templateId = 'template_q21ufkl';
  static const String _userId = 'AaKc7OXSu4WKZk4uM';

  static Future<void> sendAppointmentConfirmedEmail({
    required String toEmail,
    required String toName,
    required String appointmentDate,
    required String appointmentTime,
    required String doctorName,
    required String hospitalName,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _userId,
        'template_params': {
          'to_email': toEmail,
          'to_name': toName,
          'appointment_date': appointmentDate,
          'appointment_time': appointmentTime,
          'doctor_name': doctorName,
          'hospital_name': hospitalName,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send email: ${response.body}');
    }
  }
}
