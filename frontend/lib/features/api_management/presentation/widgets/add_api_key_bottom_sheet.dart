import 'package:flutter/material.dart';
import 'package:university_qa_system/init_dependencies.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/add_api_key.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/add_key_model.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/get_key_models.dart';

class AddApiKeyBottomSheet extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AddApiKeyBottomSheet({super.key, this.onSuccess});

  @override
  State<AddApiKeyBottomSheet> createState() => _AddApiKeyBottomSheetState();
}

class _AddApiKeyBottomSheetState extends State<AddApiKeyBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _keyController = TextEditingController();

  final List<String> _providerList = ['OpenAI', 'Google'];
  String? _selectedProvider;
  String? _selectedModel;

  bool _isLoadingModels = false;
  bool _isSubmitting = false;
  List<String> _availableModels = [];
  String? _modelsError;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableModels() async {
    if (_keyController.text.isEmpty || _selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập API Key và chọn nhà cung cấp'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingModels = true;
      _modelsError = null;
      _availableModels = [];
      _selectedModel = null;
    });

    final getKeyModelsUseCase = serviceLocator<GetKeyModelsUseCase>();
    final result = await getKeyModelsUseCase(
      GetKeyModelsUseCaseParams(
        key: _keyController.text.trim(),
        provider: _selectedProvider!,
      ),
    );

    result.fold(
      (failure) {
        setState(() {
          _isLoadingModels = false;
          _modelsError = failure.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (models) {
        setState(() {
          _isLoadingModels = false;
          _availableModels = models;
        });
        if (models.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy models nào cho API Key này'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_availableModels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra API Key trước khi thêm'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một model'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final addApiKeyUseCase = serviceLocator<AddAPIKeyUseCase>();
    final addKeyResult = await addApiKeyUseCase(
      AddAPIKeyParams(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        provider: _selectedProvider!,
        apiKey: _keyController.text.trim(),
      ),
    );

    await addKeyResult.fold(
      (failure) async {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm API Key thất bại: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (apiKeyId) async {
        final addKeyModelUseCase = serviceLocator<AddKeyModelUseCase>();
        final addModelResult = await addKeyModelUseCase(
          AddKeyModelUseCaseParams(
            id: apiKeyId,
            model: _selectedModel!,
          ),
        );

        setState(() {
          _isSubmitting = false;
        });

        addModelResult.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Thêm API Key thành công nhưng gắn model thất bại: ${failure.message}'),
                backgroundColor: Colors.orange,
              ),
            );
            widget.onSuccess?.call();
            Navigator.of(context).pop();
          },
          (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thêm API Key và gắn model thành công'),
                backgroundColor: Colors.green,
              ),
            );
            widget.onSuccess?.call();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thêm API Key mới',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên API Key *',
                  hintText: 'Ví dụ: OpenAI Production Key',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên API Key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  hintText: 'Mô tả ngắn gọn về API Key này',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Nhà cung cấp *',
                  border: OutlineInputBorder(),
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
                    _selectedProvider = value;
                    _availableModels = [];
                    _selectedModel = null;
                    _modelsError = null;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn nhà cung cấp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _keyController,
                decoration: const InputDecoration(
                  labelText: 'API Key *',
                  hintText: 'Nhập API Key của bạn',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập API Key';
                  }
                  return null;
                },
                onChanged: (_) {
                  if (_availableModels.isNotEmpty) {
                    setState(() {
                      _availableModels = [];
                      _selectedModel = null;
                      _modelsError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _isLoadingModels ? null : _fetchAvailableModels,
                icon: _isLoadingModels
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isLoadingModels ? 'Đang kiểm tra...' : 'Kiểm tra API Key',
                ),
              ),
              const SizedBox(height: 16),

              if (_availableModels.isNotEmpty) ...[
                Text(
                  'Chọn model sử dụng (${_availableModels.length} models khả dụng):',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Model *',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedModel,
                  items: _availableModels
                      .map(
                        (model) => DropdownMenuItem<String>(
                          value: model,
                          child: Text(
                            model,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedModel = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn model';
                    }
                    return null;
                  },
                  isExpanded: true,
                ),
                const SizedBox(height: 16),
              ],

              if (_modelsError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _modelsError!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              ElevatedButton(
                onPressed: _isSubmitting || _selectedModel == null
                    ? null
                    : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Thêm API Key'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

