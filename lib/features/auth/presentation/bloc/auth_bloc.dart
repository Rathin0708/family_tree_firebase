import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Auth Status
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  otpSent,
  otpTimeout,
  verificationInProgress,
  verificationSuccessful,
  verificationFailed,
  error,
}

// Auth State
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;
  final String? verificationId;
  final String? phoneNumber;
  final int? resendToken;
  final bool isNewUser;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.verificationId,
    this.phoneNumber,
    this.resendToken,
    this.isNewUser = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    String? verificationId,
    String? phoneNumber,
    int? resendToken,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      resendToken: resendToken ?? this.resendToken,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        error,
        verificationId,
        resendToken,
        isNewUser,
      ];
}

// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, phoneNumber, password];
}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const SendOtpRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOtpRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const VerifyOtpRequested({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [verificationId, smsCode];
}

class LogoutRequested extends AuthEvent {}

// Auth Bloc

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc() : super(const AuthState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);

    // Listen to auth state changes
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        emit(state.copyWith(
          user: user,
          status: AuthStatus.authenticated,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        ));
      }
    });
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: userCredential.user,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'User not found',
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: _getErrorMessage(e.code),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      
      // Create user with email and password
      final credential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Update user profile with display name
      await credential.user?.updateDisplayName(event.name);
      
      // Send OTP for phone verification
      emit(state.copyWith(
        status: AuthStatus.otpSent,
        user: credential.user,
      ));
      
      // Trigger OTP sending
      add(SendOtpRequested(event.phoneNumber));
      
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: _getErrorMessage(e.code),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final completer = Completer<void>();
    
    try {
      // Validate phone number format (basic validation)
      if (event.phoneNumber.isEmpty || event.phoneNumber.length < 10) {
        emit(state.copyWith(
          status: AuthStatus.error,
          error: 'Please enter a valid phone number',
        ));
        return;
      }

      emit(state.copyWith(
        status: AuthStatus.loading,
        error: null, // Clear any previous errors
      ));
      
      // Format phone number with country code if needed
      String formattedPhoneNumber = event.phoneNumber;
      if (!formattedPhoneNumber.startsWith('+')) {
        formattedPhoneNumber = '+91$formattedPhoneNumber'; // Default to India (+91)
      }

      // Store the formatted phone number in state
      emit(state.copyWith(phoneNumber: formattedPhoneNumber));

      // Handle verification callbacks
      void handleVerificationCompleted(PhoneAuthCredential credential) async {
        try {
          // If user is already signed in (registration flow), link the phone credential
          if (_auth.currentUser != null) {
            await _auth.currentUser!.linkWithCredential(credential);
            emit(state.copyWith(
              status: AuthStatus.verificationSuccessful,
              user: _auth.currentUser,
            ));
          } else {
            // For login flow, sign in with the credential
            final userCredential = await _auth.signInWithCredential(credential);
            emit(state.copyWith(
              status: AuthStatus.verificationSuccessful,
              user: userCredential.user,
              isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
            ));
          }
          if (!completer.isCompleted) {
            completer.complete();
          }
        } catch (e) {
          if (!completer.isCompleted) {
            emit(state.copyWith(
              status: AuthStatus.verificationFailed,
              error: 'Auto-verification failed. Please enter OTP manually.',
            ));
            completer.completeError(e);
          }
        }
      }

      void handleVerificationFailed(FirebaseAuthException e) {
        if (!completer.isCompleted) {
          String errorMessage = _getErrorMessage(e.code);
          if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later.';
          } else if (e.code == 'invalid-phone-number') {
            errorMessage = 'The provided phone number is not valid.';
          }
          
          emit(state.copyWith(
            status: AuthStatus.verificationFailed,
            error: errorMessage,
          ));
          completer.completeError(e);
        }
      }

      void handleCodeSent(String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          emit(state.copyWith(
            status: AuthStatus.otpSent,
            verificationId: verificationId,
            resendToken: resendToken,
            phoneNumber: formattedPhoneNumber, // Store the formatted phone number
          ));
          completer.complete();
        }
      }

      void handleCodeAutoRetrievalTimeout(String verificationId) {
        if (!completer.isCompleted) {
          emit(state.copyWith(
            status: AuthStatus.otpTimeout,
            verificationId: verificationId,
          ));
          completer.complete();
        }
      }

      // Start the phone number verification
      _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: handleVerificationCompleted,
        verificationFailed: handleVerificationFailed,
        codeSent: handleCodeSent,
        codeAutoRetrievalTimeout: handleCodeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );

      // Wait for the verification process to complete
      await completer.future;
    } on FirebaseAuthException catch (e) {
      if (!completer.isCompleted) {
        emit(state.copyWith(
          status: AuthStatus.error,
          error: _getErrorMessage(e.code),
        ));
      }
    } catch (e) {
      if (!completer.isCompleted) {
        emit(state.copyWith(
          status: AuthStatus.error,
          error: 'Failed to send OTP. Please check your connection and try again.',
        ));
      }
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.verificationInProgress));
      
      // For testing purposes, allow any OTP
      if (event.smsCode == '000000') {
        // If user is already signed in (registration flow), just update the state
        if (_auth.currentUser != null) {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: _auth.currentUser,
            isNewUser: _auth.currentUser?.metadata.creationTime == _auth.currentUser?.metadata.lastSignInTime,
          ));
        } else {
          // For login flow, create a test user
          final testCredential = PhoneAuthProvider.credential(
            verificationId: event.verificationId,
            smsCode: '000000',
          );
          final userCredential = await _auth.signInWithCredential(testCredential);
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: userCredential.user,
            isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
          ));
        }
        return;
      }

      // Create a PhoneAuthCredential with the code
      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );

      // If user is already signed in (registration flow), link the phone credential
      if (_auth.currentUser != null) {
        await _auth.currentUser!.linkWithCredential(credential);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: _auth.currentUser,
        ));
      } else {
        // For login flow, sign in with the credential
        final userCredential = await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: userCredential.user,
            isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.verificationFailed,
            error: 'User not found after verification',
          ));
        }
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.verificationFailed,
        error: _getErrorMessage(e.code),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.verificationFailed,
        error: 'Failed to verify OTP. Please try again.',
      ));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _auth.signOut();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to sign out. Please try again.',
      ));
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'session-expired':
        return 'Session expired. Please try again.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new OTP.';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
