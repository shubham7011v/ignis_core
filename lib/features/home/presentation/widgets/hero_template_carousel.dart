import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../../../../core/widgets/ignis_network_image.dart';
import '../../../templates/domain/models/template.dart';

class HeroTemplateCarousel extends StatefulWidget {
  final List<Template> featuredTemplates;
  final Function(Template) onCreatePressed;
  final Function(Template) onPlayPressed;

  const HeroTemplateCarousel({
    super.key,
    required this.featuredTemplates,
    required this.onCreatePressed,
    required this.onPlayPressed,
  });

  @override
  State<HeroTemplateCarousel> createState() => _HeroTemplateCarouselState();
}

class _HeroTemplateCarouselState extends State<HeroTemplateCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.featuredTemplates.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_currentPage < widget.featuredTemplates.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featuredTemplates.isEmpty) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 0.85, // Cinema poster style aspect ratio
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.featuredTemplates.length,
            itemBuilder: (context, index) {
              final template = widget.featuredTemplates[index];
              return _HeroSlide(
                template: template,
                onCreatePressed: () => widget.onCreatePressed(template),
                onPlayPressed: () => widget.onPlayPressed(template),
              );
            },
          ),
          // Page Indicators
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.featuredTemplates.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? IgnisTheme.goldAccent
                        : Colors.white24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final Template template;
  final VoidCallback onCreatePressed;
  final VoidCallback onPlayPressed;

  const _HeroSlide({
    required this.template,
    required this.onCreatePressed,
    required this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        IgnisNetworkImage(imageUrl: template.thumbnailUrl, fit: BoxFit.cover),
        // Gradient Overlay (The "Hotstar" Look)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black54,
                Colors.black,
              ],
              stops: [0.0, 0.4, 0.7, 1.0],
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                template.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (template.cost > 0) ...[
                    Text(
                      '₹${template.cost.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        color: IgnisTheme.goldAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    template.category,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    template.duration,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onCreatePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IgnisTheme.goldAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.movie_creation_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'CREATE NOW',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: onPlayPressed,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white70),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.play_arrow_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
