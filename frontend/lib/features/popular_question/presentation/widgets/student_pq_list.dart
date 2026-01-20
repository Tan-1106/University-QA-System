import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_question.dart';
import 'package:university_qa_system/features/popular_question/presentation/bloc/student_pq/student_pq_bloc.dart';

class StudentPQList extends StatelessWidget {
  final Function(PopularQuestionEntity question) onQuestionTap;

  const StudentPQList({super.key, required this.onQuestionTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentPQBloc, StudentPQState>(
      buildWhen: (previous, current) => current is StudentPQLoading || current is StudentPQLoaded,
      builder: (context, state) {
        if (state is StudentPQLoading) {
          return const Center(child: Loader());
        }

        if (state is StudentPQLoaded) {
          final popularQuestions = state.questions;
          if (popularQuestions.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Theme.of(context).hintColor),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy câu hỏi phổ biến nào.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            itemCount: popularQuestions.length,
            itemBuilder: (context, index) {
              final question = popularQuestions[index];
              return Column(
                children: [
                  InkWell(
                    onTap: () => onQuestionTap(question),
                    child: ListTile(
                      title: Text(
                        question.question,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
