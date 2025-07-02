import 'package:flutter/material.dart';
import 'doctor_appointments_screen.dart';
import '../services/auth_service.dart'; // Import AuthService

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService(); // Initialize AuthService

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _DashboardCard(
              title: 'Patients',
              icon: Icons.people,
              color: Colors.green,
              count: 'View All',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Patients page - Coming Soon!')),
                );
              },
            ),
            _DashboardCard(
              title: 'Prescriptions',
              icon: Icons.receipt_long,
              color: Colors.orange,
              count: 'Create',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Prescriptions page - Coming Soon!')),
                );
              },
            ),
            _DashboardCard(
              title: 'Profile',
              icon: Icons.person,
              color: Colors.purple,
              count: 'Edit',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile page - Coming Soon!')),
                );
              },
            ),
            _DashboardCard(
              title: 'Reports',
              icon: Icons.analytics,
              color: Colors.teal,
              count: 'View',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports page - Coming Soon!')),
                );
              },
            ),
            _DashboardCard(
              title: 'Settings',
              icon: Icons.settings,
              color: Colors.grey,
              count: 'Configure',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings page - Coming Soon!')),
                );
              },
            ),
            _DashboardCard(
              title: 'Logout',
              icon: Icons.logout,
              color: Colors.red,
              count: 'Sign Out',
              onTap: () async {
                try {
                  await authService.signOut();
                  // StreamBuilder in main.dart will handle navigation to LoginPage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Successfully signed out')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String count;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
