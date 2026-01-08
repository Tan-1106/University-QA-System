import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/api_management/presentation/bloc/api_key/api_keys_bloc.dart';
import 'package:university_qa_system/features/api_management/presentation/widgets/add_api_key_bottom_sheet.dart';
import 'package:university_qa_system/features/api_management/presentation/widgets/api_key_list.dart';

class APIManagementPage extends StatefulWidget {
  const APIManagementPage({super.key});

  @override
  State<APIManagementPage> createState() => _APIManagementPageState();
}

class _APIManagementPageState extends State<APIManagementPage> {
  final List<String> _providerList = [
    'OpenAI',
    'Google',
  ];
  String _keyword = '';
  String _selectedProvider = '';

  void _triggerSearch() {
    context.read<ApiKeysBloc>().add(
      LoadApiKeysEvent(
        keyword: _keyword.isEmpty ? null : _keyword,
        provider: _selectedProvider.isEmpty ? null : _selectedProvider,
        isLoadMore: false,
      ),
    );
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Bộ lọc API Keys',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Từ khóa',
                ),
                onChanged: (value) {
                  setState(() {
                    _keyword = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Nhà cung cấp',
                ),
                items: _providerList
                    .map(
                      (provider) => DropdownMenuItem<String>(
                        value: provider,
                        child: Text(provider),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProvider = value ?? '';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _keyword = '';
                  _selectedProvider = '';
                });
                _triggerSearch();
                Navigator.of(context).pop();
              },
              child: const Text('Hủy lọc'),
            ),
            ElevatedButton(
              onPressed: () {
                _triggerSearch();
                Navigator.of(context).pop();
              },
              child: const Text('Áp dụng'),
            ),
          ],
        );
      },
    );
  }

  void _showAddKeyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return AddApiKeyBottomSheet(
          onSuccess: () {
            _triggerSearch();
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _triggerSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddKeyBottomSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách API Keys: ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _showFiltersDialog();
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const Expanded(child: ApiKeyList()),
          ],
        ),
      ),
    );
  }
}
