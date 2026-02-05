import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class VideoShort {
  final String title;
  final String category;
  final int color;

  const VideoShort({
    required this.title,
    required this.category,
    required this.color,
  });
}

class _ShortsScreenState extends State<ShortsScreen> {
  final PageController _pageController = PageController();

  final List<VideoShort> _dummyShorts = [
    VideoShort(
      title: 'Royal Heritage Wedding',
      category: 'Traditional • Premium',
      color: 0xFF3E2723,
    ),
    VideoShort(
      title: 'Modern Minimalist',
      category: 'Contemporary • Popular',
      color: 0xFF1A237E,
    ),
    VideoShort(
      title: 'Golden Haldi Ceremony',
      category: 'Sangeet • Trending',
      color: 0xFFF57F17,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: _dummyShorts.length,
        itemBuilder: (context, index) {
          final short = _dummyShorts[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background / Video Placeholder
              Container(
                color: Color(short.color),
                child: Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),

              // 2. Gradient Overlay for Text Visibility
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),

              // 3. Right Side Actions (Discovery-Focused)
              Positioned(
                right: 12,
                bottom: 120,
                child: Column(
                  children: [
                    _buildAction(Icons.favorite_border, 'Favorite', () {
                      // TODO: Add to favorites
                    }),
                    const SizedBox(height: 24),
                    _buildAction(Icons.share_outlined, 'Share', () {
                      // TODO: Share template
                    }),
                    const SizedBox(height: 24),
                    _buildAction(Icons.info_outline, 'Info', () {
                      // TODO: Show template details
                    }),
                    const SizedBox(height: 32),
                    // Primary CTA
                    _buildPrimaryCTA(() {
                      // TODO: Navigate to order flow
                    }),
                  ],
                ),
              ),

              // 4. Bottom Template Info
              Positioned(
                left: 16,
                bottom: 24,
                right: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      short.title,
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        short.category,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
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
        child: const Icon(
          Icons.auto_awesome, // Magic Wand icon
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }
}
