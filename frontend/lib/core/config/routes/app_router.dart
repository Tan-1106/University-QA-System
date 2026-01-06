import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/logout_page.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/register_page.dart';
import 'package:university_qa_system/features/authentication/presentation/pages/system_sign_in_page.dart';
import 'package:university_qa_system/features/chat_box/presentation/pages/chat_box_page.dart';
import 'package:university_qa_system/features/chat_box/presentation/pages/qa_history_record_page.dart';
import 'package:university_qa_system/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:university_qa_system/features/document/presentation/pages/documents_page.dart';
import 'package:university_qa_system/features/document/presentation/pages/view_document_page.dart';
import 'package:university_qa_system/features/popular_question/presentation/pages/admin_popular_questions_page.dart';
import 'package:university_qa_system/features/popular_question/presentation/pages/student_popular_questions_page.dart';
import 'package:university_qa_system/features/user_management/presentation/pages/user_management_page.dart';
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
    final currentLocation = state.matchedLocation;

    final publicRoutes = ['/sign-in', '/auth-webview', '/system-sign-in', '/register'];
    final isPublicRoute = publicRoutes.contains(currentLocation);

    if (authState is AuthLoggedOut) {
      if (!isPublicRoute) {
        return '/sign-in';
      }
      return null;
    }
    if (authState is AuthSuccess) {
      if (isPublicRoute) {
        final role = authState.user.role;

        if (role == 'Admin') return '/admin-dashboard';
        return '/qa';
      }
      return null;
    }
    if (authState is AuthFailure || authState is AuthInitial) {
      if (!isPublicRoute) {
        return '/sign-in';
      }
    }
    if (authState is AuthRegistered) {
      if (currentLocation != '/system-sign-in') {
        return '/system-sign-in';
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
    GoRoute(
      name: 'NormalSignIn',
      path: '/system-sign-in',
      builder: (context, state) => const SystemSignInPage(),
    ),
    GoRoute(
      name: 'Register',
      path: '/register',
      builder: (context, state) => const RegisterPage(),
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
          builder: (context, state) => const AdminPopularQuestionsPage(),
        ),
        GoRoute(
          name: 'AdminUsers',
          path: '/admin-users',
          builder: (context, state) => const UserManagementPage(),
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
          builder: (context, state) => const DocumentsPage(),
        ),
        GoRoute(
          name: 'UserPopularQuestions',
          path: '/user-popular-questions',
          builder: (context, state) => const StudentPopularQuestionsPage(),
        ),
        GoRoute(
          name: 'QAHistoryDetails',
          path: '/qa-history/:questionId',
          builder: (context, state) {
            final questionId = state.pathParameters['questionId']!;
            return QaHistoryDetailsPage(questionId: questionId);
          },
        ),
        GoRoute(
          name: 'DocumentViewer',
          path: '/document-viewer',
          builder: (context, state) => const ViewDocumentPage(),
        )
      ],
    ),

    GoRoute(
      name: 'Information&Logout',
      path: '/information-and-logout',
      builder: (context, state) => const LogoutPage(),
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
