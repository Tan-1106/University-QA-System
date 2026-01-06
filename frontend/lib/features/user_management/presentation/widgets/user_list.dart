import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/user_management/domain/entities/users.dart';

import '../bloc/user_management_bloc.dart';

class UserList extends StatefulWidget {
  final Function(
    String userId,
    bool currentBanStatus,
    String userRole,
    String? userFaculty,
  )
  onUserTap;

  const UserList({super.key, required this.onUserTap});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final ScrollController _scrollController = ScrollController();

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<UserManagementBloc>().state;

      if (state is UserManagementStateLoaded && state.hasMore && !state.isLoadingMoreUsers) {
        context.read<UserManagementBloc>().add(
          LoadUserListEvent(
            page: state.currentPage + 1,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementBloc, UserManagementState>(
      buildWhen: (previous, current) => current is UserManagementLoading || current is UserManagementStateLoaded,
      builder: (context, state) {
        List<User> users = [];
        bool isLoadingMore = false;

        if (state is UserManagementLoading) {
          return const Center(child: Loader());
        }

        if (state is UserManagementStateLoaded) {
          users = state.users;
          isLoadingMore = state.isLoadingMoreUsers;
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: isLoadingMore ? users.length + 1 : users.length,
          itemBuilder: (context, index) {
            if (index >= users.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Loader()),
              );
            }
            final user = users[index];
            return Column(
              children: [
                InkWell(
                  onTap: () => widget.onUserTap(
                    user.id,
                    user.banned,
                    user.role,
                    user.faculty,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.imageUrl),
                    ),
                    title: Text(
                      user.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.sub,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${user.role} - ${user.faculty ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: user.banned ? const Icon(Icons.block, color: Colors.red) : const Icon(Icons.check, color: Colors.green),
                  ),
                ),
                const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}
