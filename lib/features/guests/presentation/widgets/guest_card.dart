import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../../domain/models/guest.dart';

class GuestCard extends StatelessWidget {
  final Guest guest;
  final Function(RsvpStatus) onStatusChanged;
  final VoidCallback onRemove;
  final VoidCallback onSendInvite;

  const GuestCard({
    super.key,
    required this.guest,
    required this.onStatusChanged,
    required this.onRemove,
    required this.onSendInvite,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (guest.rsvpStatus) {
      case RsvpStatus.accepted:
        statusColor = Colors.greenAccent;
        break;
      case RsvpStatus.declined:
        statusColor = Colors.redAccent;
        break;
      case RsvpStatus.pending:
        statusColor = Colors.white24;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF251616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // RSVP Status indicator
          Container(
            width: 12,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.name,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  guest.phoneNumber,
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: Icon(
              guest.isInvitationSent
                  ? Icons.mark_email_read
                  : Icons.send_rounded,
              color: guest.isInvitationSent
                  ? IgnisTheme.goldAccent
                  : Colors.white70,
              size: 20,
            ),
            onPressed: onSendInvite,
          ),

          PopupMenuButton<RsvpStatus>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onSelected: onStatusChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: RsvpStatus.accepted,
                child: Text('Accept'),
              ),
              const PopupMenuItem(
                value: RsvpStatus.declined,
                child: Text('Decline'),
              ),
              const PopupMenuItem(
                value: RsvpStatus.pending,
                child: Text('Reset to Pending'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
