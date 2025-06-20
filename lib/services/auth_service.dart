// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
    required String userType, // Added to support different user types
    String? name, // Optional for patient/admin
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        if (userType.toLowerCase() == 'doctor') {
          // Doctors are created in doctors collection, likely via admin panel
          // Do not create a user profile in users collection
          return result;
        } else {
          await _createUserProfile(result.user!.uid, email, userType, name);
        }
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  Future<void> _createUserProfile(String uid, String email, String userType, String? name) async {
    try {
      final userProfile = UserProfile(
        name: name ?? email.split('@')[0], // Default name from email if not provided
        contact: null,
        userType: userType.toLowerCase(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(userProfile.toJson());
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile(String uid, UserProfile userProfile) async {
    try {
      await _firestore.collection('users').doc(uid).update(
        userProfile.copyWith(updatedAt: DateTime.now()).toJson(),
      );
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    if (currentUser != null) {
      return await getUserProfile(currentUser!.uid);
    }
    return null;
  }

  Stream<UserProfile?> get currentUserProfileStream {
    return authStateChanges.asyncMap((user) async {
      if (user != null) {
        return await getUserProfile(user.uid);
      }
      return null;
    });
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}