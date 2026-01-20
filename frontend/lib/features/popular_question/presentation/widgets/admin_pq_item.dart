import 'package:flutter/material.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_question.dart';

class AdminPQItem extends StatelessWidget {
  final Function() onEditPressed;

  final PopularQuestionEntity question;

  const AdminPQItem({super.key, required this.onEditPressed, required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
        ),
        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide.none,
        ),
        iconColor: Theme.of(context).colorScheme.onPrimary,
        collapsedIconColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          question.question,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      const Text(
                        'Trạng thái: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        question.isDisplay ? 'Đang hiển thị' : 'Không hiển thị',
                        style: TextStyle(
                          color: question.isDisplay
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      const Text(
                        'Phạm vi: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        question.summary.facultyScope ?? 'Chung',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Câu trả lời: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    question.answer,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onEditPressed,
                      child: Text(
                        'Chỉnh sửa nội dung và trạng thái',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
