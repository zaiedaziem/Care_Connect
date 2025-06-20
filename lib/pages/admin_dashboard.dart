import 'package:flutter/material.dart';
import 'doctor_list.dart';
import 'create_doctor.dart';
import '../services/auth_service.dart'; // Import AuthService

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService(); // Initialize AuthService

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _DashboardCard(
              title: 'Register Doctor',
              icon: Icons.person_add,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorSignUpPage(),
                  ),
                );
              },
            ),
            _DashboardCard(
              title: 'Doctor List',
              icon: Icons.list,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorListPage(),
                  ),
                );
              },
            ),
            _DashboardCard(
              title: 'Logout',
              icon: Icons.logout,
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
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: title == 'Logout' ? Colors.red : Theme.of(context).primaryColor, // Red for logout
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}