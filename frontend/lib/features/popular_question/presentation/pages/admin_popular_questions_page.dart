import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/utils/app_bloc_observer.dart';
import 'package:university_qa_system/core/utils/show_snackbar.dart';
import 'package:university_qa_system/features/popular_question/presentation/bloc/admin_pq/admin_pq_bloc.dart';
import 'package:university_qa_system/features/popular_question/presentation/widgets/admin_faculty_filter.dart';
import 'package:university_qa_system/features/popular_question/presentation/widgets/admin_pq_generate_button.dart';
import 'package:university_qa_system/features/popular_question/presentation/widgets/admin_pq_item.dart';

class AdminPopularQuestionsPage extends StatefulWidget {
  const AdminPopularQuestionsPage({super.key});

  @override
  State<AdminPopularQuestionsPage> createState() => _AdminPopularQuestionsPageState();
}

class _AdminPopularQuestionsPageState extends State<AdminPopularQuestionsPage> {
  String? _faculty;
  bool _isDisplay = true;

  void _triggerGeneratePotentialQuestions() {
    context.read<AdminPQBloc>().add(GeneratePopularQuestionsEvent());
    showSuccessSnackBar(context, 'Đang thống kê câu hỏi, vui lòng quay lại sau...');
    context.pop();
  }

  void _triggerSearch() {
    context.read<AdminPQBloc>().add(
      GetAdminPopularQuestionsEvent(
        faculty: _faculty,
        isDisplay: _isDisplay,
      ),
    );
  }

  void _assignFacultyScope(String questionId, String? faculty) {
    context.read<AdminPQBloc>().add(
      AssignFacultyScopeEvent(
        questionId: questionId,
        faculty: faculty,
      ),
    );
  }

  void _updateQuestion(String questionId, String? question, String? answer) {
    context.read<AdminPQBloc>().add(
      UpdateQuestionEvent(
        questionId: questionId,
        question: question,
        answer: answer,
      ),
    );
  }

  void _toggleQuestionDisplay(String questionId) {
    context.read<AdminPQBloc>().add(
      ToggleQuestionDisplayEvent(
        questionId: questionId,
      ),
    );
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
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      Text(
                        'Cài đặt',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(),
                      AdminPQGenerateButton(
                        onPressed: () {
                          setState(() {
                            _faculty = null;
                            _isDisplay = true;
                          });
                          _triggerGeneratePotentialQuestions();
                        },
                      ),
                      Text(
                        'Phạm vi câu hỏi:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AdminFacultyFilter(
                        selectedFaculty: tempFaculty,
                        onFacultySelected: (faculty) {
                          setSheetState(() {
                            tempFaculty = faculty != 'Tất cả' ? faculty : null;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chỉ hiển thị các câu hỏi đã duyệt:',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: tempIsDisplay,
                            onChanged: (bool value) {
                              setSheetState(() {
                                tempIsDisplay = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          onPressed: () {
                            setState(() {
                              _faculty = tempFaculty;
                              _isDisplay = tempIsDisplay;
                            });
                            _triggerSearch();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Áp dụng bộ lọc'),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _faculty = null;
                              _isDisplay = true;
                            });
                            Navigator.of(context).pop();
                            _triggerSearch();
                          },
                          child: const Text('Hủy lọc'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<AdminPQBloc>().add(GetFacultiesEvent());
    _triggerSearch();
  }

  @override
  Widget build(BuildContext context) {
    String questionValue = '';
    String answerValue = '';
    String? facultyValue = '';
    bool isDisplay = true;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterSheet(context),
        child: const Icon(Icons.settings),
      ),
      body: BlocBuilder<AdminPQBloc, AdminPQState>(
        builder: (context, state) {
          if (state is AdminPQDataState) {
            if (state.questions.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => _triggerSearch(),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Card(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            spacing: 10,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Trạng thái: ',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(_isDisplay ? 'Đang hiển thị' : 'Đang ẩn'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Phạm vi câu hỏi: ',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(_faculty ?? 'Tất cả'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      Center(
                        child: Text(
                          'Không có câu hỏi phổ biến nào.',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Column(
                children: [
                  Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        spacing: 10,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Trạng thái: ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(_isDisplay ? 'Đang hiển thị' : 'Đang ẩn'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Phạm vi câu hỏi: ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(_faculty ?? 'Tất cả'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _triggerSearch();
                      },
                      child: ListView.builder(
                        itemCount: state.questions.length,
                        itemBuilder: (context, index) {
                          final question = state.questions[index];
                          return Column(
                            children: [
                              AdminPQItem(
                                question: question,
                                onEditPressed: () {
                                  questionValue = question.question;
                                  answerValue = question.answer;
                                  facultyValue = question.summary.facultyScope ?? 'Tất cả';
                                  isDisplay = question.isDisplay;

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    shape: const Border(),
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
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  Text(
                                                    'Câu hỏi:',
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    initialValue: questionValue,
                                                    maxLines: null,
                                                    decoration: const InputDecoration(
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onChanged: (value) {
                                                      setSheetState(() {
                                                        questionValue = value;
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Text(
                                                    'Câu trả lời:',
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    initialValue: answerValue,
                                                    maxLines: null,
                                                    decoration: const InputDecoration(
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onChanged: (value) {
                                                      setSheetState(() {
                                                        answerValue = value;
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Text(
                                                    'Phạm vi câu hỏi:',
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  AdminFacultyFilter(
                                                    selectedFaculty: facultyValue,
                                                    onFacultySelected: (faculty) {
                                                      setSheetState(() {
                                                        facultyValue = faculty != 'Tất cả' ? faculty : 'Tất cả';
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Trạng thái hiển thị: ',
                                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Switch(
                                                        value: isDisplay,
                                                        onChanged: (value) {
                                                          setSheetState(() {
                                                            isDisplay = value;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        if (questionValue != question.question || answerValue != question.answer) {
                                                          _updateQuestion(
                                                            question.id,
                                                            questionValue,
                                                            answerValue,
                                                          );
                                                        }

                                                        if (facultyValue != (question.summary.facultyScope ?? 'Tất cả')) {
                                                          logger.i('Assign faculty scope: $facultyValue');
                                                          _assignFacultyScope(
                                                            question.id,
                                                            facultyValue == 'Tất cả' ? null : facultyValue,
                                                          );
                                                        }

                                                        if (isDisplay != question.isDisplay) {
                                                          _toggleQuestionDisplay(
                                                            question.id,
                                                          );
                                                        }

                                                        Navigator.of(context).pop();
                                                        await Future.delayed(const Duration(milliseconds: 500));
                                                        _triggerSearch();
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                                      ),
                                                      child: const Text('Lưu thay đổi'),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                                        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                                                      ),
                                                      child: const Text('Hủy'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
