import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../../domain/models/creation.dart';
import 'package:intl/intl.dart';

class CreationCard extends StatelessWidget {
  final Creation creation;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRSVP;

  const CreationCard({
    super.key,
    required this.creation,
    required this.onTap,
    required this.onDelete,
    required this.onRSVP,
  });

  @override
  Widget build(BuildContext context) {
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
              // Thumbnail
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      creation.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black26,
                        child: const Icon(
                          Icons.video_collection,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: onDelete,
                    ),
                  ),
                ],
              ),

              // Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creation.title,
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
                      DateFormat('MMM dd, yyyy').format(creation.createdAt),
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onRSVP,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: IgnisTheme.goldAccent),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'VIEW RSVP',
                          style: GoogleFonts.inter(
                            color: IgnisTheme.goldAccent,
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
}
