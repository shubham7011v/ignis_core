import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/short.dart';
import '../bloc/shorts_bloc.dart';
import '../bloc/shorts_event.dart';
import '../bloc/shorts_state.dart';
import '../widgets/shorts_action_bar.dart';
import '../widgets/shorts_info_sheet.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Load shorts when screen is created
    context.read<ShortsBloc>().add(const LoadShorts());
  }

  void _showTemplateInfo(BuildContext context, Short short) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShortsInfoSheet(short: short),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ShortsBloc, ShortsState>(
        builder: (context, state) {
          if (state is ShortsLoading || state is ShortsInitial) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          if (state is ShortsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ShortsBloc>().add(const LoadShorts());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ShortsLoaded) {
            final shorts = state.shortsWithFavorites;

            if (shorts.isEmpty) {
              return Center(
                child: Text(
                  'No shorts available',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 18),
                ),
              );
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: shorts.length,
              itemBuilder: (context, index) {
                final short = shorts[index];
                return _buildShortCard(context, short);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildShortCard(BuildContext context, Short short) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background / Video Placeholder
        Container(
          color: Color(short.placeholderColor),
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
          child: ShortsActionBar(
            short: short,
            onFavoriteTap: () {
              context.read<ShortsBloc>().add(ToggleFavoriteShort(short.id));
            },
            onShareTap: () {
              context.read<ShortsBloc>().add(ShareShort(short.id));
            },
            onInfoTap: () => _showTemplateInfo(context, short),
            onCtaTap: () {
              // TODO: Navigate to Order Flow
            },
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
