import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'core/service_locator.dart' as di;
import 'firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize local storage
    await GetStorage.init();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize dependency injection
    await di.init();
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    
    // Enable Firebase emulator for development
    // Uncomment and update with your emulator host and port
    // await _connectToFirebaseEmulator();
    
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

// Helper function to connect to Firebase emulator (for development)
// Future<void> _connectToFirebaseEmulator() async {
//   final host = 'localhost';
//   await FirebaseAuth.instance.useAuthEmulator(host, 9099);
//   FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
//   await FirebaseStorage.instance.useStorageEmulator(host, 9199);
// }
