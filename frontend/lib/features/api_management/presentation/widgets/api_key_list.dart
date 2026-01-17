import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/toggle_using_key.dart';
import 'package:university_qa_system/init_dependencies.dart';
import 'package:university_qa_system/core/common/widgets/loader.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_keys.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/delete_api_key.dart';
import 'package:university_qa_system/features/api_management/presentation/bloc/api_key/api_keys_bloc.dart';

class ApiKeyList extends StatefulWidget {
  const ApiKeyList({super.key});

  @override
  State<ApiKeyList> createState() => _ApiKeyListState();
}

class _ApiKeyListState extends State<ApiKeyList> {
  final ScrollController _scrollController = ScrollController();

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<ApiKeysBloc>().state;
      if (state is ApiKeysLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<ApiKeysBloc>().add(
          LoadApiKeysEvent(
            page: state.currentPage + 1,
            isLoadMore: true,
          ),
        );
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiKeysBloc, ApiKeysState>(
      buildWhen: (previous, current) => current is ApiKeysLoading || current is ApiKeysLoaded || current is ApiKeysError,
      builder: (context, state) {
        List<APIKey> apiKeys = [];
        bool isLoadingMore = false;

        if (state is ApiKeysLoading) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Loader(),
              ),
            ],
          );
        }

        if (state is ApiKeysLoaded) {
          apiKeys = state.apiKeys;
          isLoadingMore = state.isLoadingMore;
        }

        if (state is ApiKeysError) {
          return Center(
            child: Text(
              state.message,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }

        if (apiKeys.isEmpty) {
          return Center(
            child: Text(
              'Không có API Key nào.',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: apiKeys.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= apiKeys.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Loader(),
                ),
              );
            }

            final apiKey = apiKeys[index];
            return Column(
              children: [
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(
                    'Key: ${apiKey.name}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Trạng thái: ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            apiKey.isUsing ? 'Đang sử dụng' : 'Không sử dụng',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: apiKey.isUsing ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Nhà cung cấp: ${apiKey.provider}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        apiKey.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: apiKey.key));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép API Key vào clipboard'),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.copy,
                            size: 20,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(apiKey.isUsing ? 'Tắt API key' : 'Bật API key'),
                              content: Text('Bạn có chắc chắn muốn ${apiKey.isUsing ? 'tắt API key này không ?' : 'bật API key này không ?'}'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(apiKey.isUsing ? 'Tạm dừng' : 'Bắt đầu'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final toggleUsingKeyUseCase = serviceLocator<ToggleUsingKeyUseCase>();
                            final result = await toggleUsingKeyUseCase(
                              ToggleUsingKeyUseCaseParams(
                                id: apiKey.id,
                              ),
                            );

                            result.fold(
                                  (failure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Thay đổi trạng thái thất bại: ${failure.message}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                                  (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Thay đổi trạng thái thành công'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context.read<ApiKeysBloc>().add(LoadApiKeysEvent(page: 1));
                              },
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: apiKey.isUsing
                              ? const Icon(
                                  Icons.pause,
                                  size: 20,
                                )
                              : const Icon(
                                  Icons.play_arrow,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: Text('Bạn có chắc chắn muốn xóa API Key "${apiKey.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            final deleteUseCase = serviceLocator<DeleteAPIKeyUseCase>();
                            final result = await deleteUseCase(DeleteAPIKeyUseCaseParams(id: apiKey.id));

                            result.fold(
                              (failure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Xóa thất bại: ${failure.message}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Xóa API Key thành công'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context.read<ApiKeysBloc>().add(LoadApiKeysEvent(page: 1));
                              },
                            );
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
