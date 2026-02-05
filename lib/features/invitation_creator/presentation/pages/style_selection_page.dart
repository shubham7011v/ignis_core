import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/ignis_network_image.dart';
import '../bloc/invitation_bloc.dart';
import '../bloc/invitation_event.dart';
import '../bloc/invitation_state.dart';
import '../../domain/entities/invitation_style.dart';

class StyleSelectionPage extends StatelessWidget {
  const StyleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPalette(AppThemeMode.royal);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(
          'Style Selection',
          style: TextStyle(
            color: palette.textPrimary,
            fontFamily: 'Cinzel',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      body: BlocBuilder<InvitationBloc, InvitationState>(
        builder: (context, state) {
          if (state.status == InvitationStatus.loading) {
            return Center(
              child: CircularProgressIndicator(color: palette.primary),
            );
          }

          if (state.status == InvitationStatus.failure) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: TextStyle(color: palette.error),
              ),
            );
          }

          return Column(
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: 0.2, // Step 1 of 3
                backgroundColor: palette.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(palette.primary),
                minHeight: 4,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP 1 OF 3',
                        style: TextStyle(
                          color: palette.textTertiary,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your aesthetic',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select the visual style that best matches your wedding theme.',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grid
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: state.availableStyles.length,
                          itemBuilder: (context, index) {
                            final style = state.availableStyles[index];
                            final isSelected =
                                state.selectedStyle?.id == style.id;

                            return StyleCard(
                              style: style,
                              isSelected: isSelected,
                              palette: palette,
                              onTap: () {
                                context.read<InvitationBloc>().add(
                                  StyleSelected(style),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Continue Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.selectedStyle == null
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/details_form');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.primary,
                      disabledBackgroundColor: palette.surfaceLight,
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
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class StyleCard extends StatelessWidget {
  final InvitationStyle style;
  final bool isSelected;
  final dynamic palette;
  final VoidCallback onTap;

  const StyleCard({
    super.key,
    required this.style,
    required this.isSelected,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? palette.accent : palette.divider,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: palette.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: IgnisNetworkImage(
                imageUrl: style.thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorWidget: Container(
                  color: palette.surfaceLight,
                  child: Icon(Icons.broken_image, color: palette.textTertiary),
                ),
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Cinzel',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: style.categories.map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: palette.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: palette.accent,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Selection Checkmark
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: palette.accent,
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
