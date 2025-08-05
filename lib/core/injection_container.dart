import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:family_tree_firebase/features/family/data/datasources/family_remote_data_source.dart';
import 'package:family_tree_firebase/features/family/data/repositories/family_repository_impl.dart';
import 'package:family_tree_firebase/features/family/domain/repositories/family_repository.dart';
import 'package:family_tree_firebase/features/family/domain/usecases/create_family.dart';
import 'package:family_tree_firebase/features/family/domain/usecases/generate_invite_code.dart';
import 'package:family_tree_firebase/features/family/domain/usecases/get_current_family.dart';
import 'package:family_tree_firebase/features/family/domain/usecases/join_family.dart';
import 'package:family_tree_firebase/features/family/domain/usecases/validate_invite_code.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  
  // Data sources
  sl.registerLazySingleton<FamilyRemoteDataSource>(
    () => FamilyRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  
  // Repository
  sl.registerLazySingleton<FamilyRepository>(
    () => FamilyRepositoryImpl(
      remoteDataSource: sl(),
      firebaseAuth: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => CreateFamily(sl()));
  sl.registerLazySingleton(() => JoinFamily(sl()));
  sl.registerLazySingleton(() => GetCurrentFamily(sl()));
  sl.registerLazySingleton(() => GenerateInviteCode(sl()));
  sl.registerLazySingleton(() => ValidateInviteCode(sl()));
  
  // BLoC
  sl.registerFactory(
    () => FamilyBloc(
      createFamily: sl(),
      joinFamily: sl(),
      getCurrentFamily: sl(),
      generateInviteCode: sl(),
      validateInviteCode: sl(),
    ),
  );
}
