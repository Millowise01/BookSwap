import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    _user = _authRepository.currentUser;
    if (_user != null) {
      _loadUserProfile();
    }
    
    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      _user = user;
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      _userProfile = await _authRepository.getUserProfile(_user!.uid);
      notifyListeners();
    }
  }



  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String university,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        university: university,
      );

      _user = userCredential.user;
      await _loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authRepository.signIn(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      

      
      await _loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Sign in failed';
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'No account found with this email';
          break;
        case 'wrong-password':
          errorMsg = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMsg = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMsg = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMsg = 'Too many failed attempts. Try again later';
          break;
        case 'invalid-credential':
          errorMsg = 'Invalid email or password';
          break;
        default:
          errorMsg = e.message ?? 'Sign in failed';
      }
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Network error. Please check your connection';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.signOut();
    _user = null;
    _userProfile = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _authRepository.resendVerificationEmail();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

