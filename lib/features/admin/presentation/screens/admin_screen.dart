import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/config/app_config.dart';
import '../bloc/admin_bloc.dart';
import '../../../../features/orders/domain/entities/order.dart';
import '../../../../features/orders/domain/entities/order_status.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBloc(
        repository: sl.adminRepository,
        orderRepository: sl.orderRepository,
      ),
      child: const _AdminView(),
    );
  }
}

class _AdminView extends StatefulWidget {
  const _AdminView();

  @override
  State<_AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<_AdminView> {
  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  void _checkAuthorization() {
    final user = FirebaseAuth.instance.currentUser;
    final config = AppConfig.instance;

    if (user != null &&
        (config.isAdmin || config.adminUids.contains(user.uid))) {
      context.read<AdminBloc>().add(AdminLogin());
    } else {
      context.read<AdminBloc>().add(AdminLogout());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black, // Matrix style
        appBar: AppBar(
          title: const Text('SERVER ADMIN'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.greenAccent,
          bottom: const TabBar(
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'DASHBOARD'),
              Tab(icon: Icon(Icons.list_alt), text: 'ORDERS'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AdminBloc>().add(LoadAdminData());
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AdminBloc>().add(AdminLogout());
              },
            ),
          ],
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is AdminInitial || state is AdminError) {
              String? errorMessage;
              if (state is AdminError) {
                errorMessage = state.message;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                });
              }
              return _buildLogin(context, errorMessage);
            }

            if (state is AdminLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent),
              );
            }

            if (state is AdminAuthenticated) {
              return TabBarView(
                children: [
                  _buildDashboard(context, state),
                  _buildOrderList(context, state),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLogin(BuildContext context, [String? errorMessage]) {
    // Keeping simplified login UI
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_person, size: 64, color: Colors.redAccent),
          const SizedBox(height: 32),
          Text(
            errorMessage != null ? 'LOGIN FAILED' : 'UNAUTHORIZED ACCESS',
            style: const TextStyle(color: Colors.redAccent, fontSize: 18),
          ),
          const SizedBox(height: 16),
          if (errorMessage != null)
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.orangeAccent),
            ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AdminBloc>().add(AdminLogin());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('RETRY INITIALIZATION'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, AdminAuthenticated state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard("UPTIME", "${state.stats['uptime_sec'] ?? 0}s"),
        _buildStatCard("Goroutines", "${state.stats['goroutines'] ?? 0}"),
        _buildStatCard("Total Orders", "${state.orders.length}"),
      ],
    );
  }

  Widget _buildOrderList(BuildContext context, AdminAuthenticated state) {
    if (state.orders.isEmpty) {
      return const Center(
        child: Text("No orders found.", style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        final order = state.orders[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Wed: ${DateFormat('yyyy-MM-dd').format(order.details.weddingDate)}",
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  "Created: ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () {
                        _showUpdateStatusDialog(context, order);
                      },
                      child: const Text("Update Status"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.inProgress:
        color = Colors.blue;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.greenAccent)),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Order order) {
    OrderStatus selectedStatus = order.status;
    final urlController = TextEditingController(text: order.videoUrl);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Update Status',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<OrderStatus>(
                  value: selectedStatus,
                  dropdownColor: Colors.grey[850],
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white),
                  items: OrderStatus.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedStatus = val);
                  },
                ),
                const SizedBox(height: 16),
                if (selectedStatus == OrderStatus.delivered)
                  TextField(
                    controller: urlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'YouTube Video URL',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AdminBloc>().add(
                    UpdateOrderStatusEvent(
                      order.id,
                      selectedStatus,
                      videoUrl: urlController.text.isNotEmpty
                          ? urlController.text
                          : null,
                    ),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }
}
