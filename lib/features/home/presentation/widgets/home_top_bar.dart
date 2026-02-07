import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/domain/models/user_stats.dart';
import '../../../../core/models/system_status.dart';
import 'system_status_capsule.dart';
import '../../../../core/widgets/ignis_network_image.dart';

class HomeTopBar extends StatelessWidget {
  final User? user;
  final UserStats? stats;
  final AppColorPalette palette;
  final SystemStatus systemStatus;
  final String greeting;

  const HomeTopBar({
    super.key,
    this.user,
    this.stats,
    required this.palette,
    required this.systemStatus,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final String rawName = user?.displayName ?? stats?.name ?? 'Guest';
    final String displayName = rawName.split(' ').first;
    final String photoUrl = user?.photoURL ?? '';
    // Legacy stats removed for Vivaah

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'VITES',
                  style: GoogleFonts.cinzel(
                    color: palette.warn, // Using gold color
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SystemStatusCapsule(systemStatus: systemStatus, palette: palette),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: palette.textTertiary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cinzel(
                        color: palette.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.primary.withValues(alpha: 0.1),
                ),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? IgnisNetworkImage(
                          imageUrl: photoUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorWidget: Center(
                            child: Icon(
                              Icons.person,
                              size: 24,
                              color: palette.primary,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.person,
                            size: 24,
                            color: palette.primary,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // User info chips removed to focus on Wedding Planning Dashboard
        ],
      ),
    );
  }
}
