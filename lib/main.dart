import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_tree_firebase/core/constants/app_constants.dart';
import 'package:family_tree_firebase/core/injection_container.dart' as di;
import 'package:family_tree_firebase/features/splash/presentation/screens/splash_screen.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/login_screen.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/register_screen.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/setup_password_screen.dart';
import 'package:family_tree_firebase/features/auth/presentation/screens/success_screen.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_bloc.dart';
import 'package:family_tree_firebase/features/family/presentation/screens/join_or_create_family_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Family Bloc
        BlocProvider(
          create: (context) => di.sl<FamilyBloc>(),
        ),
      ],
      child: MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
      ),
      initialRoute: AppConstants.splashRoute,
      routes: {
        AppConstants.splashRoute: (context) => const SplashScreen(),
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.registerRoute: (context) => const RegisterScreen(),
        AppConstants.joinOrCreateFamilyRoute: (context) =>
            const JoinOrCreateFamilyScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppConstants.otpRoute:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                verificationId: args['verificationId'],
                phoneNumber: args['phoneNumber'],
              ),
            );

          case AppConstants.setupPasswordRoute:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => SetupPasswordScreen(
                email: args['email'],
                name: args['name'],
                phone: args['phone'],
              ),
            );

          case AppConstants.successRoute:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => SuccessScreen(
                title: args['title'],
                message: args['message'],
                nextRoute: args['nextRoute'],
                arguments: args['arguments'],
              ),
            );

          default:
            return null;
        }
      },
      ),
    );
  }
}
