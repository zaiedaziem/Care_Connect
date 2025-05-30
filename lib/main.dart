import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'view/login_view.dart';
import 'view/register_view.dart';
import 'view/clinic_dashboard.dart';

import 'view_model/login_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDTAMAvDT1b_d1xZUu8qihnGmukDfqKOn8",
      authDomain: "careconnect-1601c.firebaseapp.com",
      projectId: "careconnect-1601c",
      storageBucket: "careconnect-1601c.firebasestorage.app",
      messagingSenderId: "707193746787",
      appId: "1:707193746787:web:17229c7323711c1ee88f56",
      measurementId: "G-LK0Y7E1EZM",
    ),
  );

  runApp(const CareConnectApp());
}

class CareConnectApp extends StatelessWidget {
  const CareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginViewModel>(
          create: (_) => LoginViewModel(),
        ),
        // Add more ViewModels here if needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Care Connect',
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginView(),
          '/register': (context) => const SignUpScreen(),
          '/dashboard': (context) => const ClinicDashboard(),
        },
      ),
    );
  }
}
