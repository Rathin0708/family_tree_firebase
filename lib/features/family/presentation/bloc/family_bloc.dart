import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:family_tree_firebase/core/error/failures.dart';
import 'package:family_tree_firebase/core/usecases/usecase.dart';
import 'package:family_tree_firebase/features/family/domain/entities/family.dart';
import 'package:family_tree_firebase/features/family/domain/repositories/family_repository.dart';
import 'package:family_tree_firebase/features/family/domain/usecases/create_family.dart';
import 'package:family_tree_firebase/features/family/domain/usecases/generate_invite_code.dart';
import 'package:family_tree_firebase/features/family/domain/usecases/get_current_family.dart';
import 'package:family_tree_firebase/features/family/domain/usecases/join_family.dart';
import 'package:family_tree_firebase/features/family/domain/usecases/validate_invite_code.dart';

import 'family_event.dart';
import 'family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final CreateFamily _createFamily;
  final JoinFamily _joinFamily;
  final GetCurrentFamily _getCurrentFamily;
  final GenerateInviteCode _generateInviteCode;
  final ValidateInviteCode _validateInviteCode;
  
  FamilyBloc({
    required CreateFamily createFamily,
    required JoinFamily joinFamily,
    required GetCurrentFamily getCurrentFamily,
    required GenerateInviteCode generateInviteCode,
    required ValidateInviteCode validateInviteCode,
  })  : _createFamily = createFamily,
        _joinFamily = joinFamily,
        _getCurrentFamily = getCurrentFamily,
        _generateInviteCode = generateInviteCode,
        _validateInviteCode = validateInviteCode,
        super(const FamilyInitial()) {
    on<CreateFamilyEvent>(_onCreateFamily);
    on<JoinFamilyEvent>(_onJoinFamily);
    on<LoadFamilyEvent>(_onLoadFamily);
    on<GenerateInviteCodeEvent>(_onGenerateInviteCode);
    on<ValidateInviteCodeEvent>(_onValidateInviteCode);
    on<ResetFamilyStateEvent>(_onResetState);
  }

  Future<void> _onCreateFamily(
    CreateFamilyEvent event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    
    final result = await _createFamily(CreateFamilyParams(
      familyName: event.familyName,
    ));
    
    result.fold(
      (failure) => emit(FamilyError(message: _mapFailureToMessage(failure))),
      (family) => emit(FamilyLoadSuccess(
        family: family,
        isNewlyCreated: true,
      )),
    );
  }

  Future<void> _onJoinFamily(
    JoinFamilyEvent event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    
    final result = await _joinFamily(JoinFamilyParams(
      inviteCode: event.inviteCode,
    ));
    
    result.fold(
      (failure) => emit(FamilyError(message: _mapFailureToMessage(failure))),
      (family) => emit(FamilyLoadSuccess(family: family)),
    );
  }

  Future<void> _onLoadFamily(
    LoadFamilyEvent event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    
    final result = await _getCurrentFamily(NoParams());
    
    result.fold(
      (failure) {
        if (failure is NotFoundFailure) {
          emit(const FamilyLoadEmpty());
        } else {
          emit(FamilyError(message: _mapFailureToMessage(failure)));
        }
      },
      (family) => emit(FamilyLoadSuccess(family: family)),
    );
  }

  Future<void> _onGenerateInviteCode(
    GenerateInviteCodeEvent event,
    Emitter<FamilyState> emit,
  ) async {
    final result = await _generateInviteCode(NoParams());
    
    result.fold(
      (failure) => emit(FamilyError(message: _mapFailureToMessage(failure))),
      (inviteCode) => emit(InviteCodeGenerated(
        inviteCode: inviteCode,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      )),
    );
  }

  Future<void> _onValidateInviteCode(
    ValidateInviteCodeEvent event,
    Emitter<FamilyState> emit,
  ) async {
    emit(InviteCodeValidating(event.inviteCode));
    
    final result = await _validateInviteCode(ValidateInviteCodeParams(
      inviteCode: event.inviteCode,
    ));
    
    result.fold(
      (failure) => emit(FamilyError(message: _mapFailureToMessage(failure))),
      (family) => emit(InviteCodeValid(
        inviteCode: event.inviteCode,
        familyName: family.name,
      )),
    );
  }

  void _onResetState(
    ResetFamilyStateEvent event,
    Emitter<FamilyState> emit,
  ) {
    emit(const FamilyInitial());
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your internet connection.';
      case InvalidInviteCodeFailure:
        return 'Invalid or expired invite code. Please check and try again.';
      case AlreadyInFamilyFailure:
        return 'You are already a member of a family.';
      case PermissionDeniedFailure:
        return 'You do not have permission to perform this action.';
      case FamilyNotFoundFailure:
        return 'Family not found. The family may have been deleted.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
