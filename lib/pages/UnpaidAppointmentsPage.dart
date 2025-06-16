import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'payment_screen.dart';

class UnpaidAppointmentsPage extends StatelessWidget {
  const UnpaidAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    // Handle unauthenticated users
    if (currentUser?.email == null) {
      return _buildUnauthenticatedView(context, theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unpaid Appointments'),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: _buildAppointmentsList(currentUser!, theme),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unpaid Appointments'),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Authentication required',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(User currentUser, ThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientEmail', isEqualTo: currentUser.email)
          .where('isPaid', isEqualTo: false) // Ensure only unpaid
          .where('status', isEqualTo: 'unpaid') // Double-check status
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
          return _buildErrorView(context, snapshot.error.toString(), theme);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyStateView(theme);
        }

        return _buildAppointmentsListView(snapshot.data!.docs, theme);
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String error, ThemeData theme) {
    debugPrint('Error loading appointments: $error');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load appointments',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {}, // Will automatically rebuild
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No unpaid appointments',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All your appointments are paid',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsListView(
      List<QueryDocumentSnapshot> docs, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

        return _buildAppointmentCard(context, data, doc.id, amount, theme);
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Map<String, dynamic> data,
      String docId, double amount, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppointmentHeader(data),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildPaymentSection(context, data, docId, amount),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentHeader(Map<String, dynamic> data) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.payment,
            color: Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointment with ${data['doctorName'] ?? 'Doctor'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${data['hospitalName'] ?? 'Clinic'} • ${data['time'] ?? ''}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          _formatTime(data['createdAt']),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context, Map<String, dynamic> data,
      String docId, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Amount: \$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        ElevatedButton(
          onPressed: () => _navigateToPayment(context, data, docId, amount),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Pay Now',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToLogin(BuildContext context) {
    // Implement your login navigation logic here
    // Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  void _navigateToPayment(BuildContext context, Map<String, dynamic> data,
      String docId, double amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          amount: amount,
          appointmentDetails: {
            'hospitalName': data['hospitalName'],
            'doctorName': data['doctorName'],
            'date': data['date'],
            'time': data['time'],
            'appointmentId': docId,
          },
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Recently';

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      date = DateTime.parse(timestamp);
    } else {
      return 'Recently';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
