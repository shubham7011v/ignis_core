import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class SettingsAboutSection extends StatelessWidget {
  final AppColorPalette palette;
  final String version;
  final String buildNumber;
  final VoidCallback onOpenAdmin;
  final VoidCallback onOpenSoundTest;

  const SettingsAboutSection({
    super.key,
    required this.palette,
    required this.version,
    required this.buildNumber,
    required this.onOpenAdmin,
    required this.onOpenSoundTest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'VITES',
          style: TextStyle(
            color: palette.textPrimary.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version $version • Build $buildNumber',
          style: TextStyle(color: palette.textTertiary, fontSize: 10),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onOpenSoundTest,
          icon: Icon(Icons.music_note, size: 14, color: palette.textTertiary),
          label: Text(
            'SOUND TEST',
            style: TextStyle(
              color: palette.textTertiary,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
