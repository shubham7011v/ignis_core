import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/admin_stat_card.dart';

class AdminDashboardTab extends StatefulWidget {
  final AdminAuthenticated state;

  const AdminDashboardTab({super.key, required this.state});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  final _broadcastTitleController = TextEditingController();
  final _broadcastBodyController = TextEditingController();

  // Config controllers
  late bool _maintenanceMode;
  final _minVersionController = TextEditingController();
  final _promoBannerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize config values (mock or from state if we had it in state)
    // For now assuming defaults or fetch from repository if possible.
    // Ideally AdminAuthenticated should hold config too.
    _maintenanceMode = false;
  }

  @override
  void dispose() {
    _broadcastTitleController.dispose();
    _broadcastBodyController.dispose();
    _minVersionController.dispose();
    _promoBannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.state.stats;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- STATS ---
        const Text(
          "OVERVIEW",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            AdminStatCard(
              label: "TOTAL USERS",
              value: "${stats['totalUsers'] ?? 0}",
            ),
            AdminStatCard(
              label: "REVENUE",
              value:
                  "₹${((stats['totalRevenue'] ?? 0) / 100).toStringAsFixed(2)}",
            ),
            AdminStatCard(
              label: "TOTAL ORDERS",
              value: "${stats['totalOrders'] ?? 0}",
            ),
            AdminStatCard(
              label: "PENDING",
              value: "${stats['pendingOrders'] ?? 0}",
            ),
            AdminStatCard(
              label: "COMPLETED",
              value: "${stats['completedOrders'] ?? 0}",
            ),
          ],
        ),

        const Divider(color: Colors.greenAccent, height: 40),

        // --- BROADCAST ---
        const Text(
          "BROADCAST MESSAGE",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _broadcastTitleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Title",
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.greenAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _broadcastBodyController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Body",
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.greenAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text("SEND BROADCAST"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      if (_broadcastTitleController.text.isEmpty ||
                          _broadcastBodyController.text.isEmpty) {
                        return;
                      }

                      context.read<AdminBloc>().add(
                        BroadcastMessageEvent(
                          _broadcastTitleController.text,
                          _broadcastBodyController.text,
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Broadcast Sent!")),
                      );
                      _broadcastTitleController.clear();
                      _broadcastBodyController.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const Divider(color: Colors.greenAccent, height: 40),

        // --- CONFIG ---
        const Text(
          "APP CONFIGURATION",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    "Maintenance Mode",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Prevent users from accessing the app",
                    style: TextStyle(color: Colors.grey),
                  ),
                  value: _maintenanceMode,
                  activeThumbColor: Colors.redAccent,
                  onChanged: (val) {
                    setState(() => _maintenanceMode = val);
                    context.read<AdminBloc>().add(
                      UpdateConfigEvent({'maintenance_mode': val}),
                    );
                  },
                ),
                TextField(
                  controller: _minVersionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Min App Version (e.g. 1.0.0)",
                    labelStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save, color: Colors.greenAccent),
                      onPressed: () {
                        context.read<AdminBloc>().add(
                          UpdateConfigEvent({
                            'min_app_version': _minVersionController.text,
                          }),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Min Version Updated")),
                        );
                      },
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
