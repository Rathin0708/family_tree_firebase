import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessScreen extends StatelessWidget {
  final String title;
  final String message;
  final bool isRegistration;
  final String? buttonText;
  final VoidCallback? onPressed;

  const SuccessScreen({
    Key? key,
    required this.title,
    required this.message,
    this.isRegistration = false,
    this.buttonText,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 80,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF666666),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onPressed ?? () {
                    if (isRegistration) {
                      // Navigate to home screen after registration
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText ?? (isRegistration ? 'GET STARTED' : 'DONE'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              if (!isRegistration) ...[  
                const SizedBox(height: 16),
                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF6B35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'BACK TO HOME',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
