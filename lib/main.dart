import 'package:flutter/material.dart';
import 'view/login_view.dart';
import 'view/register_view.dart';
import 'view/clinic_dashboard.dart';    


void main() {
  runApp(const CareConnectApp());
}

class CareConnectApp extends StatelessWidget {
  const CareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Care Connect',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/register': (context) => const SignUpScreen(),
        '/dashboard': (context) => const ClinicDashboard(),
      },
    );
  }
}
