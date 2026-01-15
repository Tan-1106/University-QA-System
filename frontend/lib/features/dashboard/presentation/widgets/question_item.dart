import 'package:flutter/material.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/question_records.dart';

class QuestionItem extends StatelessWidget {
  final String userSub;
  final Question question;
  final VoidCallback? onTap;

  const QuestionItem({
    super.key,
    required this.userSub,
    required this.question,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MSSV: $userSub',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    question.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        _getFeedbackIcon(question.feedback ?? 'None'),
                        size: 16,
                        color: _getFeedbackColor(question.feedback ?? 'None'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        question.createdAt,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(onPressed: onTap, icon: const Icon(Icons.chevron_right)),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.onSurface,
            thickness: 0.5,
          )
        ],
      ),
    );
  }

  IconData _getFeedbackIcon(String feedback) {
    switch (feedback.toLowerCase()) {
      case 'like':
        return Icons.thumb_up;
      case 'dislike':
        return Icons.thumb_down;
      default:
        return Icons.remove;
    }
  }

  Color _getFeedbackColor(String feedback) {
    switch (feedback.toLowerCase()) {
      case 'like':
        return Colors.green;
      case 'dislike':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
