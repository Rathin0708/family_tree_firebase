import 'package:dartz/dartz.dart';
import 'package:family_tree_firebase/core/error/failures.dart';
import 'package:family_tree_firebase/core/usecases/usecase.dart';
import 'package:family_tree_firebase/features/family/domain/entities/family.dart';
import 'package:family_tree_firebase/features/family/domain/repositories/family_repository.dart';

class GetCurrentFamily implements UseCase<Family?, NoParams> {
  final FamilyRepository repository;

  GetCurrentFamily(this.repository);

  @override
  Future<Either<Failure, Family?>> call(NoParams params) async {
    return await repository.getCurrentFamily();
  }
}
