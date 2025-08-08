import 'package:family_tree_firebase/features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Enable Firebase emulator for development
    // Uncomment and update with your emulator host and port
    // await _connectToFirebaseEmulator();
    
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc()..add(CheckAuthStatus())),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    // Handle Firebase initialization errors
    debugPrint('Firebase initialization error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing Firebase: $e'),
          ),
        ),
      ),
    );
  }
}

// Helper function to connect to Firebase emulator (for development)
// Future<void> _connectToFirebaseEmulator() async {
//   final host = 'localhost';
//   await FirebaseAuth.instance.useAuthEmulator(host, 9099);
//   FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
//   await FirebaseStorage.instance.useStorageEmulator(host, 9199);
// }
