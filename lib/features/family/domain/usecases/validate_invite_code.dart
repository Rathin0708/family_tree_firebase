import 'package:dartz/dartz.dart';
import 'package:family_tree_firebase/core/error/failures.dart';
import 'package:family_tree_firebase/core/usecases/usecase.dart';
import 'package:family_tree_firebase/features/family/domain/entities/family.dart';
import 'package:family_tree_firebase/features/family/domain/repositories/family_repository.dart';

class ValidateInviteCode implements UseCase<Family, ValidateInviteCodeParams> {
  final FamilyRepository repository;

  ValidateInviteCode(this.repository);

  @override
  Future<Either<Failure, Family>> call(ValidateInviteCodeParams params) async {
    return await repository.validateInviteCode(params.inviteCode);
  }
}

class ValidateInviteCodeParams extends Equatable {
  final String inviteCode;

  const ValidateInviteCodeParams({required this.inviteCode});

  @override
  List<Object> get props => [inviteCode];
}
