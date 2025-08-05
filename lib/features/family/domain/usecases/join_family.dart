import 'package:dartz/dartz.dart';
import 'package:family_tree_firebase/core/error/failures.dart';
import 'package:family_tree_firebase/core/usecases/usecase.dart';
import 'package:family_tree_firebase/features/family/domain/entities/family.dart';
import 'package:family_tree_firebase/features/family/domain/repositories/family_repository.dart';

class JoinFamily implements UseCase<Family, JoinFamilyParams> {
  final FamilyRepository repository;

  JoinFamily(this.repository);

  @override
  Future<Either<Failure, Family>> call(JoinFamilyParams params) async {
    return await repository.joinFamily(params.inviteCode);
  }
}

class JoinFamilyParams extends Equatable {
  final String inviteCode;

  const JoinFamilyParams({required this.inviteCode});

  @override
  List<Object> get props => [inviteCode];
}
