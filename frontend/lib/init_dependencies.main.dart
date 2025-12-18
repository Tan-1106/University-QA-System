part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  _initAuth();
}

Future<void> _initCore() async {
  // Internet Connection Checker
  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerFactory<ConnectionChecker>(
        () => ConnectionCheckerImpl(
      serviceLocator(),
    ),
  );

  // Secure Storage Service
  serviceLocator.registerLazySingleton(() => const FlutterSecureStorage());
  serviceLocator.registerLazySingleton(
        () => SecureStorageService(
      serviceLocator(),
    ),
  );

  // Shared Preferences Service
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(
        () => SharedPreferencesService(sharedPreferences),
  );

  // Dio Client
  serviceLocator.registerLazySingleton<Dio>(() {
    final dio = Dio();
    final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';

    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (const bool.fromEnvironment('dart.vm.product') == false) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        secureStorageService: serviceLocator(),
      ),
    );

    return dio;
  });
}

void _initAuth() {
  // Auth Remote Data Source
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      serviceLocator(),
    ),
  );

  // Auth Repository
  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );

  // Sign In With ELIT Use Case
  serviceLocator.registerFactory(
    () => SignInWithELIT(
      serviceLocator(),
    ),
  );


  // Verify User Access Use Case
  serviceLocator.registerFactory(
    () => VerifyUserAccess(
      serviceLocator(),
    ),
  );


  // Auth Bloc
  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      serviceLocator(),
      serviceLocator(),
    ),
  );
}
