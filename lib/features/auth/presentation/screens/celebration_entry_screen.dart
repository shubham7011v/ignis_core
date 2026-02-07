import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../../../../core/navigation/app_router.dart';
import '../widgets/display_name_dialog.dart';

class CelebrationEntryScreen extends StatefulWidget {
  const CelebrationEntryScreen({super.key});

  @override
  State<CelebrationEntryScreen> createState() => _CelebrationEntryScreenState();
}

class _CelebrationEntryScreenState extends State<CelebrationEntryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        (user.displayName == null || user.displayName!.isEmpty)) {
      setState(() => _isDialogShowing = true);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => DisplayNameDialog(
            initialName: '',
            onConfirm: (name) async {
              final navigator = Navigator.of(context);
              final rootNavigator = Navigator.of(this.context);
              await user.updateDisplayName(name);
              if (!mounted) return;

              // Close dialog and navigate
              navigator.pop();
              rootNavigator.pushReplacementNamed(AppRouter.home);
            },
          ),
        );
      }
    } else {
      // Auto-advance after a short delay
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IgnisTheme.deepMaroon,
      body: Stack(
        children: [
          // Background Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isDialogShowing ? 0.2 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: IgnisTheme.goldAccent.withValues(alpha: 0.1),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite, // Heart Icon for Vivaah
                        size: 100,
                        color: IgnisTheme.goldAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Text(
                    'WELCOME TO VITES',
                    style: GoogleFonts.cinzel(
                      color: IgnisTheme.goldAccent.withValues(alpha: 0.9),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Preparing your celebration…',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 1.2,
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
}
