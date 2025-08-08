import 'package:family_tree_firebase/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/login_screen.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/register_screen.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/success_screen.dart';
import 'package:family_tree_firebase/features/home/presentation/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Tree',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Show loading indicator while checking auth status
          if (state.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Show registration screen first for new users
          if (state.status == AuthStatus.unauthenticated) {
            // Check if it's a new user (not coming back from login)
            final isNewUser = ModalRoute.of(context)?.settings.arguments as bool? ?? true;
            if (isNewUser) {
              return const RegisterScreen();
            } else {
              return const LoginScreen();
            }
          }

          // Show home screen if authenticated
          if (state.status == AuthStatus.authenticated) {
            return const HomeScreen();
          }

          // Show loading indicator for other states
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/otp-verification': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return OtpVerificationScreen(
            verificationId: args?['verificationId'] ?? '',
            phoneNumber: args?['phoneNumber'] ?? '',
          );
        },
        '/success': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return SuccessScreen(
            title: args?['title'] ?? 'Success!',
            message: args?['message'] ?? 'Operation completed successfully.',
            buttonText: args?['buttonText'] ?? 'Continue',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
          );
        },
      },
      onGenerateRoute: (settings) {
        // Handle named routes with arguments
        if (settings.name == '/otp-verification') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              verificationId: args?['verificationId'] ?? '',
              phoneNumber: args?['phoneNumber'] ?? '',
            ),
          );
        }
        // Handle home route
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        }
        return null;
      },
      onUnknownRoute: (settings) {
        // Handle unknown routes by redirecting to home or login
        return MaterialPageRoute(
          builder: (context) => BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.authenticated) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(CheckAuthStatus())),
      ],
      child: MaterialApp(
        title: 'Family Tree App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Color(0xFF333333)),
            titleTextStyle: TextStyle(
              color: Color(0xFF333333),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFFF6B35)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              minimumSize: const Size(double.infinity, 56),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B35),
              side: const BorderSide(color: Color(0xFFFF6B35)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              minimumSize: const Size(double.infinity, 56),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Show loading indicator while checking auth status
            if (state.status == AuthStatus.initial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B35),
                  ),
                ),
              );
            }

            // Show login screen if not authenticated
            if (state.status != AuthStatus.authenticated) {
              return const LoginScreen();
            }

            // Show home screen if authenticated
            return const SuccessScreen(
              title: 'Welcome!',
              message: 'You are successfully logged in.',
            );
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/success': (context) => const SuccessScreen(
                title: 'Success!',
                message: 'Operation completed successfully.',
              ),
        },
      ),
    );
  }
}
