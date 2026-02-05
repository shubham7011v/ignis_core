import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../features/orders/domain/entities/order.dart';
import '../../../../features/orders/domain/entities/order_status.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/admin_status_badge.dart';

class AdminOrdersTab extends StatelessWidget {
  final List<Order> orders;

  const AdminOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Text("No orders found.", style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
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
                    AdminStatusBadge(status: order.status),
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
