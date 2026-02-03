import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../../../auth/auth.dart';
import '../bloc/home_state.dart';
import 'home_top_bar.dart';

class HomeDashboard extends StatelessWidget {
  final AppColorPalette palette;
  final HomeState homeState;

  const HomeDashboard({
    super.key,
    required this.palette,
    required this.homeState,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = (authState is Authenticated) ? authState.user : null;

        return Column(
          children: [
            HomeTopBar(
              user: user,
              palette: palette,
              systemStatus: homeState.systemStatus,
              greeting: homeState.greeting,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildPremiumBanner(),
                    const SizedBox(height: 24),
                    _buildHeroSection(),
                    const SizedBox(height: 32),
                    _buildCreateInvitationButton(context),
                    const SizedBox(height: 24),
                    _buildFeatureRow(),
                    const SizedBox(height: 48),
                    _buildSectionHeader('Trending Collections'),
                    const SizedBox(height: 16),
                    _buildTrendingList(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: IgnisTheme.goldAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: IgnisTheme.goldAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 14,
            color: IgnisTheme.goldAccent,
          ),
          const SizedBox(width: 8),
          Text(
            'PREMIUM AI WEDDING SUITE',
            style: GoogleFonts.inter(
              color: IgnisTheme.goldAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your dream\nwedding invitation in\nminutes',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Transform your love story into a cinematic masterpiece. AI-powered video invitations that capture the essence of your big day.',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateInvitationButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: IgnisTheme.actionGradient,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: IgnisTheme.actionRed.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/style_selection'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_creation, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'CREATE INVITATION',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildFeatureItem(Icons.flash_on, 'Instant', 'Ready in 5m'),
        _buildFeatureItem(Icons.diamond, 'Premium', '4K Quality'),
        _buildFeatureItem(Icons.share, 'Easy Share', 'WhatsApp'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: IgnisTheme.goldAccent, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cinzel(
            color: IgnisTheme.goldAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'VIEW ALL',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingList() {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTrendingCard('Royal Heritage', 'Gold & Maroon', Colors.amber),
          const SizedBox(width: 16),
          _buildTrendingCard('Vintage Bollywood', 'Classic Retro', Colors.red),
          const SizedBox(width: 16),
          _buildTrendingCard('Modern Floral', 'Pastel Elegance', Colors.pink),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(String title, String theme, Color color) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(Icons.image_outlined, color: color, size: 40),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  theme,
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
