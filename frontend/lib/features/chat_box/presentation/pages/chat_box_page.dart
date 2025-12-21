import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/utils/show_snackbar.dart';
import 'package:university_qa_system/features/chat_box/presentation/bloc/chat_box_bloc.dart';
import 'package:university_qa_system/features/chat_box/presentation/widgets/system_answer.dart';
import 'package:university_qa_system/features/chat_box/presentation/widgets/system_thinking.dart';
import 'package:university_qa_system/features/chat_box/presentation/widgets/user_question.dart';

class ChatBoxPage extends StatefulWidget {
  const ChatBoxPage({super.key});

  @override
  State<ChatBoxPage> createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  String _submittedQuestion = '';
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSendQuestion() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _submittedQuestion = text;
      });

      context.read<ChatBoxBloc>().add(AskQuestionEvent(question: _submittedQuestion));

      _textController.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ChatBoxBloc, ChatBoxState>(
          listenWhen: (previous, current) => current is ChatBoxError,
          listener: (context, state) {
            if (state is ChatBoxError) {
              showSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      children: [
                        if (_submittedQuestion.isNotEmpty)
                          Align(
                            alignment: Alignment.centerRight,
                            child: UserQuestion(question: _submittedQuestion),
                          ),
                        SizedBox(height: 10),
                        if (state is ChatBoxLoading)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SystemThinking(),
                          ),
                        if (state is ChatBoxQuestionAnswered)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SystemAnswer(answer: state.qaRecord.answer),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    onChanged: (value) {},
                    enabled: state is! ChatBoxLoading,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu hỏi của bạn...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _handleSendQuestion,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
