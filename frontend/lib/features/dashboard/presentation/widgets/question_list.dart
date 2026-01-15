import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/question_records.dart';
import 'package:university_qa_system/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:university_qa_system/features/dashboard/presentation/widgets/question_item.dart';

class QuestionList extends StatefulWidget {
  final void Function(Question question)? onTap;

  const QuestionList({super.key, this.onTap});

  @override
  State<QuestionList> createState() {
    return _QuestionListState();
  }
}

class _QuestionListState extends State<QuestionList> {
  final ScrollController _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (previous, current) => current is DashboardDataLoaded || current is DashboardQuestionRecordsLoaded || current is DashboardLoading,
      builder: (context, state) {
        List<Question> questions = [];
        bool isLoadingMore = false;

        if (state is DashboardDataLoaded) {
          questions = state.questions;
          isLoadingMore = state.isLoadingMore;
        }

        if (state is DashboardQuestionRecordsLoaded) {
          questions = state.questions;
          isLoadingMore = state.isLoadingMore;
        }

        if (state is DashboardLoading) {
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
                'Không có câu hỏi nào.',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 500,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: questions.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= questions.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Loader()),
                );
              }

              final question = questions[index];
              return QuestionItem(
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