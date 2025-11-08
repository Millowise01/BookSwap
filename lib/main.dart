import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart' as app_auth;
import 'presentation/providers/book_provider.dart';
import 'presentation/providers/swap_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/home/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    rethrow;
  }
  
  runApp(const BookSwapApp());
}

class BookSwapApp extends StatelessWidget {
  const BookSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => SwapProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'BookSwap',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    
    return StreamBuilder(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          
          // Check if email is verified
          if (!user.emailVerified) {
            return EmailVerificationScreen(user: user);
          }
          
          return const MainScreen();
        }
        
        return const WelcomeScreen();
      },
    );
  }
}

class EmailVerificationScreen extends StatelessWidget {
  final dynamic user;
  const EmailVerificationScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          TextButton(
            onPressed: () => authProvider.signOut(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Verify Your Email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'We sent a verification email to ${user.email}. Please check your inbox and click the verification link.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await user.reload();
                if (user.emailVerified) {
                  // This will trigger the StreamBuilder to rebuild
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please verify your email first'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('I\'ve Verified My Email'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await authProvider.resendVerificationEmail();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification email sent!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Resend Email'),
            ),
          ],
        ),
      ),
    );
  }
}

