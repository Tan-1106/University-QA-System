import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/core/utils/format_date.dart';
import 'package:university_qa_system/features/document/domain/entities/documents.dart';
import 'package:university_qa_system/features/document/presentation/bloc/document_list/document_list_bloc.dart';
import 'package:university_qa_system/features/document/presentation/widgets/document_segmented_button.dart';

class DocumentList extends StatefulWidget {
  final Function(String documentId) onDocumentTap;
  final DocumentSegmentedButtonOptions selectedOption;

  const DocumentList({super.key, required this.onDocumentTap, required this.selectedOption});

  @override
  State<DocumentList> createState() => _DocumentListState();
}

class _DocumentListState extends State<DocumentList> {
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
      final state = context.read<DocumentListBloc>().state;
      if (state is DocumentListLoaded && state.hasMore && !state.isLoadingMore) {
        if (widget.selectedOption == DocumentSegmentedButtonOptions.general) {
          context.read<DocumentListBloc>().add(
            LoadGeneralDocumentsEvent(
              page: state.currentPage + 1,
              isLoadMore: true,
            ),
          );
        } else if (widget.selectedOption == DocumentSegmentedButtonOptions.faculty) {
          context.read<DocumentListBloc>().add(
            LoadGeneralDocumentsEvent(
              page: state.currentPage + 1,
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
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentListBloc, DocumentListState>(
      buildWhen: (previous, current) => current is DocumentListLoading || current is DocumentListLoaded,
      builder: (context, state) {
        List<Document> documents = [];
        bool isLoadingMore = false;

        if (state is DocumentListLoaded) {
          documents = state.documents;
          isLoadingMore = state.isLoadingMore;
        }

        if (state is DocumentListLoading) {
          return const Center(child: Loader());
        }

        if (documents.isEmpty) {
          return Center(
            child: Text(
              'Không có tài liệu nào',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: documents.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= documents.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Loader()),
              );
            }

            final document = documents[index];
            return Column(
              children: [
                InkWell(
                  onTap: () => widget.onDocumentTap(document.id),
                  child: ListTile(
                    title: Text(
                      document.fileName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        const SizedBox(height: 4),
                        if (widget.selectedOption == DocumentSegmentedButtonOptions.general)
                          Text(
                            'Phòng ban: ${document.department}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        Text(
                          'Loại tài liệu: ${document.docType}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          'Ngày đăng tải: ${formatDate(document.uploadedAt)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
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
