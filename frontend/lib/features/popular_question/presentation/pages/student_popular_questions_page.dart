import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/presentation/bloc/student_pq/student_pq_bloc.dart';
import 'package:university_qa_system/features/popular_question/presentation/widgets/student_pq_list.dart';
import 'package:university_qa_system/features/popular_question/presentation/widgets/student_pq_segmented_button.dart';

class StudentPopularQuestionsPage extends StatefulWidget {
  const StudentPopularQuestionsPage({super.key});

  @override
  State<StudentPopularQuestionsPage> createState() => _StudentPopularQuestionsPageState();
}

class _StudentPopularQuestionsPageState extends State<StudentPopularQuestionsPage> {
  bool _showFacultyOnly = false;

  @override
  void initState() {
    super.initState();
    context.read<StudentPQBloc>().add(GetStudentPopularQuestionsEvent(facultyOnly: _showFacultyOnly));
  }

  void _showQuestionDetailsDialog(BuildContext context, PopularQuestion question) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Câu hỏi phổ biến',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Trả lời: ${question.answer}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: StudentPqSegmentedButton(
              onTypeSelected: (type) {
                setState(() {
                  _showFacultyOnly = type == 'faculty';
                });
                context.read<StudentPQBloc>().add(GetStudentPopularQuestionsEvent(facultyOnly: _showFacultyOnly));
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: StudentPQList(
                onQuestionTap: (question) {
                  _showQuestionDetailsDialog(context, question);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
