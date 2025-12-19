import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';

class ManagerShellLayout extends StatelessWidget {
  final Widget child;

  const ManagerShellLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/manager-popular-faculty-questions')) return 1;
    if (location.startsWith('/manager-faculty-students')) return 2;
    if (location.startsWith('/manager-documents')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/manager-dashboard');
        break;
      case 1:
        context.go('/manager-popular-faculty-questions');
        break;
      case 2:
        context.go('/manager-faculty-students');
        break;
      case 3:
        context.go('/manager-documents');
        break;
    }
  }

  String _getTitle(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Câu hỏi phổ biến';
      case 2:
        return 'Quản lý người dùng';
      case 3:
        return 'Quản lý tài liệu';
      default:
        return 'Manager Panel';
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _getTitle(selectedIndex),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: NavigationDrawer(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    _onItemTapped(index, context);
                    Navigator.pop(context);
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'UniWise',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28),
                      child: Divider(),
                    ),
                    const NavigationDrawerDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    const NavigationDrawerDestination(
                      icon: Icon(Icons.question_answer_outlined),
                      selectedIcon: Icon(Icons.question_answer),
                      label: Text('Câu hỏi phổ biến'),
                    ),
                    const NavigationDrawerDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Quản lý người dùng'),
                    ),
                    const NavigationDrawerDestination(
                      icon: Icon(Icons.document_scanner_outlined),
                      selectedIcon: Icon(Icons.document_scanner),
                      label: Text('Quản lý tài liệu'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String userName = '';
                  String userEmail = '';
                  String? userImageUrl;

                  if (state is AuthSuccess) {
                    userName = state.user.name;
                    userEmail = state.user.email;
                    userImageUrl = state.user.imageUrl;
                  }

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        child: Row(
                          children: [
                            userImageUrl != null && userImageUrl.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(userImageUrl),
                                    onBackgroundImageError: (_, _) => const Icon(Icons.person),
                                  )
                                : const CircleAvatar(child: Icon(Icons.person)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    userEmail,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
