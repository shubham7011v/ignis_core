import 'package:flutter/material.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/admin_stat_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminDashboardTab extends StatelessWidget {
  final AdminAuthenticated state;

  const AdminDashboardTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminStatCard(
          label: "UPTIME",
          value: "${state.stats['uptime_sec'] ?? 0}s",
        ),
        AdminStatCard(
          label: "GOROUTINES",
          value: "${state.stats['goroutines'] ?? 0}",
        ),
        AdminStatCard(label: "TOTAL ORDERS", value: "${state.orders.length}"),

        const Divider(color: Colors.greenAccent, height: 40),

        const Text(
          "ACTIVE ROOMS",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        if (state.rooms.isEmpty)
          const Text("No active rooms", style: TextStyle(color: Colors.grey)),

        ...state.rooms.map(
          (room) => Card(
            color: Colors.grey[900],
            child: ExpansionTile(
              iconColor: Colors.greenAccent,
              collapsedIconColor: Colors.grey,
              title: Text(
                "Room: ${room['id']}",
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Users: ${room['playerCount']} | Status: ${room['phase']}",
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                tooltip: 'Close Room',
                onPressed: () {
                  context.read<AdminBloc>().add(CloseRoomEvent(room['id']));
                },
              ),
              children: [
                if (room['playerIds'] != null)
                  ...(room['playerIds'] as List).map(
                    (pid) => ListTile(
                      dense: true,
                      title: Text(
                        pid.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          context.read<AdminBloc>().add(
                            BanUserEvent(pid.toString()),
                          );
                        },
                        child: const Text(
                          'BAN',
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
