import 'package:university_qa_system/core/utils/app_bloc_observer.dart';
import 'package:university_qa_system/features/dashboard/presentation/bloc/dashboard_bloc.dart';

import 'core/config/theme/theme.dart';
import 'core/utils/create_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:university_qa_system/init_dependencies.dart';
import 'package:university_qa_system/core/config/routes/app_router.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initDependencies();
  Bloc.observer = AppBlocObserver();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<DashboardBloc>()),
      ],
      child: const MyApp(),
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
