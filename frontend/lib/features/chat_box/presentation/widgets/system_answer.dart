import 'package:flutter/material.dart';

class SystemAnswer extends StatelessWidget {
  final String answer;

  const SystemAnswer({super.key, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.directional(
            bottomEnd: const Radius.circular(20),
            bottomStart: const Radius.circular(40),
            topEnd: const Radius.circular(20),
            topStart: const Radius.circular(0),
          )
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 20, 20, 20),
        child: Text(
          answer,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
