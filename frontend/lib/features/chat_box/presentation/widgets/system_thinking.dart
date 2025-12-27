import 'package:flutter/material.dart';

class SystemThinking extends StatelessWidget {
  const SystemThinking({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundImage: AssetImage('assets/images/chat_bot.png'),
          radius: 20,
        ),
        Flexible(
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.directional(
                bottomEnd: Radius.circular(20),
                bottomStart: Radius.circular(20),
                topEnd: Radius.circular(20),
                topStart: Radius.circular(0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Đang suy nghĩ...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
