import 'package:flutter/material.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../../domain/models/template.dart';
import 'package:google_fonts/google_fonts.dart';

class TemplateCard extends StatelessWidget {
  final Template template;
  final VoidCallback onTap;

  const TemplateCard({super.key, required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF251616), // Slightly lighter maroon
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: template.isPremium ? IgnisTheme.goldAccent : Colors.white10,
            width: 1,
          ),
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
              // Thumbnail
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      template.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black26,
                        child: const Icon(
                          Icons.video_library,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  if (template.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: IgnisTheme.goldAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        template.duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: GoogleFonts.cinzel(
                        color: IgnisTheme.goldAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.category,
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 12,
                        letterSpacing: 1.1,
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
}
