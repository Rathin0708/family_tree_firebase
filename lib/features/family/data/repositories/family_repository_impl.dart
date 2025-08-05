import 'package:dartz/dartz.dart';
import 'package:family_tree_firebase/core/error/exceptions.dart';
import 'package:family_tree_firebase/core/error/failures.dart';
import 'package:family_tree_firebase/features/family/data/datasources/family_remote_data_source.dart';
import 'package:family_tree_firebase/features/family/domain/entities/family.dart';
import 'package:family_tree_firebase/features/family/domain/repositories/family_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;

  FamilyRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseAuth,
  });

  @override
  Future<Either<Failure, String>> createFamily(String familyName) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(PermissionDeniedFailure('User not authenticated'));
      }

      final family = await remoteDataSource.createFamily(
        familyName,
        currentUser.uid,
      );
      
      return Right(family.id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure('Failed to create family: $e'));
    }
  }

  @override
  Future<Either<Failure, Family>> joinFamily(String inviteCode) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(PermissionDeniedFailure('User not authenticated'));
      }

      final family = await remoteDataSource.joinFamily(
        inviteCode,
        currentUser.uid,
      );
      
      return Right(family);
    } on ServerException catch (e) {
      if (e.message.contains('already a member')) {
        return const Left(AlreadyInFamilyFailure('Already a member of a family'));
      } else if (e.message.contains('expired') || e.message.contains('Invalid')) {
        return const Left(InvalidInviteCodeFailure('Invalid or expired invite code'));
      }
      return Left(ServerFailure(e.message));
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure('Failed to join family: $e'));
    }
  }

  @override
  Future<Either<Failure, Family?>> getCurrentFamily() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(PermissionDeniedFailure('User not authenticated'));
      }

      final family = await remoteDataSource.getCurrentFamily(currentUser.uid);
      return Right(family);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure('Failed to get family: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> generateNewInviteCode() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(PermissionDeniedFailure('User not authenticated'));
      }

      // Get the current family to ensure the user is the admin
      final familyResult = await getCurrentFamily();
      return familyResult.fold(
        (failure) => Left(failure),
        (family) async {
          if (family == null) {
            return const Left(NotFoundFailure('No family found for user'));
          }
          
          // Check if current user is the family admin
          if (family.createdBy != currentUser.uid) {
            return const Left(PermissionDeniedFailure('Only family admin can generate invite codes'));
          }
          
          // Generate new invite code
          final newCode = await remoteDataSource.generateNewInviteCode(family.id);
          return Right(newCode);
        },
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(ServerFailure('Failed to generate invite code: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateInviteCode(String inviteCode) async {
    try {
      final isValid = await remoteDataSource.validateInviteCode(inviteCode);
      return Right(isValid);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to validate invite code: $e'));
    }
  }
}
