import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_status.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status color and label
    Color statusColor;
    String statusLabel = order.status.displayName;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.hourglass_empty;
        break;
      case OrderStatus.inProgress:
        statusColor = Colors.blueAccent;
        statusIcon = Icons.brush;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.greenAccent;
        statusIcon = Icons.check_circle_outline;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.redAccent;
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF251616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Header (Top Bar)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                color: statusColor.withValues(alpha: 0.2),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 8),
                    Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Placeholder Thumbnail or Icon
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.movie_creation_outlined,
                      color: Colors.white10,
                      size: 48,
                    ),
                  ),
                ),
              ),

              // Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: GoogleFonts.cinzel(
                        color: IgnisTheme.goldAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(order.createdAt),
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (order.status == OrderStatus.delivered &&
                        order.videoUrl != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchURL(order.videoUrl!),
                          icon: const Icon(Icons.play_circle_fill, size: 16),
                          label: const Text('WATCH VIDEO'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            textStyle: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
