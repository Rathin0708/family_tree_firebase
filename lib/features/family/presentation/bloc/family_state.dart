import 'package:equatable/equatable.dart';
import 'package:family_tree_firebase/features/family/domain/entities/family.dart';

abstract class FamilyState extends Equatable {
  const FamilyState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when the family bloc is first created
class FamilyInitial extends FamilyState {
  const FamilyInitial();
}

/// State when family data is being loaded
class FamilyLoading extends FamilyState {
  const FamilyLoading();
}

/// State when family data has been successfully loaded
class FamilyLoadSuccess extends FamilyState {
  final Family family;
  final bool isNewlyCreated;
  
  const FamilyLoadSuccess({
    required this.family,
    this.isNewlyCreated = false,
  });
  
  @override
  List<Object?> get props => [family, isNewlyCreated];
}

/// State when no family is found for the current user
class FamilyLoadEmpty extends FamilyState {
  const FamilyLoadEmpty();
}

/// State when a new invite code has been generated
class InviteCodeGenerated extends FamilyState {
  final String inviteCode;
  final DateTime expiresAt;
  
  const InviteCodeGenerated({
    required this.inviteCode,
    required this.expiresAt,
  });
  
  @override
  List<Object?> get props => [inviteCode, expiresAt];
}

/// State when invite code is being validated
class InviteCodeValidating extends FamilyState {
  final String inviteCode;
  
  const InviteCodeValidating(this.inviteCode);
  
  @override
  List<Object?> get props => [inviteCode];
}

/// State when invite code is valid
class InviteCodeValid extends FamilyState {
  final String inviteCode;
  final String familyName;
  
  const InviteCodeValid({
    required this.inviteCode,
    required this.familyName,
  });
  
  @override
  List<Object?> get props => [inviteCode, familyName];
}

/// State when an error occurs
class FamilyError extends FamilyState {
  final String message;
  final StackTrace? stackTrace;
  
  const FamilyError({
    required this.message,
    this.stackTrace,
  });
  
  @override
  List<Object?> get props => [message, stackTrace];
}
