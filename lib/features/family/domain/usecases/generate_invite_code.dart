import 'package:dartz/dartz.dart';
import 'package:family_tree_firebase/core/error/failures.dart';
import 'package:family_tree_firebase/core/usecases/usecase.dart';
import 'package:family_tree_firebase/features/family/domain/repositories/family_repository.dart';

class GenerateInviteCode implements UseCase<String, NoParams> {
  final FamilyRepository repository;

  GenerateInviteCode(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.generateNewInviteCode();
  }
}
