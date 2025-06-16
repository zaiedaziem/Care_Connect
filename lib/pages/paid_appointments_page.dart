import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaidAppointmentsPage extends StatelessWidget {
  const PaidAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    // Handle case where user is not logged in
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
                  subtitle: Text(
                    'Paid: \RM${(data['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  ),
                  trailing: Text(data['date']?.toString() ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
