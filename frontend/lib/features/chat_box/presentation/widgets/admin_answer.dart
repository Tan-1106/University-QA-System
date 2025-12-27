import 'package:flutter/material.dart';

class AdminAnswer extends StatefulWidget {
  final String answer;

  const AdminAnswer({
    super.key,
    required this.answer
  });

  @override
  State<AdminAnswer> createState() {
    return _SystemAnswerState();
  }
}

class _SystemAnswerState extends State<AdminAnswer> {
  String currentFeedback = '';

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
              backgroundImage: AssetImage('assets/images/admin.png'),
              radius: 20,
            ),
            Flexible(
              child: Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
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
                    widget.answer,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
