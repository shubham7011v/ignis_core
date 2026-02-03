import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../../shared/components/app_error_widget.dart';
import '../../../../core/di/service_locator.dart' as di;

class ProfileViewScreen extends StatelessWidget {
  final String userId;

  const ProfileViewScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(repository: di.sl.profileRepository)
            ..add(ProfileViewRequested(userId)),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final palette = AppColors.getPalette(themeState.mode);

          return Scaffold(
            backgroundColor: palette.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: palette.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: palette.primary),
                  );
                }

                if (state is ProfileError) {
                  return AppErrorWidget(
                    message: state.failure.message,
                    onRetry: () {
                      context.read<ProfileBloc>().add(
                        ProfileViewRequested(userId),
                      );
                    },
                  );
                }

                if (state is ProfileLoaded) {
                  return _buildProfileContent(context, state, palette);
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    ProfileLoaded state,
    AppColorPalette palette,
  ) {
    final profile = state.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar and Name
          CircleAvatar(
            radius: 60,
            backgroundColor: palette.primary.withValues(alpha: 0.1),
            backgroundImage: profile.photoUrl != null
                ? NetworkImage(profile.photoUrl!)
                : null,
            onBackgroundImageError: (exception, stackTrace) {
              // Silently handle error
            },
            child: profile.photoUrl == null
                ? Icon(Icons.person, size: 60, color: palette.primary)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            style: GoogleFonts.cinzel(
              color: palette.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Online Status (Repurposed as Wedding Planning Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: palette.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'PREMIUM PLANNER',
                style: GoogleFonts.inter(
                  color: palette.success,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Stats Grid (Repurposed for Wedding Planning)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: palette.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: palette.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'WEDDING PROJECTS',
                  style: GoogleFonts.cinzel(
                    color: palette.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'INVITATIONS',
                        '${profile.stats.invitationsCreated}',
                        palette.textSecondary,
                        palette,
                      ),
                    ),
                    Container(height: 40, width: 1, color: palette.divider),
                    Expanded(
                      child: _buildStatItem(
                        'GUESTS',
                        '${profile.stats.guestsCount}',
                        palette.textSecondary,
                        palette,
                      ),
                    ),
                    Container(height: 40, width: 1, color: palette.divider),
                    Expanded(
                      child: _buildStatItem(
                        'RSVPS',
                        '${profile.stats.rsvpsReceived}',
                        palette.success,
                        palette,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Premium Badge / Subscription Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [palette.primaryDim, palette.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(
                  'GO PREMIUM',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlock unlimited video renders and guest analytics.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    AppColorPalette palette,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: palette.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.cinzel(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
