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
  final int? resendToken;
  final bool isNewUser;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.verificationId,
    this.resendToken,
    this.isNewUser = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    String? verificationId,
    int? resendToken,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      verificationId: verificationId ?? this.verificationId,
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
      
      // Update user profile with phone number (custom claim or Firestore would be better)
      await credential.user?.updatePhoneNumber(event.phoneNumber as PhoneAuthCredential);

      // State will be updated by the authStateChanges listener
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
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      
      await _auth.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verify on Android devices
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(state.copyWith(
            status: AuthStatus.verificationFailed,
            error: _getErrorMessage(e.code),
          ));
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(state.copyWith(
            status: AuthStatus.otpSent,
            verificationId: verificationId,
            resendToken: resendToken,
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timeout, you might want to handle this case
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to send OTP. Please try again.',
      ));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.verificationInProgress));
      
      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );

      await _auth.signInWithCredential(credential);
      
      emit(state.copyWith(
        status: AuthStatus.verificationSuccessful,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.verificationFailed,
        error: _getErrorMessage(e.code),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
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
