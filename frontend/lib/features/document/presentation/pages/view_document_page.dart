import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/document/presentation/bloc/document_viewer/document_viewer_bloc.dart';

class ViewDocumentPage extends StatefulWidget {
  const ViewDocumentPage({super.key});

  @override
  State<ViewDocumentPage> createState() => _ViewDocumentPageState();
}

class _ViewDocumentPageState extends State<ViewDocumentPage> {
  final PdfViewerController _controller = PdfViewerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DocumentViewerBloc, DocumentViewerState>(
        builder: (context, state) {
          if (state is DocumentViewerLoading) {
            return const Center(child: Loader());
          }
      
          if (state is DocumentViewerLoaded) {
            return SizedBox.expand(
              child: SfPdfViewer.memory(
                state.pdfBytes.bytes,
                controller: _controller,
              ),
            );
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
