import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:university_qa_system/init_dependencies.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/sign_in_page.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/elit_login_webview.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/sign-in',
  refreshListenable: GoRouterRefreshStream(serviceLocator<AuthBloc>().stream),
  redirect: (context, state) {
    final authState = serviceLocator<AuthBloc>().state;
    final isSigningIn = state.matchedLocation == '/sign-in';
    final isAuthWebview = state.matchedLocation == '/auth-webview';

    if (authState is AuthSuccess) {
      if (isSigningIn || isAuthWebview) {
        final role = authState.user.role;
        final isManager = authState.user.isFacultyManager;

        if (role == 'Admin') return '/admin-dashboard';
        if (isManager) return '/faculty-manager-dashboard';
        return '/qa';
      }
      return null;
    }

    if (authState is AuthFailure || authState is AuthInitial) {
      if (!isSigningIn && !isAuthWebview) {
        return '/sign-in';
      }
    }

    return null;
  },
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
    GoRoute(
      name: 'adminDashboard',
      path: '/admin-dashboard',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Dashboard'))),
    ),
    GoRoute(
      name: 'facultyManagerDashboard',
      path: '/faculty-manager-dashboard',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Faculty Manager Dashboard'))),
    ),
    GoRoute(
      name: 'qa',
      path: '/qa',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Q&A Page'))),
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
