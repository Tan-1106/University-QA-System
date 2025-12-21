import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/dashboard/data/models/question_records_data.dart';
import 'package:university_qa_system/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class QuestionList extends StatefulWidget {
  final void Function(Questions question)? onTap;

  const QuestionList({super.key, this.onTap});

  @override
  State<QuestionList> createState() {
    return _QuestionListState();
  }
}

class _QuestionListState extends State<QuestionList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<DashboardBloc>().add(LoadDashboardQuestionRecordsEvent(page: 1));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<DashboardBloc>().state;
      if (state is DashboardDataLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<DashboardBloc>().add(
          LoadDashboardQuestionRecordsEvent(
            page: state.currentPage + 1,
            isLoadMore: true,
          ),
        );
      } else if (state is DashboardQuestionRecordsLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<DashboardBloc>().add(
          LoadDashboardQuestionRecordsEvent(
            page: state.currentPage + 1,
            isLoadMore: true,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (previous, current) => current is DashboardDataLoaded || current is DashboardQuestionRecordsLoaded || current is DashboardLoading,
      builder: (context, state) {
        List<Questions> questions = [];
        bool isLoadingMore = false;

        if (state is DashboardDataLoaded) {
          questions = state.questions;
          isLoadingMore = state.isLoadingMore;
        } else if (state is DashboardQuestionRecordsLoaded) {
          questions = state.questions;
          isLoadingMore = state.isLoadingMore;
        } else if (state is DashboardLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: Loader()),
          );
        }

        if (questions.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Không có câu hỏi nào',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 400,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: questions.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= questions.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final question = questions[index];
              return _QuestionItem(
                userSub: question.userSub,
                question: question,
                onTap: () => widget.onTap?.call(question),
              );
            },
          ),
        );
      },
    );
  }
}

class _QuestionItem extends StatelessWidget {
  final String userSub;
  final Questions question;
  final VoidCallback? onTap;

  const _QuestionItem({
    required this.userSub,
    required this.question,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MSSV: $userSub',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer
                    )
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        _getFeedbackIcon(question.feedback),
                        size: 16,
                        color: _getFeedbackColor(question.feedback),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        question.createdAt,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            IconButton(onPressed: onTap, icon: const Icon(Icons.chevron_right))
          ],
        )
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
