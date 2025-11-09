import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String university,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 30));

      userCredential.user?.sendEmailVerification().catchError((e) {
        print('Email verification error: $e');
      });

      _createUserProfile(userCredential.user?.uid, email, name, university);

      return userCredential;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  // Create user profile asynchronously
  void _createUserProfile(String? uid, String email, String name, String university) async {
    if (uid == null) return;
    
    try {
      final userModel = UserModel(
        uid: uid,
        email: email,
        name: name,
        university: university,
      );
      
      await _firestore.collection('users').doc(uid).set(userModel.toJson());
    } catch (e) {
      print('Error creating user profile: $e');
      // Don't throw - profile creation is non-critical
    }
  }

  // Sign in
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 30));

      return userCredential;
    } catch (e) {
      print('Signin error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      // Return basic profile if not found in Firestore
      return UserModel(
        uid: uid,
        email: _auth.currentUser?.email ?? '',
        name: _auth.currentUser?.displayName,
        university: null,
      );
    } catch (e) {
      print('Error getting user profile: $e');
      // Return basic profile on error
      return UserModel(
        uid: uid,
        email: _auth.currentUser?.email ?? '',
        name: _auth.currentUser?.displayName,
        university: null,
      );
    }
  }

  // Stream user profile
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
  }
}


