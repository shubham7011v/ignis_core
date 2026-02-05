import 'package:flutter/material.dart';

class AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final Color backgroundColor;

  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    this.labelColor = Colors.greenAccent,
    this.valueColor = Colors.white,
    this.backgroundColor = const Color(0xFF212121), // Colors.grey[900]
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: labelColor)),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
