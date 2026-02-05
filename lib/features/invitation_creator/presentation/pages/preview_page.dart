import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/ignis_network_image.dart';
import '../bloc/invitation_bloc.dart';
import '../bloc/invitation_event.dart';
import '../bloc/invitation_state.dart';

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
              content: Text('Order Failed: ${state.errorMessage}'),
              backgroundColor: palette.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isProcessing = state.status == InvitationStatus.placingOrder;

        return Scaffold(
          backgroundColor: palette.background,
          appBar: isProcessing || state.status == InvitationStatus.success
              ? null
              : AppBar(
                  title: Text(
                    'Review Order',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontFamily: 'Cinzel',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  iconTheme: IconThemeData(color: palette.textPrimary),
                ),
          body: isProcessing
              ? _buildPlacingOrderState(palette, state)
              : _buildReviewState(palette, state),
        );
      },
    );
  }

  Widget _buildPlacingOrderState(
    AppColorPalette palette,
    InvitationState state,
  ) {
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
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFFFFD700),
            ), // Gold
          ),
          const SizedBox(height: 32),
          Text(
            'Placing Your Order',
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
              'Securely transmitting your details to our studio...',
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
    if (state.status == InvitationStatus.success) {
      return _buildSuccessState(palette, state);
    }

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

                const SizedBox(height: 32),
                _buildSectionHeader(palette, 'Order Summary'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.divider),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        palette,
                        'Service',
                        'Manual Video Creation',
                        Icons.video_camera_back,
                      ),
                      const Divider(),
                      _buildDetailRow(
                        palette,
                        'Delivery',
                        '2-3 Business Days',
                        Icons.watch_later_outlined,
                      ),
                      const Divider(),
                      _buildDetailRow(
                        palette,
                        'Price',
                        'FREE (Introductory Offer)',
                        Icons.monetization_on,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Action Buttons
        _buildActionButtons(palette, context, state),
      ],
    );
  }

  Widget _buildSuccessState(AppColorPalette palette, InvitationState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: palette.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Order Placed Successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cinzel',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Order ID: #${state.orderId?.substring(0, 8) ?? "N/A"}',
            style: TextStyle(
              color: palette.textTertiary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Our team has started crafting your masterpiece. We will notify you once it is ready (approx. 2-3 days).',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Return to Home',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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

  // ... (Keep existing _buildStyleSummary, _buildDetailsSummary, _buildDetailRow methods) ...
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
            child: IgnisNetworkImage(
              imageUrl: style.thumbnailUrl,
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
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please sign in to place an order'),
                    ),
                  );
                  return;
                }

                context.read<InvitationBloc>().add(PlaceOrderRequested(userId));
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
                  Icon(Icons.check_circle_outline),
                  SizedBox(width: 12),
                  Text(
                    'Place Order',
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
            'We will manually craft your video with care',
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
