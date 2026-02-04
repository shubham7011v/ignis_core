import 'package:flutter/material.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/models/template.dart';
import 'package:google_fonts/google_fonts.dart';

class TemplateCard extends StatefulWidget {
  final Template template;
  final VoidCallback onTap;
  final bool isLocked;
  final VoidCallback? onUnlock;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.isLocked = false,
    this.onUnlock,
  });

  @override
  State<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<TemplateCard> {
  bool _isCached = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkCacheStatus();
  }

  Future<void> _checkCacheStatus() async {
    final isCached = await sl.templateDownloadService.isTemplateCached(
      widget.template.id,
    );
    if (mounted) {
      setState(() {
        _isCached = isCached;
      });
    }
  }

  Future<void> _downloadTemplate() async {
    if (widget.template.youtubeId == null || _isDownloading || _isCached) {
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      await sl.templateDownloadService.downloadTemplateWithProgress(
        widget.template,
        (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isCached = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildDownloadIndicator() {
    if (widget.template.youtubeId == null) {
      return const SizedBox.shrink();
    }

    if (_isCached) {
      return Positioned(
        top: 8,
        left: 8,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        ),
      );
    }

    if (_isDownloading) {
      return Positioned(
        top: 8,
        left: 8,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: _downloadProgress,
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                IgnisTheme.goldAccent,
              ),
            ),
          ),
        ),
      );
    }

    return Positioned(
      top: 8,
      left: 8,
      child: GestureDetector(
        onTap: _downloadTemplate,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: IgnisTheme.goldAccent.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.download, color: Colors.black, size: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLocked ? widget.onUnlock : widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF251616), // Slightly lighter maroon
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isLocked
                ? Colors
                      .white12 // Dim border if locked
                : widget.template.isPremium
                ? IgnisTheme.goldAccent
                : Colors.white10,
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
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          widget.template.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.black26,
                                child: const Icon(
                                  Icons.video_library,
                                  color: Colors.white24,
                                ),
                              ),
                        ),
                      ),
                      _buildDownloadIndicator(),
                      if (widget.template.isPremium)
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
                            widget.template.duration,
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
                          widget.template.title,
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
                          widget.template.category,
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
              // Lock Overlay
              if (widget.isLocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: IgnisTheme.goldAccent,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: IgnisTheme.goldAccent,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
