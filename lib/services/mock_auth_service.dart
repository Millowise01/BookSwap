import 'dart:async';

class MockUser {
  final String uid;
  final String email;
  final bool emailVerified;
  
  MockUser({
    required this.uid,
    required this.email,
    this.emailVerified = true,
  });
}

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  MockUser? _currentUser;
  final StreamController<MockUser?> _authStateController = StreamController<MockUser?>.broadcast();

  Stream<MockUser?> get authStateChanges => _authStateController.stream;
  MockUser? get currentUser => _currentUser;

  Future<MockUser> signUp({
    required String email,
    required String password,
    required String name,
    required String university,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final user = MockUser(
      uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      emailVerified: true,
    );
    
    _currentUser = user;
    _authStateController.add(user);
    
    return user;
  }

  Future<MockUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final user = MockUser(
      uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      emailVerified: true,
    );
    
    _currentUser = user;
    _authStateController.add(user);
    
    return user;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _authStateController.add(null);
  }

  Stream<bool> checkEmailVerification(String uid) {
    return Stream.value(true);
  }

  Future<void> resendVerificationEmail() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}