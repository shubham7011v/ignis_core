import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';

class IntroMoodPage extends StatefulWidget {
  const IntroMoodPage({super.key});

  @override
  State<IntroMoodPage> createState() => _IntroMoodPageState();
}

class _IntroMoodPageState extends State<IntroMoodPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showTitle = false;
  bool _showSubtitle = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Slower, more elegant
    )..repeat();

    // Sequence animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showTitle = true);
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showSubtitle = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IgnisTheme.deepMaroon,
      body: Stack(
        children: [
          // Background "Glitter" Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _controller.value,
                    color: IgnisTheme.goldAccent.withValues(alpha: 0.1),
                  ),
                );
              },
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _showTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'VITES',
                    style: GoogleFonts.cinzel(
                      color: IgnisTheme.goldAccent,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedOpacity(
                  opacity: _showSubtitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Your digital companion for the\nperfect wedding journey.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.6,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<Offset> _points = List.generate(
    20,
    (index) => Offset(
      math.Random(index).nextDouble(),
      math.Random(index + 100).nextDouble(),
    ),
  );

  _ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (var i = 0; i < _points.length; i++) {
      final p = _points[i];
      // Slow float upwards
      double x = p.dx * size.width;
      double y = ((p.dy - progress) % 1.0) * size.height;

      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
