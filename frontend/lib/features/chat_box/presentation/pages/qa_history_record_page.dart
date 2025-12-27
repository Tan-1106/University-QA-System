import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/chat_box/presentation/bloc/history_details/history_details_bloc.dart';
import 'package:university_qa_system/features/chat_box/presentation/widgets/admin_answer.dart';
import 'package:university_qa_system/features/chat_box/presentation/widgets/system_answer_history.dart';

import '../widgets/user_question.dart';

class QaHistoryDetailsPage extends StatefulWidget {
  final String questionId;

  const QaHistoryDetailsPage({super.key, required this.questionId});

  @override
  State<QaHistoryDetailsPage> createState() {
    return _QaHistoryDetailsPageState();
  }
}

class _QaHistoryDetailsPageState extends State<QaHistoryDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadRecordDetails();
  }

  @override
  void didUpdateWidget(covariant QaHistoryDetailsPage oldWidget) {
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
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: UserQuestion(question: state.recordDetails.question),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SystemAnswerHistory(answer: state.recordDetails.answer, feedback: state.recordDetails.feedback),
                      ),
                      if (state.recordDetails.managerAnswer != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AdminAnswer(
                            answer: state.recordDetails.managerAnswer!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return const Center(
          child: Loader(),
        );
      },
    );
  }
}
