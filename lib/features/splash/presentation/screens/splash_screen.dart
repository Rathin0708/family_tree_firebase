import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:family_tree_firebase/core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // TODO: Add authentication check here
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo and App Name
            Hero(
              tag: 'app-logo',
              child: Column(
                children: [
                  // Replace with your app logo
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.family_restroom,
                      size: 100,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Family Connect',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Loading animation
            SizedBox(
              width: 100,
              height: 100,
              child: Lottie.asset(
                'assets/animations/loading_animation.json',
                controller: _animationController,
                onLoaded: (composition) {
                  _animationController
                    ..duration = composition.duration
                    ..repeat();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
