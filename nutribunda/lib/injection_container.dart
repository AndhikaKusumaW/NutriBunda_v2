import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // TODO: Register dependencies here
  // This will be populated as we implement features
  
  // Example structure:
  // // Providers
  // sl.registerFactory(() => AuthProvider(authUseCase: sl()));
  
  // // Use Cases
  // sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  
  // // Repositories
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //   ),
  // );
  
  // // Data Sources
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(client: sl()),
  // );
  
  // // Core
  // sl.registerLazySingleton(() => Dio());
}
