import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({super.key});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage>
    with TickerProviderStateMixin {
  bool _isGenerating = true;
  double _progress = 0.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startMockGeneration();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startMockGeneration() async {
    // Simulate progress loops
    for (int i = 0; i <= 100; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        _progress = i / 100;
      });
    }

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPalette(AppThemeMode.royal);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _isGenerating
          ? null
          : AppBar(
              title: Text(
                'Your Invitation',
                style: TextStyle(color: palette.textPrimary),
              ),
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(color: palette.textPrimary),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ),
      body: _isGenerating
          ? _buildLoadingState(palette)
          : _buildPreviewState(palette),
    );
  }

  Widget _buildLoadingState(AppColorPalette palette) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 8,
                  backgroundColor: palette.surfaceLight,
                  color: palette.primary,
                ),
              ),
              Icon(Icons.auto_awesome, size: 48, color: palette.warn),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Creating your invitation...',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair Display',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${(_progress * 100).toInt()}% Complete',
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            [
              'Analyzing template assets...',
              'Customizing text layers...',
              'Rendering video scenes...',
              'Finalizing audio mix...',
              'Optimizing for WhatsApp share...',
              'Done!',
            ][(_progress * 5).floor().clamp(0, 5)],
            style: TextStyle(color: palette.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewState(AppColorPalette palette) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Mock Video Placeholder
                Image.asset(
                  'assets/splash_icon.png', // Fallback
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      Container(color: palette.surface),
                ),
                Container(color: Colors.black.withOpacity(0.3)),
                Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: palette.textPrimary.withOpacity(0.8),
                ),

                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: palette.primary,
                        child: const Text(
                          'PREVIEW MODE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ananya & Rohan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Playfair Display',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Mock Download
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Video saved to gallery!'),
                        backgroundColor: palette.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text(
                        'Download HD Video',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Edit
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.textPrimary,
                    side: BorderSide(color: palette.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Change Style',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
