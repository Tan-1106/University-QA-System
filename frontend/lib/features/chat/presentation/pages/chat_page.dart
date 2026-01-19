import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/utils/show_snackbar.dart';
import 'package:university_qa_system/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:university_qa_system/features/chat/presentation/widgets/system_answer.dart';
import 'package:university_qa_system/features/chat/presentation/widgets/system_thinking.dart';
import 'package:university_qa_system/features/chat/presentation/widgets/user_question.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  String _submittedQuestion = '';

  void _handleSendQuestion() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _submittedQuestion = text;
      });

      context.read<ChatBoxBloc>().add(AskQuestionEvent(question: _submittedQuestion));
      _focusNode.unfocus();
      _textController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _submittedQuestion = '';
    context.read<ChatBoxBloc>().add(ResetChatBoxEvent());
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ChatBoxBloc, ChatState>(
          listenWhen: (previous, current) => current is ChatError,
          listener: (context, state) {
            if (state is ChatError) {
              showErrorSnackBar(context, state.message);
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
                        const SizedBox(height: 10),
                        if (state is ChatLoading)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: SystemThinking(),
                          ),
                        if (state is ChatQuestionAnswered)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SystemAnswer(
                              answer: state.question.answer ?? '',
                              onFeedbackTap: (feedback) {
                                context.read<ChatBoxBloc>().add(
                                  SendFeedbackEvent(
                                    questionID: state.question.questionID,
                                    feedback: feedback,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    onChanged: (_) {},
                    enabled: state is! ChatLoading,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu hỏi của bạn...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
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
