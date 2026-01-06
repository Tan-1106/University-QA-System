import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/user_management/presentation/bloc/user_management_bloc.dart';

class RoleFilter extends StatefulWidget {
  final String? currentRole;
  final Function(String role) onRoleSelected;
  const RoleFilter({super.key, required this.onRoleSelected, this.currentRole});

  @override
  State<RoleFilter> createState() => _RoleFilterState();
}

class _RoleFilterState extends State<RoleFilter> {
  String selectedRole = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<UserManagementBloc>().state;
    List<String> existingRoles = widget.currentRole != null ? [] : ['Tất cả'];
    if (state is UserManagementStateLoaded) {
      existingRoles = existingRoles + state.roles;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: widget.currentRole ?? selectedRole,
          hint: const Text('Chọn vai trò'),
          elevation: 16,
          isExpanded: true,
          icon: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.arrow_drop_down),
          ),
          items: existingRoles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(value),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedRole = newValue!;
            });
            widget.onRoleSelected(newValue!);
          },
        ),
      ),
    );
  }
}
