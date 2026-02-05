import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../../domain/entities/short.dart';

class ShortsActionBar extends StatelessWidget {
  final Short short;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;
  final VoidCallback onInfoTap;
  final VoidCallback onCtaTap;

  const ShortsActionBar({
    super.key,
    required this.short,
    required this.onFavoriteTap,
    required this.onShareTap,
    required this.onInfoTap,
    required this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAction(
          short.isFavorite ? Icons.favorite : Icons.favorite_border,
          'Favorite',
          onFavoriteTap,
          isActive: short.isFavorite,
        ),
        const SizedBox(height: 24),
        _buildAction(Icons.share_outlined, 'Share', onShareTap),
        const SizedBox(height: 24),
        _buildAction(Icons.info_outline, 'Info', onInfoTap),
        const SizedBox(height: 32),
        _buildPrimaryCTA(onCtaTap),
      ],
    );
  }

  Widget _buildAction(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? IgnisTheme.goldAccent : Colors.white,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isActive ? IgnisTheme.goldAccent : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCTA(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: IgnisTheme.goldAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: IgnisTheme.goldAccent.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.auto_awesome, color: Colors.black, size: 24),
      ),
    );
  }
}
