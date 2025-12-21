import 'package:flutter/material.dart';

class UserQuestion extends StatelessWidget {
  final String question;

  const UserQuestion({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.directional(
          bottomEnd: const Radius.circular(40),
          bottomStart: const Radius.circular(20),
          topEnd: const Radius.circular(0),
          topStart: const Radius.circular(20),
        )
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
        child: Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
