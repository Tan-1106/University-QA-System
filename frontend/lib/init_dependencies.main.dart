part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  _initAuth();
  _initDashboard();
  _initChatBox();
  _initDocument();
  _initPopularQuestions();
  _initUserManagement();
  _initAPIKeyListManagement();
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
    () => SignUpSystemAccountUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => SignInWithSystemAccountUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => SignInWithELitUseCase(
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

  serviceLocator.registerFactory<GetStatisticsUseCase>(
    () => GetStatisticsUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetQuestionsUseCase>(
    () => GetQuestionsUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<RespondToQuestionUseCase>(
    () => RespondToQuestionUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DashboardBloc(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
}

void _initChatBox() {
  serviceLocator.registerFactory<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<ChatBoxRepository>(
    () => ChatRepositoryImpl(
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
    () => GetQuestionHistoryUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => ViewQuestionDetailsUseCase(
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

  serviceLocator.registerFactory<GetDocumentFiltersUseCase>(
    () => GetDocumentFiltersUseCase(
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

  serviceLocator.registerFactory<UploadPDFDocumentUseCase>(
    () => UploadPDFDocumentUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UpdateDocumentBasicInfoUseCase>(
    () => UpdateDocumentBasicInfoUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<DeleteDocumentUseCase>(
    () => DeleteDocumentUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DocumentListBloc(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DocumentViewerBloc(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => DocumentProvider(
      serviceLocator(),
      serviceLocator(),
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

  serviceLocator.registerFactory<AssignFacultyScopeToQuestionUseCase>(
    () => AssignFacultyScopeToQuestionUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UpdateQuestionUseCase>(
    () => UpdateQuestionUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<ToggleQuestionDisplayStatusUseCase>(
    () => ToggleQuestionDisplayStatusUseCase(
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
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
}

void _initUserManagement() {
  serviceLocator.registerFactory<UserManagementRemoteDataSource>(
    () => UserManagementDataSourceImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserManagementRepository>(
    () => UserManagementRepositoryImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<LoadAllRolesUseCase>(
    () => LoadAllRolesUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<LoadAllFacultiesUseCase>(
    () => LoadAllFacultiesUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<LoadUsersUseCase>(
    () => LoadUsersUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AssignRoleUseCase>(
    () => AssignRoleUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<ChangeBanStatusUseCase>(
    () => ChangeBanStatusUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => UserManagementBloc(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
}

void _initAPIKeyListManagement() {
  serviceLocator.registerFactory<APIManagementRemoteDataSource>(
    () => APIManagementRemoteDataSourceImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<APIManagementRepository>(
    () => APIManagementRepositoryImpl(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<LoadAPIKeysUseCase>(
    () => LoadAPIKeysUseCase(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<DeleteAPIKeyUseCase>(
    () => DeleteAPIKeyUseCase(
      repository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetKeyModelsUseCase>(
    () => GetKeyModelsUseCase(
      repository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AddAPIKeyUseCase>(
    () => AddAPIKeyUseCase(
      repository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AddKeyModelUseCase>(
    () => AddKeyModelUseCase(
      repository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<ToggleUsingKeyUseCase>(
    () => ToggleUsingKeyUseCase(
      repository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => ApiKeysBloc(
      serviceLocator(),
    ),
  );
}
