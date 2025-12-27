import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/document/presentation/bloc/document_viewer/document_viewer_bloc.dart';

class ViewDocumentPage extends StatelessWidget {
  const ViewDocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<DocumentViewerBloc, DocumentViewerState>(
        builder: (context, state) {
          if (state is DocumentViewerLoading) {
            return const Center(child: Loader());
          }

          if (state is DocumentViewerLoaded) {
            return SfPdfViewer.memory(state.pdfBytes.bytes);
          }

          if (state is DocumentViewerError) {
            return Center(
              child: Text(
                'Không thể tải được tài liệu.',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          return Center(
            child: Text(
              'Lỗi không thể hiển thị tài liệu.',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        },
      ),
    );
  }
}
