import 'core/config/theme/theme.dart';
import 'core/utils/create_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:university_qa_system/init_dependencies.dart';
import 'package:university_qa_system/core/utils/app_bloc_observer.dart';
import 'package:university_qa_system/core/config/routes/app_router.dart';
import 'features/user_management/presentation/bloc/user_management_bloc.dart';
import 'features/chat/presentation/bloc/history_details/history_details_bloc.dart';
import 'features/document/presentation/bloc/document_list/document_list_bloc.dart';
import 'package:university_qa_system/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:university_qa_system/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:university_qa_system/features/chat/presentation/bloc/history/history_bloc.dart';
import 'package:university_qa_system/features/document/presentation/provider/document_provider.dart';
import 'package:university_qa_system/features/api_management/presentation/bloc/api_key/api_keys_bloc.dart';
import 'package:university_qa_system/features/popular_question/presentation/bloc/admin_pq/admin_pq_bloc.dart';
import 'package:university_qa_system/features/popular_question/presentation/bloc/student_pq/student_pq_bloc.dart';
import 'package:university_qa_system/features/document/presentation/bloc/document_viewer/document_viewer_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initDependencies();
  Bloc.observer = AppBlocObserver();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => serviceLocator<DocumentProvider>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
          BlocProvider(create: (_) => serviceLocator<DashboardBloc>()),
          BlocProvider(create: (_) => serviceLocator<ChatBoxBloc>()),
          BlocProvider(create: (_) => serviceLocator<HistoryBloc>()),
          BlocProvider(create: (_) => serviceLocator<HistoryDetailsBloc>()),
          BlocProvider(create: (_) => serviceLocator<DocumentListBloc>()),
          BlocProvider(create: (_) => serviceLocator<DocumentViewerBloc>()),
          BlocProvider(create: (_) => serviceLocator<StudentPQBloc>()),
          BlocProvider(create: (_) => serviceLocator<AdminPQBloc>()),
          BlocProvider(create: (_) => serviceLocator<UserManagementBloc>()),
          BlocProvider(create: (_) => serviceLocator<ApiKeysBloc>()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Arimo", "Nunito");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      title: 'University Q&A System',
      routerConfig: appRouter,
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
