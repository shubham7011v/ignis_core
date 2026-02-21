import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/short.dart';
import '../bloc/shorts_bloc.dart';
import '../bloc/shorts_event.dart';
import '../bloc/shorts_state.dart';
import '../widgets/shorts_action_bar.dart';
import '../widgets/shorts_info_sheet.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../widgets/shorts_player_widget.dart';
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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ShortsBloc>().add(const LoadShorts());
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
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
                child: EmptyStateWidget(
                  icon: Icons.movie_filter_outlined,
                  title: 'No Shorts Yet',
                  message:
                      'We are curating the best wedding templates for you.\nCheck back soon!',
                  actionLabel: 'Browse Templates',
                  onAction: () => Navigator.pushNamed(context, '/search'),
                ),
              );
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: shorts.length,
              onPageChanged: _onPageChanged,
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
        // 1. Video Player (YouTube)
        ShortsPlayerWidget(short: short, shouldPlay: index == _currentIndex),

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

        // 3. Right Side Actions
        Positioned(
          right: 12,
          top: MediaQuery.of(context).padding.top + 12,
          child: IconButton(
            onPressed: () => Navigator.pushNamed(context, '/search'),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),

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
              context.read<InvitationBloc>().add(
                TemplateSelected(
                  Template(
                    id: short.id,
                    title: short.title,
                    cost: short.cost,
                    category: short.category,
                    duration: short.duration ?? '0:30',
                    youtubeId: short.youtubeId,
                    description: short.description ?? 'Wedding Invitation',
                  ),
                ),
              );
              Navigator.pushNamed(context, '/details_form');
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
