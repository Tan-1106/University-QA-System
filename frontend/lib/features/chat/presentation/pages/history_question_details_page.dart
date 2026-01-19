import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/chat/presentation/bloc/history_details/history_details_bloc.dart';
import 'package:university_qa_system/features/chat/presentation/widgets/admin_answer.dart';
import 'package:university_qa_system/features/chat/presentation/widgets/system_answer_history.dart';
import 'package:university_qa_system/features/chat/presentation/widgets/user_question.dart';


class HistoryQuestionDetailsPage extends StatefulWidget {
  final String questionId;

  const HistoryQuestionDetailsPage({super.key, required this.questionId});

  @override
  State<HistoryQuestionDetailsPage> createState() {
    return _HistoryQuestionDetailsPageState();
  }
}

class _HistoryQuestionDetailsPageState extends State<HistoryQuestionDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadRecordDetails();
  }

  @override
  void didUpdateWidget(covariant HistoryQuestionDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionId != widget.questionId) {
      _loadRecordDetails();
    }
  }

  void _loadRecordDetails() {
    context.read<HistoryDetailsBloc>().add(
      ViewRecordDetailsEvent(questionID: widget.questionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryDetailsBloc, HistoryDetailsState>(
      builder: (context, state) {
        if (state is HistoryDetailsLoading) {
          return const Center(child: Loader());
        }

        if (state is HistoryDetailsError) {
          return const Center(child: Text('Không thể tải lịch sử câu hỏi.'));
        }

        if (state is HistoryDetailsLoaded) {
          return RefreshIndicator(
            onRefresh: () async => _loadRecordDetails(),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: UserQuestion(question: state.questionDetails.question),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SystemAnswerHistory(answer: state.questionDetails.answer, feedback: state.questionDetails.feedback),
                        ),
                        if (state.questionDetails.managerAnswer != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: AdminAnswer(
                              answer: state.questionDetails.managerAnswer!,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(
          child: Loader(),
        );
      },
    );
  }
}
