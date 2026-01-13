import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:university_qa_system/core/utils/show_snackbar.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/statistic.dart';
import 'package:university_qa_system/features/dashboard/presentation/widgets/total_like.dart';
import 'package:university_qa_system/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:university_qa_system/features/dashboard/presentation/widgets/question_list.dart';
import 'package:university_qa_system/features/dashboard/presentation/widgets/total_dislike.dart';
import 'package:university_qa_system/features/dashboard/presentation/widgets/total_question.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() {
    return _AdminDashboardPageState();
  }
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardStatisticEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 20,
        ),
        child: Center(
          child: BlocConsumer<DashboardBloc, DashboardState>(
            listenWhen: (previous, current) => current is DashboardError,
            listener: (context, state) {
              if (state is DashboardError) {
                showSnackBar(context, state.message);
              }
            },
            buildWhen: (previous, current) =>
                current is DashboardLoading ||
                current is DashboardStatisticLoaded ||
                current is DashboardDataLoaded ||
                (current is DashboardError && previous is! DashboardQuestionRecordsLoaded && previous is! DashboardDataLoaded),
            builder: (context, state) {
              Statistic? statisticData;

              if (state is DashboardLoading) {
                return const Loader();
              }

              if (state is DashboardStatisticLoaded) {
                statisticData = state.statisticData;
              }

              if (state is DashboardDataLoaded) {
                statisticData = state.statisticData;
              }

              if (statisticData != null) {
                return ListView(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      color: Theme.of(context).colorScheme.tertiary,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Thống kê theo tháng',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onTertiary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TotalQuestions(quantity: statisticData.total),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TotalLike(quantity: statisticData.like),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TotalDislike(quantity: statisticData.dislike),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      color: Theme.of(context).colorScheme.tertiary,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Câu hỏi từ người dùng',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onTertiary),
                        ),
                      ),
                    ),
                    QuestionList(
                      onTap: (question) {
                        context.push(
                          '/admin-dashboard-question-details',
                          extra: question,
                        );
                      },
                    ),
                  ],
                );
              }

              return Text(
                'Không thể tải dữ liệu thống kê',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
