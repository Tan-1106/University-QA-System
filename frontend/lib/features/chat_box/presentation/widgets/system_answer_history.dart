import 'package:flutter/material.dart';

class SystemAnswerHistory extends StatelessWidget {
  final String answer;
  final String? feedback;

  const SystemAnswerHistory({
    super.key,
    required this.answer,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                  child: Text(
                    answer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (feedback != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Phản hồi của bạn: ',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              Icon(
                feedback == 'Like' ? Icons.thumb_up : Icons.thumb_down,
                color: feedback == 'Like' ? Colors.green : Colors.red,
              ),
            ],
          ),
      ],
    );
  }
}
