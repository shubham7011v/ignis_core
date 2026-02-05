import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/ignis_network_image.dart';
import 'settings_components.dart';

class SettingsAccountSection extends StatelessWidget {
  final AppColorPalette palette;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  const SettingsAccountSection({
    super.key,
    required this.palette,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return SettingsCard(
      palette: palette,
      children: [
        ListTile(
          leading: ClipOval(
            child: user?.photoURL != null
                ? IgnisNetworkImage(
                    imageUrl: user!.photoURL!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorWidget: const Icon(Icons.person),
                  )
                : const Icon(Icons.person, size: 24),
          ),
          title: Text(
            user?.displayName ?? 'Guest',
            style: TextStyle(color: palette.textPrimary),
          ),
          subtitle: Text(
            user?.email ?? user?.uid ?? 'Not logged in',
            style: TextStyle(color: palette.textTertiary, fontSize: 12),
          ),
        ),
        SettingsDivider(palette: palette),
        SettingsActionTile(
          icon: Icons.logout_rounded,
          title: 'Sign Out',
          color: palette.textSecondary,
          palette: palette,
          onTap: onSignOut,
        ),
        SettingsDivider(palette: palette),
        SettingsActionTile(
          icon: Icons.delete_forever_rounded,
          title: 'Delete Account',
          color: Colors.redAccent,
          palette: palette,
          onTap: onDeleteAccount,
        ),
      ],
    );
  }
}
