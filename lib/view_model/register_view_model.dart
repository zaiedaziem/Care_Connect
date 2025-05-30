import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/auth_service.dart'; // adjust path if needed

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  /// Register user using email and password
  Future<User?> registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage = "Email and password cannot be empty";
      notifyListeners();
      return null;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final user = await _authService.register(email, password);

      isLoading = false;
      notifyListeners();

      return user;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }

  void disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
