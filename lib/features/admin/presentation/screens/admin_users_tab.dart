import 'package:flutter/material.dart';
import '../../data/models/admin_user.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/app_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/admin_repository.dart';

class AdminUsersTab extends StatefulWidget {
  final List<AdminUser> users;

  const AdminUsersTab({super.key, required this.users});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  // Check if current user is Super Admin
  bool get _isSuperAdmin {
    final email = FirebaseAuth.instance.currentUser?.email;
    return email != null && email == AppConfig.instance.superAdminEmail;
  }

  void _updateRole(BuildContext context, AdminUser user, bool makeAdmin) async {
    final repository = context
        .read<AdminRepository>(); // Provided by parent or GetIt

    // Optimistic Update / Show Loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(makeAdmin ? "Promoting..." : "Demoting...")),
    );

    try {
      await repository.updateUserRole(user.id, isAdmin: makeAdmin);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Success: ${user.displayName} is now ${makeAdmin ? 'Admin' : 'User'}",
          ),
        ),
      );
      // Trigger refresh?
      // Ideally calls Bloc event to reload data.
      // But AdminUsersTab is stateless (now stateful), getting `users` from parent.
      // Parent should handle refresh.
      // For now, this just sends API call.
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) {
      return const Center(
        child: Text("No users found.", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.users.length,
      itemBuilder: (context, index) {
        final user = widget.users[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[800],
              backgroundImage: user.photoUrl.isNotEmpty
                  ? NetworkImage(user.photoUrl)
                  : null,
              child: user.photoUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              user.displayName.isEmpty ? "No Name" : user.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: const TextStyle(color: Colors.grey)),
                Text(
                  "Joined: ${DateFormat('yyyy-MM-dd').format(user.createdAt)}",
                  style: const TextStyle(color: Colors.white24, fontSize: 12),
                ),
                if (user.isSuperAdmin)
                  const Text(
                    "SUPER ADMIN",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.isAdmin)
                  const Chip(
                    label: Text(
                      "ADMIN",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),

                // Only show actions if current user is Super Admin
                if (_isSuperAdmin && !user.isSuperAdmin) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'promote') {
                        _updateRole(context, user, true);
                      } else if (value == 'demote') {
                        _updateRole(context, user, false);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!user.isAdmin)
                        const PopupMenuItem(
                          value: 'promote',
                          child: Text("Promote to Admin"),
                        ),
                      if (user.isAdmin)
                        const PopupMenuItem(
                          value: 'demote',
                          child: Text("Demote to User"),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
