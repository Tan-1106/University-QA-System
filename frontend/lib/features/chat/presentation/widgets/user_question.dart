import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/authentication/presentation/bloc/auth_bloc.dart';

class UserQuestion extends StatelessWidget {
  final String question;

  const UserQuestion({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Card(
            color: Theme.of(context).colorScheme.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.directional(
                bottomEnd: Radius.circular(20),
                bottomStart: Radius.circular(20),
                topEnd: Radius.circular(0),
                topStart: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Text(
                question,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return CircleAvatar(
                backgroundImage: NetworkImage(state.user.imageUrl),
                radius: 20,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
