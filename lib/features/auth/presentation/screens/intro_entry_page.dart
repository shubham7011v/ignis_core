import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/notifications/bloc/app_notification_bloc.dart';
import '../../../../core/notifications/bloc/app_notification_event.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/ignis_theme.dart';

class IntroEntryPage extends StatefulWidget {
  const IntroEntryPage({super.key});

  @override
  State<IntroEntryPage> createState() => _IntroEntryPageState();
}

class _IntroEntryPageState extends State<IntroEntryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showButton = true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          di.sl.onboardingRepository.markIntroAsSeen();
          Navigator.of(context).pushReplacementNamed(AppRouter.celebration);
        } else if (state is AuthFailure) {
          context.read<AppNotificationBloc>().add(
            ShowErrorNotification(state.failure.message),
          );
        }
      },
      child: Scaffold(
        backgroundColor: IgnisTheme.deepMaroon,
        body: Stack(
          children: [
            // Background Flourish Placeholder
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(painter: _FlourishPainter()),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      // Bypass to celebration for testing
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRouter.celebration);
                    },
                    child: Text(
                      'Create Memories.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: IgnisTheme.goldAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Celebrate Love.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      color: IgnisTheme.goldAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 80),
                  AnimatedOpacity(
                    opacity: _showButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1000),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 1.02).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: OutlinedButton(
                            onPressed: () => context.read<AuthBloc>().add(
                              GoogleSignInRequested(),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: IgnisTheme.goldAccent,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: IgnisTheme.goldAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  state is AuthLoading
                                      ? 'ASCENDING...'
                                      : 'GET STARTED',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlourishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    // Subtle mandala-like curve at the bottom
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.7,
      size.width,
      size.height,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
