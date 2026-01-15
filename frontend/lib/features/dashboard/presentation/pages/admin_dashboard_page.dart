import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:university_qa_system/core/utils/show_snackbar.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/statistic.dart';
import 'package:university_qa_system/features/dashboard/presentation/widgets/statistic_box.dart';
import 'package:university_qa_system/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:university_qa_system/features/dashboard/presentation/widgets/question_list.dart';

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
                showErrorSnackBar(context, state.message);
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
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<DashboardBloc>().add(LoadDashboardStatisticEvent());
                  },
                  child: ListView(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Thống kê theo tháng',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: StatisticBox(
                              quantity: statisticData.total,
                              title: 'Tổng số\n câu hỏi',
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              textColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatisticBox(
                              quantity: statisticData.like,
                              title: 'Phản hồi tích cực',
                              backgroundColor: Colors.green,
                              textColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatisticBox(
                              quantity: statisticData.dislike,
                              title: 'Phản hồi tiêu cực',
                              backgroundColor: Colors.red,
                              textColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Câu hỏi từ người dùng',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
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
                  ),
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
