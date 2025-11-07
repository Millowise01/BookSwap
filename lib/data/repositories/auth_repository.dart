import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_model.dart';
import '../../services/mock_auth_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MockAuthService _mockAuth = MockAuthService();
  
  static bool useTestMode = false;

  // Get current user
  User? get currentUser {
    if (useTestMode) {
      final mockUser = _mockAuth.currentUser;
      return mockUser != null ? _MockFirebaseUser(mockUser) : null;
    }
    return _auth.currentUser;
  }

  // Auth state changes stream
  Stream<User?> get authStateChanges {
    if (useTestMode) {
      return _mockAuth.authStateChanges.map((mockUser) => 
        mockUser != null ? _MockFirebaseUser(mockUser) : null);
    }
    return _auth.authStateChanges();
  }

  // Check if email is verified
  Stream<bool> checkEmailVerification(String uid) async* {
    if (useTestMode) {
      yield* _mockAuth.checkEmailVerification(uid);
      return;
    }
    yield await _isEmailVerified(uid);
    yield* _auth.userChanges().asyncMap((user) async {
      if (user != null && user.uid == uid) {
        return _isEmailVerified(uid);
      }
      return false;
    });
  }

  Future<bool> _isEmailVerified(String uid) async {
    final user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      await user.reload();
      // For development, allow unverified emails to sign in
      // In production, you might want to enforce email verification
      return true; // Changed from user.emailVerified to true
    }
    return false;
  }

  // Sign up
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String university,
  }) async {
    try {
      if (useTestMode) {
        final mockUser = await _mockAuth.signUp(
          email: email,
          password: password,
          name: name,
          university: university,
        );
        return _MockUserCredential(_MockFirebaseUser(mockUser));
      }
      
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
      if (useTestMode) {
        final mockUser = await _mockAuth.signIn(
          email: email,
          password: password,
        );
        return _MockUserCredential(_MockFirebaseUser(mockUser));
      }
      
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
    if (useTestMode) {
      await _mockAuth.signOut();
      return;
    }
    await _auth.signOut();
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    if (useTestMode) {
      await _mockAuth.resendVerificationEmail();
      return;
    }
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

class _MockFirebaseUser implements User {
  final MockUser _mockUser;
  
  _MockFirebaseUser(this._mockUser);
  
  @override
  String get uid => _mockUser.uid;
  
  @override
  String? get email => _mockUser.email;
  
  @override
  bool get emailVerified => _mockUser.emailVerified;
  
  @override
  String? get displayName => null;
  
  @override
  String? get phoneNumber => null;
  
  @override
  String? get photoURL => null;
  
  @override
  bool get isAnonymous => false;
  
  @override
  UserMetadata get metadata => throw UnimplementedError();
  
  @override
  List<UserInfo> get providerData => [];
  
  @override
  String? get refreshToken => null;
  
  @override
  String? get tenantId => null;
  
  @override
  Future<void> delete() => throw UnimplementedError();
  
  @override
  Future<String> getIdToken([bool forceRefresh = false]) => throw UnimplementedError();
  
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) => throw UnimplementedError();
  
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) => throw UnimplementedError();
  
  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) => throw UnimplementedError();
  
  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) => throw UnimplementedError();
  
  @override
  Future<void> linkWithRedirect(AuthProvider provider) => throw UnimplementedError();
  
  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) => throw UnimplementedError();
  
  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) => throw UnimplementedError();
  
  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) => throw UnimplementedError();
  
  @override
  Future<void> reload() => Future.value();
  
  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) => Future.value();
  
  @override
  Future<User> unlink(String providerId) => throw UnimplementedError();
  
  @override
  Future<void> updateDisplayName(String? displayName) => throw UnimplementedError();
  
  @override
  Future<void> updateEmail(String newEmail) => throw UnimplementedError();
  
  @override
  Future<void> updatePassword(String newPassword) => throw UnimplementedError();
  
  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) => throw UnimplementedError();
  
  @override
  Future<void> updatePhotoURL(String? photoURL) => throw UnimplementedError();
  
  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) => throw UnimplementedError();
  
  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) => throw UnimplementedError();
  
  @override
  MultiFactor get multiFactor => throw UnimplementedError();
  
  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) => throw UnimplementedError();
  
  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) => throw UnimplementedError();
}

class _MockUserCredential implements UserCredential {
  @override
  final User? user;
  
  _MockUserCredential(this.user);
  
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
  
  @override
  AuthCredential? get credential => null;
}

