import 'package:flutter/material.dart';
import '../../data/models/admin_user.dart';
import 'package:intl/intl.dart';

class AdminUsersTab extends StatelessWidget {
  final List<AdminUser> users;

  const AdminUsersTab({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Text("No users found.", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
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
              ],
            ),
            trailing: user.isAdmin
                ? const Chip(
                    label: Text("ADMIN", style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.redAccent,
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
