import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:university_qa_system/features/chat_box/presentation/widgets/user_history.dart';

class UserShellLayout extends StatelessWidget {
  final Widget child;

  const UserShellLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/user-documents')) return 1;
    if (location.startsWith('/user-popular-questions')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/qa');
        break;
      case 1:
        context.go('/user-documents');
        break;
      case 2:
        context.go('/user-popular-questions');
        break;
    }
  }

  String _getTitle(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return 'Hỏi đáp';
      case 1:
        return 'Tài liệu';
      case 2:
        return 'Câu hỏi phổ biến';
      default:
        return 'User Panel';
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'UniWise',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ),
              ListTile(
                leading: const Icon(Icons.question_answer),
                title: const Text('Hỏi đáp'),
                selected: selectedIndex == 0,
                onTap: () {
                  _onItemTapped(0, context);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.document_scanner),
                title: const Text('Tài liệu'),
                selected: selectedIndex == 1,
                onTap: () {
                  _onItemTapped(1, context);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Câu hỏi phổ biến'),
                selected: selectedIndex == 2,
                onTap: () {
                  _onItemTapped(2, context);
                  Navigator.pop(context);
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ),
              Expanded(
                child: UserHistory(
                  onTap: (question) {
                    context.go('/qa-history/${question.id}');
                    Navigator.pop(context);
                  },
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
