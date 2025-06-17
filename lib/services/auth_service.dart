import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart'; // Adjust the import path as needed

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Register with email and password
  Future<UserCredential?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Create user profile in Firestore
      if (result.user != null) {
        await _createUserProfile(result.user!.uid, email);
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // If user was created but profile creation failed, delete the user
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }
  
  // Create user profile in Firestore
  Future<void> _createUserProfile(String uid, String email) async {
    try {
      final userProfile = UserProfile.createPatient();
      
      await _firestore.collection('users').doc(uid).set(userProfile.toJson());
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }
  
  // Get user profile from Firestore
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
  
  // Update user profile in Firestore
  Future<void> updateUserProfile(String uid, UserProfile userProfile) async {
    try {
      await _firestore.collection('users').doc(uid).update(
        userProfile.copyWith(updatedAt: DateTime.now()).toJson()
      );
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }
  
  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    if (currentUser != null) {
      return await getUserProfile(currentUser!.uid);
    }
    return null;
  }
  
  // Stream of current user profile
  Stream<UserProfile?> get currentUserProfileStream {
    return authStateChanges.asyncMap((user) async {
      if (user != null) {
        return await getUserProfile(user.uid);
      }
      return null;
    });
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }
  
  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Handle Firebase Auth exceptions
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