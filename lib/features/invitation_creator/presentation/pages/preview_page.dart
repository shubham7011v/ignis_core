import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors.dart';
import '../bloc/invitation_bloc.dart';
import '../bloc/invitation_event.dart';
import '../bloc/invitation_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex_plus/open_filex_plus.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({super.key});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPalette(AppThemeMode.royal);

    return BlocConsumer<InvitationBloc, InvitationState>(
      listener: (context, state) {
        if (state.status == InvitationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Generation Failed: ${state.errorMessage}'),
              backgroundColor: palette.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isGenerating = state.status == InvitationStatus.generating;

        return Scaffold(
          backgroundColor: palette.background,
          appBar: isGenerating
              ? null
              : AppBar(
                  title: Text(
                    'Review Invitation',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontFamily: 'Cinzel',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  iconTheme: IconThemeData(color: palette.textPrimary),
                ),
          body: isGenerating
              ? _buildGeneratingState(palette, state)
              : _buildReviewState(palette, state),
        );
      },
    );
  }

  Widget _buildGeneratingState(AppColorPalette palette, InvitationState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.background, palette.primary.withValues(alpha: 0.2)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: state.renderProgress,
                  strokeWidth: 8,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFD700),
                  ), // Gold
                ),
                Text(
                  '${(state.renderProgress * 100).toInt()}%',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Creating Cinematic Magic',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cinzel',
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              state.renderProgress < 0.3
                  ? 'Downloading Royal Template...'
                  : 'Overlaying Golden Details...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewState(AppColorPalette palette, InvitationState state) {
    return Column(
      children: [
        // Progress Bar (Step 3 of 3 -> 100%)
        LinearProgressIndicator(
          value: 1.0,
          backgroundColor: palette.surfaceLight,
          valueColor: AlwaysStoppedAnimation<Color>(palette.primary),
          minHeight: 4,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FINAL STEP',
                  style: TextStyle(
                    color: palette.textTertiary,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review Selection',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cinzel',
                  ),
                ),
                const SizedBox(height: 24),

                // Style Summary Card
                _buildSectionHeader(palette, 'Selected Style'),
                const SizedBox(height: 12),
                _buildStyleSummary(palette, state),

                const SizedBox(height: 32),

                // Details Summary Card
                _buildSectionHeader(palette, 'Wedding Details'),
                const SizedBox(height: 12),
                _buildDetailsSummary(palette, state),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Success View
        if (state.status == InvitationStatus.success)
          _buildSuccessState(palette, state)
        else
          _buildActionButtons(palette, context, state),
      ],
    );
  }

  Widget _buildSuccessState(AppColorPalette palette, InvitationState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: palette.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Invitation is Ready!',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cinzel',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A masterpiece has been created and saved to your gallery.',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (state.renderOutputPath != null) {
                      final result = await OpenFilex.open(
                        state.renderOutputPath!,
                      );
                      if (result.type != ResultType.done) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Could not open video: ${result.message}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Now'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.textPrimary,
                    side: BorderSide(color: palette.divider),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (state.renderOutputPath != null) {
                      final file = XFile(state.renderOutputPath!);
                      await Share.shareXFiles(
                        [file],
                        text:
                            'You are cordially invited to our wedding celebration! 💍✨',
                      );
                    }
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: Text(
              'Return to Home',
              style: TextStyle(color: palette.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(AppColorPalette palette, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.1,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSummary(AppColorPalette palette, InvitationState state) {
    final style = state.selectedStyle;
    if (style == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              style.thumbnailUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style.name,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Cinzel',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  style.categories.join(' • '),
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.edit, color: palette.accent, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSummary(AppColorPalette palette, InvitationState state) {
    final details = state.details;
    final dateStr =
        "${details.weddingDate.day} / ${details.weddingDate.month} / ${details.weddingDate.year}";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            palette,
            'Couple',
            '${details.brideName} & ${details.groomName}',
            Icons.favorite,
          ),
          const Divider(height: 32),
          _buildDetailRow(palette, 'Date', dateStr, Icons.calendar_today),
          const Divider(height: 32),
          _buildDetailRow(palette, 'Venue', details.venue, Icons.location_on),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    AppColorPalette palette,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: palette.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: palette.accent),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: palette.textTertiary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    AppColorPalette palette,
    BuildContext context,
    InvitationState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.read<InvitationBloc>().add(GenerateVideoRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: palette.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_creation_outlined),
                  SizedBox(width: 12),
                  Text(
                    'Generate HD Video',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ready in ~60 seconds',
            style: TextStyle(
              color: palette.textTertiary,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
