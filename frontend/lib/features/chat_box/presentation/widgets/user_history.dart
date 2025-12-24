import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/chat_box/domain/entities/qa_history.dart';
import 'package:university_qa_system/features/chat_box/presentation/bloc/history/history_bloc.dart';

class UserHistory extends StatefulWidget {
  final void Function(QuestionRecord question)? onTap;

  const UserHistory({super.key, this.onTap});

  @override
  State<UserHistory> createState() {
    return _UserHistoryState();
  }
}

class _UserHistoryState extends State<UserHistory> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<HistoryBloc>().add(GetHistoryEvent(page: 1));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<HistoryBloc>().state;
      if (state is HistoryLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<HistoryBloc>().add(
          GetHistoryEvent(
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
    return BlocBuilder<HistoryBloc, HistoryState>(
      buildWhen: (previous, current) {
        return current is HistoryLoading ||
            current is HistoryLoaded ||
            current is HistoryError;
      },
      builder: (context, state) {
        List<QuestionRecord> history = [];
        bool isLoadingMore = false;

        if (state is HistoryLoaded) {
          history = state.history;
          isLoadingMore = state.isLoadingMore;
        } else if (state is HistoryLoading) {
          return const Loader();
        }

        if (history.isEmpty) {
          return const Center(
            child: Text('No history found.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: history.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= history.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Loader()),
                );
              }
              final record = history[index];
              return _HistoryItem(
                record: record,
                onTap: widget.onTap != null ? () => widget.onTap!(record) : null,
              );
            },
          ),
        );
      },
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final QuestionRecord record;
  final VoidCallback? onTap;

  const _HistoryItem({required this.record, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        child: Text(
          record.question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}