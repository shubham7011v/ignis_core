import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';

class IntroHintPage extends StatefulWidget {
  const IntroHintPage({super.key});

  @override
  State<IntroHintPage> createState() => _IntroHintPageState();
}

class _IntroHintPageState extends State<IntroHintPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF000000),
                  Color(0xFF1A1A1A), // Deep charcoal
                ],
              ),
            ),
          ),

          // Sliding Cards (Subtle Background)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildSlidingCard(-0.2, 0.3, 0.8), // Card 1
                  _buildSlidingCard(0.5, 0.7, 1.2), // Card 2
                  _buildSlidingCard(0.1, 0.1, 0.5), // Card 3
                ],
              );
            },
          ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Design Your Dream',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      color: IgnisTheme.goldAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Craft beautiful invitations\nthat reflect your unique style.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingCard(double startX, double y, double speedFactor) {
    double progress = (_controller.value * speedFactor + startX) % 1.2;
    double xPos = (progress - 0.2) * MediaQuery.of(context).size.width * 1.2;

    return Positioned(
      left: xPos,
      top: MediaQuery.of(context).size.height * y,
      child: Opacity(
        opacity: 0.08, // Slightly more visible for the new icons
        child: Container(
          width: 140,
          height: 200,
          decoration: BoxDecoration(
            color: IgnisTheme.goldAccent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: const Center(
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }
}
