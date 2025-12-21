import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:university_qa_system/features/chat_box/presentation/pages/chat_box_page.dart';
import 'package:university_qa_system/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:university_qa_system/init_dependencies.dart';
import 'package:university_qa_system/core/common/widgets/user_shell_layout.dart';
import 'package:university_qa_system/core/common/widgets/admin_shell_layout.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/sign_in_page.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/elit_login_webview.dart';

// GoRouter Navigator Keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _adminShellNavigatorKey = GlobalKey<NavigatorState>();
final _normalUserShellNavigatorKey = GlobalKey<NavigatorState>();

// App Router
final GoRouter appRouter = GoRouter(
  initialLocation: '/sign-in',
  navigatorKey: _rootNavigatorKey,
  refreshListenable: GoRouterRefreshStream(serviceLocator<AuthBloc>().stream),
  redirect: (context, state) {
    final authState = serviceLocator<AuthBloc>().state;
    final isSigningIn = state.matchedLocation == '/sign-in';
    final isAuthWebview = state.matchedLocation == '/auth-webview';

    if (authState is AuthSuccess) {
      if (isSigningIn || isAuthWebview) {
        final role = authState.user.role;

        if (role == 'Admin') return '/admin-dashboard';
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
    // Sign In Page
    GoRoute(
      name: 'signIn',
      path: '/sign-in',
      builder: (context, state) => const SignInPage(),
    ),

    // ELIT Authentication Webview
    GoRoute(
      name: 'authWebview',
      path: '/auth-webview',
      builder: (context, state) => const ElitLoginWebview(),
    ),

    // Admin Shell Route
    ShellRoute(
      navigatorKey: _adminShellNavigatorKey,
      builder: (context, state, child) {
        return AdminShellLayout(child: child);
      },
      routes: [
        GoRoute(
          name: 'AdminDashboard',
          path: '/admin-dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          name: 'AdminPopularQuestions',
          path: '/admin-popular-questions',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Popular Questions'))),
        ),
        GoRoute(
          name: 'AdminUsers',
          path: '/admin-users',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Admin User Management'))),
        ),
        GoRoute(
          name: 'AdminDocuments',
          path: '/admin-documents',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Document Management'))),
        ),
        GoRoute(
          name: 'AdminAPISettings',
          path: '/admin-api-settings',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Admin API Settings'))),
        ),
      ],
    ),

    // Normal User Shell Route
    ShellRoute(
      navigatorKey: _normalUserShellNavigatorKey,
      builder: (context, state, child) {
        return UserShellLayout(child: child);
      },
      routes: [
        GoRoute(
          name: 'UserQ&A',
          path: '/qa',
          builder: (context, state) => const ChatBoxPage(),
        ),
        GoRoute(
          name: 'UserDocuments',
          path: '/user-documents',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Documents Page'))),
        ),
        GoRoute(
          name: 'UserPopularQuestions',
          path: '/user-popular-questions',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Popular Questions Page'))),
        )
      ],
    ),

    GoRoute(
      name: 'Information&Logout',
      path: '/information-and-logout',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Information and Logout Page'))),
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
