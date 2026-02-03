import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import 'settings_components.dart';

class SettingsSessionSection extends StatelessWidget {
  final AppColorPalette palette;
  final bool transitions;
  final bool haptics;
  final bool notifications;
  final bool showAvatars;
  final ValueChanged<bool> onTransitionsChanged;
  final ValueChanged<bool> onHapticsChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onShowAvatarsChanged;

  const SettingsSessionSection({
    super.key,
    required this.palette,
    required this.transitions,
    required this.haptics,
    required this.notifications,
    required this.showAvatars,
    required this.onTransitionsChanged,
    required this.onHapticsChanged,
    required this.onNotificationsChanged,
    required this.onShowAvatarsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      palette: palette,
      children: [
        SettingsSwitchTile(
          icon: Icons.auto_awesome_rounded,
          title: 'Smooth Transitions',
          value: transitions,
          palette: palette,
          onChanged: onTransitionsChanged,
        ),
        SettingsDivider(palette: palette),
        SettingsSwitchTile(
          icon: Icons.vibration_rounded,
          title: 'Haptic Feedback',
          value: haptics,
          palette: palette,
          onChanged: onHapticsChanged,
        ),
        SettingsDivider(palette: palette),
        SettingsSwitchTile(
          icon: Icons.notifications_rounded,
          title: 'App Notifications',
          value: notifications,
          palette: palette,
          onChanged: onNotificationsChanged,
        ),
        SettingsDivider(palette: palette),
        SettingsSwitchTile(
          icon: Icons.face_rounded,
          title: 'Show Participant Avatars',
          value: showAvatars,
          palette: palette,
          onChanged: onShowAvatarsChanged,
        ),
      ],
    );
  }
}
