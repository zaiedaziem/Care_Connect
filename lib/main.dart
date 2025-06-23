// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login_page.dart';
import 'pages/clinic_dashboard.dart';
import 'pages/doctor_dashboard.dart';
import 'pages/admin_dashboard.dart';
import 'services/auth_service.dart';
import 'services/doctor_service.dart';
import 'models/user_profile.dart';
import 'models/doctor.dart';
import 'firebase_options.dart';
import 'package:geolocator/geolocator.dart';
import 'services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  final locationService = LocationService();
  await locationService.checkAndRequestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Care Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Authentication Error',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Please restart the app',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return UserTypeRouter(user: snapshot.data!);
        }
        return const LoginPage();
      },
    );
  }
}

class UserTypeRouter extends StatelessWidget {
  final User user;

  const UserTypeRouter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final DoctorService doctorService = DoctorService();

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserType(user.uid, authService, doctorService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 3),
                    SizedBox(height: 20),
                    Text(
                      'Loading your dashboard...',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Profile Loading Error',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Failed to load user profile',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await authService.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const AuthWrapper()),
                      );
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final String userType = data['userType'];
        final dynamic profile = data['profile'];

        switch (userType) {
          case 'patient':
            return const ClinicDashboard();
          case 'admin':
            return const AdminDashboard();
          case 'doctor':
            return const DoctorDashboard();
          default:
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.help_outline,
                        size: 64, color: Colors.amber),
                    const SizedBox(height: 16),
                    Text('Unknown User Type',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('User type: $userType',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await authService.signOut();
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }

  Future<Map<String, dynamic>> _fetchUserType(
    String uid,
    AuthService authService,
    DoctorService doctorService,
  ) async {
    try {
      // Check users collection first
      final userProfile = await authService.getUserProfile(uid);
      if (userProfile != null) {
        return {
          'userType': userProfile.userType.toLowerCase(),
          'profile': userProfile,
        };
      }

      // If no user profile, check doctors collection
      final doctor = await doctorService.getDoctorByUserId(uid);
      if (doctor != null) {
        return {
          'userType': 'doctor',
          'profile': doctor,
        };
      }

      throw Exception('No profile found in users or doctors collection');
    } catch (e) {
      throw Exception('Error fetching user type: $e');
    }
  }
}
