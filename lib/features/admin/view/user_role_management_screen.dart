import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_viewmodel.dart';
import '../../../data/models/profile_model.dart';
import '../../../core/theme/app_colors.dart';

class UserRoleManagementScreen extends StatefulWidget {
  const UserRoleManagementScreen({super.key});

  @override
  State<UserRoleManagementScreen> createState() => _UserRoleManagementScreenState();
}

class _UserRoleManagementScreenState extends State<UserRoleManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminViewModel>(context, listen: false).loadAllProfiles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = Provider.of<AdminViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('User Role Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => adminVM.searchProfiles(val),
            ),
          ),

          // 👥 User List
          Expanded(
            child: adminVM.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                : adminVM.filteredProfiles.isEmpty
                    ? const Center(child: Text('No users found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: adminVM.filteredProfiles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final profile = adminVM.filteredProfiles[index];
                          return _buildUserCard(profile, adminVM);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(ProfileModel profile, AdminViewModel adminVM) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getRoleColor(profile.role).withValues(alpha: 0.1),
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
              style: TextStyle(color: _getRoleColor(profile.role), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  profile.email ?? 'No email',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          _buildRoleDropdown(profile, adminVM),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown(ProfileModel profile, AdminViewModel adminVM) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: profile.role,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
          onChanged: (String? newRole) {
            if (newRole != null && newRole != profile.role) {
              _confirmRoleChange(context, profile, newRole, adminVM);
            }
          },
          items: const [
            DropdownMenuItem(value: ProfileModel.roleUser, child: Text('User')),
            DropdownMenuItem(value: ProfileModel.roleWorker, child: Text('Worker')),
            DropdownMenuItem(value: ProfileModel.roleAdmin, child: Text('Admin')),
            DropdownMenuItem(value: ProfileModel.roleSuperAdmin, child: Text('Super Admin')),
          ],
        ),
      ),
    );
  }

  void _confirmRoleChange(BuildContext context, ProfileModel profile, String newRole, AdminViewModel adminVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role?'),
        content: Text('Are you sure you want to promote ${profile.name} to ${newRole.toUpperCase()}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              adminVM.updateUserRole(profile.id, newRole);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _getRoleColor(newRole)),
            child: const Text('Confirm Change'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case ProfileModel.roleSuperAdmin:
        return Colors.red;
      case ProfileModel.roleAdmin:
        return Colors.purple;
      case ProfileModel.roleWorker:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
