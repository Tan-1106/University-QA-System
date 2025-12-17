import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/elit_login_webview.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/sign_in_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/sign-in',
  routes: <RouteBase>[
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInPage(),
      routes: [
        GoRoute(
          path: '/auth-webview',
          builder: (context, state) => const ElitLoginWebview(),
        ),
      ],
    ),
  ],
);
