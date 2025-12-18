import 'package:go_router/go_router.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/elit_login_webview.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/sign_in_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/sign-in',
  routes: <RouteBase>[
    GoRoute(
      name: 'signIn',
      path: '/sign-in',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      name: 'authWebview',
      path: '/auth-webview',
      builder: (context, state) => const ElitLoginWebview(),
    ),
  ],
);
