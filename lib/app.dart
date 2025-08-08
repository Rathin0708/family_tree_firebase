import 'package:family_tree_firebase/core/service_locator.dart';
import 'package:family_tree_firebase/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/login_screen_new.dart';
import 'package:family_tree_firebase/features/home/presentation/screens/main_app_screen.dart' as main_app;
import 'package:family_tree_firebase/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/register_screen.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/success_screen.dart';
import 'package:family_tree_firebase/features/home/presentation/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';
import 'core/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize local storage
    await GetStorage.init();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize dependency injection
    await di.init();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // Handle initialization errors
    debugPrint('Initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
      ],
      child: MaterialApp(
        title: 'Family Tree',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
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
              return const main_app.MainAppScreen();
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
      ),
    );
  }
}
