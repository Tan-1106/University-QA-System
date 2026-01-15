import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/question_records.dart';
import 'package:university_qa_system/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class QuestionDetailsPage extends StatefulWidget {
  final Question question;

  const QuestionDetailsPage({super.key, required this.question});

  @override
  State<QuestionDetailsPage> createState() => _QuestionDetailsPageState();
}

class _QuestionDetailsPageState extends State<QuestionDetailsPage> {
  final TextEditingController _responseController = TextEditingController();

  void _submitResponse() {
    context.read<DashboardBloc>().add(
      RespondToQuestionEvent(
        questionId: widget.question.id,
        response: _responseController.text,
      ),
    );
    context.pop();
  }

  @override
  void initState() {
    super.initState();
    _responseController.text = widget.question.managerAnswer ?? '';
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Câu hỏi:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question.question,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Câu trả lời:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      (widget.question.answer ?? 'Chưa có hoặc lỗi trong quá trình tạo câu trả lời.').replaceAll('\\n', '\n'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Phản hồi từ sinh viên:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                (widget.question.feedback != null)
                    ? (widget.question.feedback! == 'Like')
                          ? 'Tích cực.'
                          : 'Không tích cực.'
                    : 'Chưa có phản hồi.',
              ),
              const SizedBox(height: 20),
              Text(
                'Phản hồi đến người dùng:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: _responseController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Nhập phản hồi của bạn ở đây...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitResponse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  child: const Text('Lưu phản hồi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
