import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';

class RejoinSessionDialog extends StatelessWidget {
  final AppColorPalette palette;
  final VoidCallback onResume;
  final VoidCallback onNewSession;

  const RejoinSessionDialog({
    super.key,
    required this.palette,
    required this.onResume,
    required this.onNewSession,
  });

  static Future<void> show({
    required BuildContext context,
    required AppColorPalette palette,
    required VoidCallback onResume,
    required VoidCallback onNewSession,
  }) {
    return showDialog(
      context: context,
      builder: (context) => RejoinSessionDialog(
        palette: palette,
        onResume: onResume,
        onNewSession: onNewSession,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: palette.surface,
      title: Text(
        'Active Session Found',
        style: GoogleFonts.cinzel(color: palette.textPrimary),
      ),
      content: Text(
        'You are currently in an ongoing wedding session. Do you want to rejoin it or start fresh?',
        style: GoogleFonts.inter(color: palette.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            onNewSession();
          },
          child: Text('Start Fresh', style: TextStyle(color: palette.danger)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            onResume();
          },
          child: const Text('Resume Session'),
        ),
      ],
    );
  }
}
