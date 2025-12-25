import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/presentation/bloc/student_pq_bloc.dart';
import 'package:university_qa_system/features/popular_question/presentation/widgets/student_pq_segmented_button.dart';

class StudentPQList extends StatefulWidget {
  final Function(PopularQuestion question) onQuestionTap;
  final StudentPQSegmentedButtonOptions selectedOption;

  const StudentPQList({super.key, required this.onQuestionTap, required this.selectedOption});

  @override
  State<StudentPQList> createState() => _StudentPQListState();
}

class _StudentPQListState extends State<StudentPQList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<StudentPQBloc>().state;
      if (state is StudentPQLoaded && state.hasMore && !state.isLoadingMore) {
        if (widget.selectedOption == StudentPQSegmentedButtonOptions.all) {
          context.read<StudentPQBloc>().add(
            GetStudentPopularQuestionsEvent(
              page: state.currentPage + 1,
              isLoadMore: true,
            ),
          );
        } else if (widget.selectedOption == StudentPQSegmentedButtonOptions.faculty) {
          context.read<StudentPQBloc>().add(
            GetStudentPopularQuestionsEvent(
              page: state.currentPage + 1,
              facultyOnly: true,
              isLoadMore: true,
            ),
          );
        }
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentPQBloc, StudentPQState>(
      buildWhen: (previous, current) => current is StudentPQLoading || current is StudentPQLoaded,
      builder: (context, state) {
        List<PopularQuestion> popularQuestions = [];
        bool isLoadingMore = false;

        if (state is StudentPQLoaded) {
          popularQuestions = state.questions;
          isLoadingMore = state.isLoadingMore;
        } else if (state is StudentPQLoading) {
          return const Center(child: Loader());
        }

        if (popularQuestions.isEmpty) {
          return const Center(
            child: Text('Không có dữ liệu.'),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: popularQuestions.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= popularQuestions.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Loader()),
              );
            }
            final question = popularQuestions[index];
            return Column(
              children: [
                InkWell(
                  onTap: () => widget.onQuestionTap(question),
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
      },
    );
  }
}
