import 'dart:async';
import 'package:family_tree_firebase/features/auth/presentation/screens/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final bool isRegistration;

  const OtpVerificationScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    this.isRegistration = false,
  }) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  int _resendTimer = 30;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus the first OTP field
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 30;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    // Auto-verify if all fields are filled
    bool allFilled = _otpControllers.every((controller) => controller.text.isNotEmpty);
    if (allFilled) {
      _verifyOtp();
    }
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      context.read<AuthBloc>().add(
            VerifyOtpRequested(
              verificationId: widget.verificationId,
              smsCode: otp,
            ),
          );
    }
  }

  void _resendOtp() {
    if (_canResend) {
      context.read<AuthBloc>().add(SendOtpRequested(widget.phoneNumber));
      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verification',
          style: GoogleFonts.poppins(
            color: const Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.verificationSuccessful) {
            // Navigate to success screen or home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SuccessScreen(
                  title: 'Verification Successful!',
                  message: 'Your account has been successfully verified.',
                  isRegistration: true,
                ),
              ),
            );
          } else if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error ?? 'Verification failed')),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Title
                Text(
                  'ENTER VERIFICATION CODE',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'We have sent the verification code to',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Phone Number
                Text(
                  widget.phoneNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) => _onOtpChanged(value, index),
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 32),
                
                // Resend OTP
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: _resendOtp,
                          child: Text(
                            'Resend OTP',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFF6B35),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : Text(
                          'Resend OTP in 00:${_resendTimer.toString().padLeft(2, '0')}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF999999),
                            fontSize: 14,
                          ),
                        ),
                ),
                
                const SizedBox(height: 40),
                
                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.status == AuthStatus.verificationInProgress ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                    ),
                    child: state.status == AuthStatus.verificationInProgress
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'VERIFY',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF6B35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'BACK',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
