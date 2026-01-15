import 'dart:async';

import 'package:flutter/material.dart';

class SystemAnswer extends StatefulWidget {
  final String answer;
  final Function(String feedback)? onFeedbackTap;

  const SystemAnswer({
    super.key,
    required this.answer,
    required this.onFeedbackTap,
  });

  @override
  State<SystemAnswer> createState() {
    return _SystemAnswerState();
  }
}

class _SystemAnswerState extends State<SystemAnswer> {
  String currentFeedback = '';
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  void _startTypingEffect() {
    final answer = widget.answer.replaceAll('\\n', '\n');

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_currentIndex < answer.length) {
        setState(() {
          _displayedText += answer[_currentIndex];
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTypingEffect();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/chat_bot.png'),
              radius: 20,
            ),
            Flexible(
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(20),
                    bottomStart: Radius.circular(20),
                    topEnd: Radius.circular(20),
                    topStart: Radius.circular(0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Text(
                    _displayedText,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                if (widget.onFeedbackTap != null) {
                  setState(() {
                    currentFeedback = 'Like';
                  });
                  widget.onFeedbackTap!('Like');
                }
              },
              icon: Icon(
                Icons.thumb_up,
                color: currentFeedback == 'Like' ? Colors.green : Colors.grey,
              ),
            ),
            IconButton(
              onPressed: () {
                if (widget.onFeedbackTap != null) {
                  setState(() {
                    currentFeedback = 'Dislike';
                  });
                  widget.onFeedbackTap!('Dislike');
                }
              },
              icon: Icon(
                Icons.thumb_down,
                color: currentFeedback == 'Dislike' ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
