part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  _initAuth();
  _initDashboard();
  _initChatBox();
  _initDocument();
  _initPopularQuestions();
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

  // Dio Client
  serviceLocator.registerLazySingleton<Dio>(() {
    final dio = Dio();
    var envBaseUrl = dotenv.env['BASE_URL'];
    String baseUrl;
    if (envBaseUrl != null && envBaseUrl.isNotEmpty) {
      if (!envBaseUrl.startsWith('http')) {
        envBaseUrl = 'https://$envBaseUrl';
      }
      baseUrl = envBaseUrl.endsWith('/') ? envBaseUrl.substring(0, envBaseUrl.length - 1) : envBaseUrl;
    } else {
      baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';
    }

    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 180),
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
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => SystemAccountRegistrationUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => SignInWithSystemAccountUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => SignInWithELITUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => VerifyUserAccessUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => LogOutUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
}

void _initDashboard() {
  serviceLocator.registerFactory<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<DashboardRepository>(
    () => DashboardRepositoryImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<LoadDashboardStatisticUseCase>(
    () => LoadDashboardStatisticUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<LoadDashboardQuestionRecordsUseCase>(
    () => LoadDashboardQuestionRecordsUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardBloc(
      serviceLocator(),
      serviceLocator(),
    ),
  );
}

void _initChatBox() {
  serviceLocator.registerFactory<ChatBoxRemoteDataSource>(
    () => ChatBoxRemoteDataSourceImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<ChatBoxRepository>(
    () => ChatBoxRepositoryImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => AskQuestionUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => SendFeedbackUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => GetQAHistoryUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => ViewQARecordDetailsUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => ChatBoxBloc(
      serviceLocator(),
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => HistoryBloc(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => HistoryDetailsBloc(
      serviceLocator(),
    ),
  );
}

void _initDocument() {
  serviceLocator.registerFactory<DocumentRemoteDataSource>(
    () => DocumentRemoteDataSourceImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<DocumentRepository>(
    () => DocumentRepositoryImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetExistingFiltersUseCase>(
    () => GetExistingFiltersUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetGeneralDocumentsUseCase>(
    () => GetGeneralDocumentsUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetFacultyDocumentsUseCase>(
    () => GetFacultyDocumentsUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<ViewDocumentUseCase>(
    () => ViewDocumentUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DocumentFilterBloc(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DocumentListBloc(
      serviceLocator(),
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DocumentViewerBloc(
      serviceLocator(),
    ),
  );
}

void _initPopularQuestions() {
  serviceLocator.registerFactory<PopularQuestionDataSource>(
    () => PopularQuestionDataSourceImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<PopularQuestionsRepository>(
    () => PopularQuestionsRepositoryImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GeneratePopularQuestionsUseCase>(
    () => GeneratePopularQuestionsUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<LoadExistingFacultiesUseCase>(
        () => LoadExistingFacultiesUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<LoadStudentPopularQuestionsUseCase>(
    () => LoadStudentPopularQuestionsUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<LoadAdminPopularQuestionsUseCase>(
    () => LoadAdminPopularQuestionsUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => StudentPQBloc(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
      () => AdminPQBloc(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      )
  );
}
