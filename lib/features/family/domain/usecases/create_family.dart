import 'package:dartz/dartz.dart';
import 'package:family_tree_firebase/core/error/failures.dart';
import 'package:family_tree_firebase/core/usecases/usecase.dart';
import 'package:family_tree_firebase/features/family/domain/entities/family.dart';
import 'package:family_tree_firebase/features/family/domain/repositories/family_repository.dart';

class CreateFamily implements UseCase<Family, CreateFamilyParams> {
  final FamilyRepository repository;

  CreateFamily(this.repository);

  @override
  Future<Either<Failure, Family>> call(CreateFamilyParams params) async {
    return await repository.createFamily(params.familyName);
  }
}

class CreateFamilyParams extends Equatable {
  final String familyName;

  const CreateFamilyParams({required this.familyName});

  @override
  List<Object> get props => [familyName];
}
