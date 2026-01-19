import 'package:flutter/material.dart';
import 'package:university_qa_system/core/common/widgets/typing_indicator.dart';

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
            elevation: 0,
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
                  Text(
                    'Đang suy nghĩ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TypingIndicator(dotColor: Theme.of(context).colorScheme.onPrimaryContainer),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
