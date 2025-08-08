import 'package:family_tree_firebase/core/services/firebase_auth_service.dart';
import 'package:family_tree_firebase/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:family_tree_firebase/features/family/data/services/family_service.dart';
import 'package:family_tree_firebase/features/stories/data/services/story_service.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External
  final getStorage = GetStorage();
  sl.registerLazySingleton<GetStorage>(() => getStorage);
  
  // Services
  sl.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(),
  );
  
  sl.registerLazySingleton<FamilyService>(
    () => FamilyService(),
  );
  
  sl.registerLazySingleton<StoryService>(
    () => StoryService(),
  );
  
  // Blocs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc()..add(CheckAuthStatus()),
  );
  
  // Add other blocs here as needed
}
