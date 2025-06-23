import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qq/pages/clinic_location.dart';
import 'createAppointment.dart';
import 'profile_page.dart';
import 'view_appointments.dart';
import 'paid_appointments_page.dart';
import 'UnpaidAppointmentsPage.dart';
import 'doctor_appointments_screen.dart';

void main() {
  runApp(const ClinicApp());
}

class ClinicApp extends StatelessWidget {
  const ClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const ClinicDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ClinicDashboard extends StatefulWidget {
  const ClinicDashboard({super.key});

  @override
  State<ClinicDashboard> createState() => _ClinicDashboardState();
}

class _ClinicDashboardState extends State<ClinicDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = 'Loading...';
  String greeting = 'Hello';
  String? profileImageUrl;
  int todayAppointments = 0;
  double pendingPayments = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchDashboardData();
  }

  Future<void> _fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            userName = data['name'] ?? 'User';
            profileImageUrl = data['profileImageUrl'];
            greeting = _getGreeting();
          });
        }
      }
    } catch (e) {
      setState(() {
        userName = 'User';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    }
  }

  Future<void> _fetchDashboardData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final unpaidQuery = await _firestore
          .collection('appointments')
          .where('patientEmail', isEqualTo: currentUser.email)
          .where('isPaid', isEqualTo: false)
          .where('status', isEqualTo: 'unpaid')
          .get();

      double totalUnpaid = 0.0;
      for (var doc in unpaidQuery.docs) {
        final data = doc.data();
        totalUnpaid += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }

      setState(() {
        pendingPayments = totalUnpaid;
        todayAppointments = unpaidQuery.size;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard data: $e')),
        );
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    return hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Top Bar with Profile and View Appointments
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 12),
                            // Profile Avatar
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: profileImageUrl != null
                                    ? NetworkImage(profileImageUrl!)
                                    : const AssetImage('images/profile.png')
                                        as ImageProvider,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search clinics, doctors, or services...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Quick Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.event_available,
                        title: 'Today',
                        subtitle: '$todayAppointments Appointments',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UnpaidAppointmentsPage(),
                            ),
                          );
                        },
                        child: _buildStatCard(
                          icon: Icons.payment,
                          title: 'To Pay',
                          subtitle: 'RM${pendingPayments.toStringAsFixed(2)}',
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // First row of action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.calendar_today_outlined,
                            label: 'Create\nAppointment',
                            gradient: const [
                              Color(0xFF667eea),
                              Color(0xFF764ba2)
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HospitalListScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.favorite_outline,
                            label: 'Health\nTips',
                            gradient: const [
                              Color(0xFFFF6B6B),
                              Color(0xFFFF8E8E)
                            ],
                            onTap: () {
                              // Add health tips navigation
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Second row of action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.medical_services_outlined,
                            label: 'Emergency\nContacts',
                            gradient: const [
                              Color(0xFF4ECDC4),
                              Color(0xFF44A08D)
                            ],
                            onTap: () {
                              // Add emergency contacts navigation
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.payment,
                            label: 'Paid\nAppointments',
                            gradient: const [
                              Color(0xFF10B981),
                              Color(0xFF059669)
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PaidAppointmentsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.calendar_today_outlined,
                            label: 'View\nAppointment',
                            gradient: const [
                              Color(0xFF4ECDC4),
                              Color(0xFF44A08D)
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ViewAppointmentsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        _buildActionButton(
                          icon: Icons.calendar_today_outlined,
                          label: 'View\nAppointment',
                          gradient: const [
                            Color(0xFF4ECDC4),
                            Color(0xFF44A08D)
                          ],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ViewAppointmentsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),

                        _buildActionButton(
                          icon: Icons.location_on,
                          label: 'Clinic\nLocation',
                          gradient: const [
                            Color(0xFF10B981),
                            Color(0xFF059669)
                          ],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ClinicLocationsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),

                        // Empty spacer buttons to maintain layout
                        Expanded(child: Container()),
                        const SizedBox(width: 18),
                        Expanded(child: Container()),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Featured Clinics Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Clinics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Clinics List
              SizedBox(
                height: 245,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 24),
                  children: const [
                    ClinicCard(
                      name: 'Gleneagles Hospital',
                      location: '900m away',
                      rating: 4.8,
                      imageUrl: 'images/glene.png',
                      specialty: 'General Medicine',
                    ),
                    ClinicCard(
                      name: 'Columbia Asia Hospital',
                      location: '1.5km away',
                      rating: 4.6,
                      imageUrl: 'images/columbia.jpg',
                      specialty: 'Cardiology',
                    ),
                    ClinicCard(
                      name: 'Klinik Keluarga i-SIHAT',
                      location: '2km away',
                      rating: 4.9,
                      imageUrl: 'images/keluarga.png',
                      specialty: 'Family Medicine',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Updated Recent Activity Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('appointments')
                          .where('patientEmail',
                              isEqualTo: _auth.currentUser?.email ?? '')
                          .orderBy('createdAt', descending: true)
                          .limit(3)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          debugPrint('Firestore Error: ${snapshot.error}');
                          return Column(
                            children: [
                              Text(
                                'Failed to load activities',
                                style: TextStyle(color: Colors.red[400]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Debug info: Querying for email ${_auth.currentUser?.email}',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Column(
                            children: [
                              Text(
                                'No appointments yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Debug info: Querying for email ${_auth.currentUser?.email}',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final status =
                                data['status']?.toString() ?? 'Upcoming';
                            final doctorName =
                                data['doctorName']?.toString() ?? 'Doctor';
                            final hospitalName =
                                data['hospitalName']?.toString() ?? 'Clinic';
                            final time = data['time']?.toString() ?? '';
                            final createdAt = data['createdAt'];

                            return _buildActivityItem(
                              icon: _getAppointmentIcon(status),
                              title: 'Appointment with $doctorName',
                              subtitle: '$hospitalName • $time',
                              time: _formatTime(createdAt),
                              iconColor: _getStatusColor(status),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for Recent Activity
  IconData _getAppointmentIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'confirmed':
        return Icons.calendar_today;
      case 'upcoming':
        return Icons.access_time;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.event;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981); // Green
      case 'confirmed':
        return const Color(0xFF3B82F6); // Blue
      case 'upcoming':
        return const Color(0xFFF59E0B); // Amber
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Recently';

    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else if (timestamp is int) {
        date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return 'Recently';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        final mins = difference.inMinutes;
        return '$mins ${mins == 1 ? 'minute' : 'minutes'} ago';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      } else {
        return DateFormat('MMM d, y').format(date);
      }
    } catch (e) {
      debugPrint('Error formatting time: $e');
      return 'Recently';
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ClinicCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String imageUrl;
  final String specialty;

  const ClinicCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.specialty,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                color: Colors.grey[200],
                child: const Icon(Icons.local_hospital, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  specialty,
                  style: const TextStyle(
                    color: Color(0xFF667eea),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 4),
                    Text(location),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(rating.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
