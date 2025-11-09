import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_model.dart'; // Using the updated model

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

      // 1. Send verification email
      userCredential.user?.sendEmailVerification().catchError((e) {
        print('Email verification error: $e');
      });

      // 2. Await profile creation to ensure data is written before sign up finishes
      await _createUserProfile(userCredential.user?.uid, email, name, university);

      return userCredential;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  // Create user profile
  Future<void> _createUserProfile(String? uid, String email, String name, String university) async {
    if (uid == null) return;
    
    try {
      final userModel = UserModel(
        uid: uid,
        email: email,
        name: name,
        university: university,
        profileImageUrl: null, // Profile image starts as null
      );
      
      // Store user profile in the 'users' collection
      await _firestore.collection('users').doc(uid).set(userModel.toJson());
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  // Sign in (WITH EMAIL VERIFICATION ENFORCEMENT)
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 30));

      final user = userCredential.user;
      
      // CRITICAL: Check if the email is verified
      if (user != null && !user.emailVerified) {
        
        // Re-send verification email for convenience (optional but recommended)
        user.sendEmailVerification().catchError((e) {
           print('Error resending verification email during failed sign-in: $e');
        });

        // If not verified, immediately sign the user out
        await _auth.signOut(); 
        
        // Throw a specific error that the UI can catch
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email address before logging in. A new verification link has been sent.',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Signin error: $e');
      rethrow;
    } catch (e) {
      print('Unexpected Signin error: $e');
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
    // Must reload the user data first to get the latest email verification status
    await user?.reload(); 
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Get user profile (One-time fetch)
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Stream user profile (Real-time updates)
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
  }
}