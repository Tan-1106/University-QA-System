import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/user_management/presentation/bloc/user_management_bloc.dart';
import 'package:university_qa_system/features/user_management/presentation/widgets/faculty_filter.dart';
import 'package:university_qa_system/features/user_management/presentation/widgets/keyword_search_textfield.dart';
import 'package:university_qa_system/features/user_management/presentation/widgets/role_filter.dart';
import 'package:university_qa_system/features/user_management/presentation/widgets/user_list.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String? _selectedRole;
  String? _selectedFaculty;
  String? _keyword;
  bool? _bannedOnly;

  @override
  void initState() {
    super.initState();
    _triggerSearch();
  }

  void _showFilterSheet(BuildContext context) {
    String? tempRole = _selectedRole;
    String? tempFaculty = _selectedFaculty;
    String? tempKeyword = _keyword;
    bool? tempBannedOnly = _bannedOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
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
                  spacing: 10,
                  children: [
                    Text(
                      'Bộ lọc người dùng',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(),
                    Text(
                      'Vai trò:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RoleFilter(
                      onRoleSelected: (role) {
                        setSheetState(() {
                          tempRole = role != 'Tất cả' ? role : null;
                        });
                      },
                    ),
                    Text(
                      'Khoa:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FacultyFilter(
                      onFacultySelected: (faculty) {
                        setSheetState(() {
                          tempFaculty = faculty != 'Tất cả' ? faculty : null;
                        });
                      },
                    ),
                    Text(
                      'Tìm theo từ khóa:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    KeywordSearchTextfield(
                      onKeywordChanged: (keyword) {
                        setSheetState(() {
                          tempKeyword = keyword.isNotEmpty ? keyword : null;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đã bị chặn: ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: tempBannedOnly ?? false,
                          onChanged: (value) {
                            setSheetState(() {
                              tempBannedOnly = value;
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
                            _selectedRole = tempRole;
                            _selectedFaculty = tempFaculty;
                            _keyword = tempKeyword;
                            _bannedOnly = tempBannedOnly;
                          });
                          Navigator.of(context).pop();
                          _triggerSearch();
                        },
                        child: const Text('Áp dụng bộ lọc'),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedRole = null;
                            _selectedFaculty = null;
                            _keyword = null;
                            _bannedOnly = null;
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
            );
          },
        );
      },
    );
  }

  void _showUserInformationSheet(
    BuildContext context,
    String userId,
    bool currentBanStatus,
    String userRole,
    String? userFaculty,
  ) {
    String tempRole = userRole;
    String? tempFaculty = userFaculty;
    bool tempBanStatus = currentBanStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
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
                  spacing: 10,
                  children: [
                    Text(
                      'Chỉnh sửa thông tin người dùng',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(),
                    Text(
                      'Vai trò:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RoleFilter(
                      currentRole: tempRole,
                      onRoleSelected: (role) {
                        setSheetState(() {
                          tempRole = role;
                        });
                      },
                    ),
                    Text(
                      'Thuộc khoa:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FacultyFilter(
                      currentFaculty: tempFaculty,
                      onFacultySelected: (faculty) {
                        setSheetState(() {
                          tempFaculty = faculty;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trạng thái chặn: ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: tempBanStatus,
                          onChanged: (value) {
                            setSheetState(() {
                              tempBanStatus = value;
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
                          if (tempRole != userRole) {
                            if (tempRole != 'Admin') {
                              context.read<UserManagementBloc>().add(
                                AssignRoleToUserEvent(
                                  userId: userId,
                                  roleToAssign: tempRole,
                                  faculty: tempFaculty
                                ),
                              );
                            } else {
                              context.read<UserManagementBloc>().add(
                                AssignRoleToUserEvent(
                                  userId: userId,
                                  roleToAssign: tempRole,
                                ),
                              );
                            }
                          }

                          if (tempBanStatus != currentBanStatus) {
                            context.read<UserManagementBloc>().add(
                              ChangeUserBanStatusEvent(
                                userId: userId,
                                currentBanStatus: currentBanStatus,
                              ),
                            );
                          }

                          Navigator.of(context).pop();
                          _triggerSearch();
                        },
                        child: const Text('Lưu'),
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
  }

  void _triggerSearch() {
    context.read<UserManagementBloc>().add(
      GetBasicInformationEvent(
        role: _selectedRole,
        faculty: _selectedFaculty,
        keyword: _keyword,
        banned: _bannedOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFilterSheet(context),
        label: const Text('Lọc & tìm kiếm'),
        icon: const Icon(Icons.filter_list),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: UserList(
          onUserTap: (userId, currentBanStatus, userRole, userFaculty) {
            _showUserInformationSheet(
              context,
              userId,
              currentBanStatus,
              userRole,
              userFaculty,
            );
          },
        ),
      ),
    );
  }
}
