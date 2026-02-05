import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/domain/models/user_stats.dart';
import '../../../../core/models/system_status.dart';
import 'system_status_capsule.dart';

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
              Text(
                'VIVAAH',
                style: GoogleFonts.cinzel(
                  color: palette.warn, // Using gold color
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
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
              CircleAvatar(
                radius: 30,
                backgroundColor: palette.primary.withValues(alpha: 0.1),
                backgroundImage: photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                onBackgroundImageError: (exception, stackTrace) {
                  // Silently handle the error
                  AppLogger.warning(
                    'Failed to load profile image',
                    exception: exception,
                  );
                },
                child: photoUrl.isEmpty
                    ? Icon(Icons.person, size: 20, color: palette.primary)
                    : null,
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
