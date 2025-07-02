import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PaidAppointmentsPage extends StatelessWidget {
  const PaidAppointmentsPage({super.key});

  Future<void> _generateAndShowInvoice(
      BuildContext context, Map<String, dynamic> appointmentData) async {
    try {
      // Validate required fields
      if (appointmentData['createdAt'] == null ||
          appointmentData['amount'] == null ||
          appointmentData['patientName'] == null ||
          appointmentData['doctorName'] == null ||
          appointmentData['hospitalName'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid appointment data')),
        );
        return;
      }

      // Handle createdAt conversion
      DateTime createdAt;
      if (appointmentData['createdAt'] is Timestamp) {
        createdAt = (appointmentData['createdAt'] as Timestamp).toDate();
      } else if (appointmentData['createdAt'] is int) {
        // Convert milliseconds since epoch to DateTime
        createdAt = DateTime.fromMillisecondsSinceEpoch(appointmentData['createdAt']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid createdAt format')),
        );
        return;
      }

      // Format date and time
      final dateFormat = DateFormat('dd MMM yyyy');
      final timeFormat = DateFormat('hh:mm a');

      // Load font
      final font = await PdfGoogleFonts.robotoRegular();

      // Create PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                    level: 0,
                    child: pw.Text('Medical Invoice',
                        style: pw.TextStyle(font: font))),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Invoice Number: ${appointmentData['id']}',
                            style: pw.TextStyle(font: font)),
                        pw.Text('Date: ${dateFormat.format(createdAt)}',
                            style: pw.TextStyle(font: font)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Patient: ${appointmentData['patientName']}',
                            style: pw.TextStyle(font: font)),
                        pw.Text('Email: ${appointmentData['patientEmail']}',
                            style: pw.TextStyle(font: font)),
                      ],
                    ),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text('Appointment Details:',
                    style: pw.TextStyle(
                        font: font, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Doctor: ${appointmentData['doctorName']}',
                    style: pw.TextStyle(font: font)),
                pw.Text('Hospital/Clinic: ${appointmentData['hospitalName']}',
                    style: pw.TextStyle(font: font)),
                pw.Text('Date: ${appointmentData['date']}',
                    style: pw.TextStyle(font: font)),
                pw.Text('Time: ${timeFormat.format(createdAt)}',
                    style: pw.TextStyle(font: font)),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Amount:',
                        style: pw.TextStyle(
                            font: font, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        'RM ${(appointmentData['amount'] as num).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            font: font, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Center(
                    child: pw.Text('Thank you for your payment!',
                        style: pw.TextStyle(font: font))),
              ],
            );
          },
        ),
      );

      // Show PDF preview
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate invoice: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (currentUser?.email == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Paid Appointments'),
          backgroundColor: const Color(0xFF667eea),
          elevation: 0,
        ),
        body: const Center(
          child: Text('Please sign in to view paid appointments'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paid Appointments'),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('appointments')
            .where('patientEmail', isEqualTo: currentUser!.email)
            .where('isPaid', isEqualTo: true)
            .where('status', isEqualTo: 'confirmed')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No paid appointments found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    '${data['doctorName'] ?? 'Doctor'} at ${data['hospitalName'] ?? 'Clinic'}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paid: RM${(data['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                      Text(
                        'Date: ${data['date']?.toString() ?? ''}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.receipt, color: Color(0xFF667eea)),
                    onPressed: () => _generateAndShowInvoice(context, {
                      ...data,
                      'id': doc.id, // Add document ID to the data
                    }),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
