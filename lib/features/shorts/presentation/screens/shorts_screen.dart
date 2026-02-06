import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/short.dart';
import '../bloc/shorts_bloc.dart';
import '../bloc/shorts_event.dart';
import '../bloc/shorts_state.dart';
import '../widgets/shorts_action_bar.dart';
import '../widgets/shorts_info_sheet.dart';
import '../managers/video_controller_manager.dart';
import '../widgets/shorts_player_widget.dart';
import '../../../../core/di/service_locator.dart';
import '../../../invitation_creator/presentation/bloc/invitation_bloc.dart';
import '../../../invitation_creator/presentation/bloc/invitation_event.dart';
import '../../../templates/domain/models/template.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  final PageController _pageController = PageController();
  late final VideoControllerManager _videoManager;

  @override
  void initState() {
    super.initState();
    _videoManager = VideoControllerManager(sl.shortsVideoService);
    context.read<ShortsBloc>().add(const LoadShorts());
  }

  void _onPageChanged(int index, List<Short> shorts) {
    // 1. Play current
    _videoManager.play(index);

    // 2. Pause previous/next (to save resources)
    if (index > 0) _videoManager.pause(index - 1);

    // 3. Preload next 2 videos
    if (index + 1 < shorts.length) {
      _preload(index + 1, shorts[index + 1]);
    }
    if (index + 2 < shorts.length) {
      _preload(index + 2, shorts[index + 2]);
    }

    // 4. Dispose metrics (sliding window)
    _videoManager.disposeMetrics(index);

    setState(() {}); // Rebuild to show updated players
  }

  void _preload(int index, Short short) {
    if (short.videoUrl != null) {
      _videoManager.preload(index, short.videoUrl!).then((_) {
        if (mounted) setState(() {});
      });
    }
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
      body: BlocConsumer<ShortsBloc, ShortsState>(
        listener: (context, state) {
          if (state is ShortsLoaded && state.shortsWithFavorites.isNotEmpty) {
            // Preload first video immediately
            final firstShort = state.shortsWithFavorites[0];
            if (firstShort.videoUrl != null) {
              _videoManager.preload(0, firstShort.videoUrl!).then((_) {
                _videoManager.play(0);
                if (mounted) setState(() {});
              });
            }
            // Preload second video, but don't play it
            if (state.shortsWithFavorites.length > 1) {
              _preload(1, state.shortsWithFavorites[1]);
            }
          }
        },
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
              onPageChanged: (index) => _onPageChanged(index, shorts),
              itemBuilder: (context, index) {
                final short = shorts[index];
                return _buildShortCard(context, index, short);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildShortCard(BuildContext context, int index, Short short) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Video Player or Placeholder
        ShortsPlayerWidget(
          short: short,
          controller: _videoManager.getController(index),
          isInitialized: _videoManager.isInitialized(index),
        ),

        // 2. Play Icon (if not playing/initialized)
        if (!_videoManager.isInitialized(index))
          Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 80,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),

        // 3. Gradient Overlay for Text Visibility
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

        // 4. Right Side Actions (Discovery-Focused)
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
              // Map Short to Template for consistency (since they share ID)
              // Ideally we'd map fields, but for now ID and Title are enough to fetch full details
              context.read<InvitationBloc>().add(
                TemplateSelected(
                  Template(
                    id: short.id,
                    title: short.title,
                    thumbnailUrl: short.thumbnailUrl ?? '',
                    cost: 499.0, // Default cost
                    category: short.category,
                    videoUrl: short.videoUrl ?? '',
                    duration: '0:30', // Default duration
                    youtubeId: '',
                    description: 'Wedding Invitation',
                  ),
                ),
              );
              Navigator.pushNamed(context, '/details_form');
            },
          ),
        ),

        // 5. Bottom Template Info
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
    _videoManager.disposeAll();
    super.dispose();
  }
}
