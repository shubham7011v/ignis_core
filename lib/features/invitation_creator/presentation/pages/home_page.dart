import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force usage of Royal Palette for this screen if not globally set
    final palette = AppColors.getPalette(AppThemeMode.royal);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(
          'RoyalInvite',
          style: TextStyle(
            color: palette.textPrimary,
            fontFamily: 'Playfair Display', // Elegant Serif
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: palette.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundColor: palette.surfaceLight,
              child: Icon(Icons.person, color: palette.textPrimary),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gold Banner "Premium AI Wedding Suite"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: palette.warn.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: palette.warn),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 16, color: palette.warn),
                  const SizedBox(width: 8),
                  Text(
                    'PREMIUM AI WEDDING SUITE',
                    style: TextStyle(
                      color: palette.warn,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hero Text
            Text(
              'Create your dream\nwedding invitation in\nminutes',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 32,
                height: 1.2,
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Transform your love story into a cinematic masterpiece. AI-powered video invitations that capture the essence of your big day.',
              style: TextStyle(
                color: palette.textSecondary.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Style Selection (which we need to add to router)
                  // For now, let's use a placeholder or the next route we create
                  Navigator.pushNamed(context, '/style_selection');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: palette.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.movie_creation),
                    SizedBox(width: 12),
                    Text(
                      'Create Invitation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Feature Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeatureIcon(
                  Icons.flash_on,
                  'Instant',
                  'Ready in 5m',
                  palette,
                ),
                _buildFeatureIcon(
                  Icons.diamond,
                  'Premium',
                  '4K Quality',
                  palette,
                ),
                _buildFeatureIcon(
                  Icons.share,
                  'Easy Share',
                  'WhatsApp',
                  palette,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Trending Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trending Collections',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(color: palette.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Trending Grid (Placeholder)
            SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildTrendingCard(
                    palette,
                    'Royal Heritage Gold',
                    Colors.amber.shade900,
                  ),
                  const SizedBox(width: 16),
                  _buildTrendingCard(
                    palette,
                    'Modern Floral Pastel',
                    Colors.pink.shade100,
                  ),
                  const SizedBox(width: 16),
                  _buildTrendingCard(
                    palette,
                    'Vintage Bollywood',
                    Colors.orange.shade800,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.textTertiary,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Templates',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(
    IconData icon,
    String title,
    String subtitle,
    AppColorPalette palette,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: palette.surfaceLight,
          child: Icon(icon, color: palette.warn, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(color: palette.textTertiary, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(
    AppColorPalette palette,
    String title,
    Color color,
  ) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: palette.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.local_movies,
                  size: 48,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Video Theme',
                  style: TextStyle(color: palette.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
