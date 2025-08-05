import 'package:equatable/equatable.dart';

abstract class FamilyEvent extends Equatable {
  const FamilyEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a new family
class CreateFamilyEvent extends FamilyEvent {
  final String familyName;
  
  const CreateFamilyEvent(this.familyName);
  
  @override
  List<Object?> get props => [familyName];
}

/// Event to join an existing family using an invite code
class JoinFamilyEvent extends FamilyEvent {
  final String inviteCode;
  
  const JoinFamilyEvent(this.inviteCode);
  
  @override
  List<Object?> get props => [inviteCode];
}

/// Event to load the current user's family
class LoadFamilyEvent extends FamilyEvent {
  const LoadFamilyEvent();
}

/// Event to generate a new invite code for the current family
class GenerateInviteCodeEvent extends FamilyEvent {
  const GenerateInviteCodeEvent();
}

/// Event to validate an invite code
class ValidateInviteCodeEvent extends FamilyEvent {
  final String inviteCode;
  
  const ValidateInviteCodeEvent(this.inviteCode);
  
  @override
  List<Object?> get props => [inviteCode];
}

/// Event to reset the family state
class ResetFamilyStateEvent extends FamilyEvent {
  const ResetFamilyStateEvent();
}
