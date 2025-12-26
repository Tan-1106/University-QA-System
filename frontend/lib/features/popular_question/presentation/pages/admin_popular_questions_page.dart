import 'package:flutter/material.dart';

class AdminPopularQuestionsPage extends StatefulWidget {
  const AdminPopularQuestionsPage({super.key});

  @override
  State<AdminPopularQuestionsPage> createState() => _AdminPopularQuestionsPageState();
}

class _AdminPopularQuestionsPageState extends State<AdminPopularQuestionsPage> {
  String? _faculty;
  bool _isDisplay = true;

  @override
  void initState() {
    super.initState();
  }

  void _showFilterSheet(BuildContext context) {
    String? tempFaculty = _faculty;
    bool tempIsDisplay = _isDisplay;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bộ lọc câu hỏi phổ biến',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(),
                    // TODO: Add faculty filter widget here
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

      ],
    );
  }
}
