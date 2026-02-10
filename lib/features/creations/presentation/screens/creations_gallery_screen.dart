import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../bloc/creations_bloc.dart';
import '../bloc/creations_state.dart';
import '../widgets/order_card.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class CreationsGalleryScreen extends StatelessWidget {
  const CreationsGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IgnisTheme.deepMaroon,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MY CREATIONS',
          style: GoogleFonts.cinzel(
            color: IgnisTheme.goldAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/style_selection');
        },
        backgroundColor: IgnisTheme.goldAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(
          'CREATE NEW',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<CreationsBloc, CreationsState>(
        builder: (context, state) {
          if (state is CreationsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: IgnisTheme.goldAccent),
            );
          } else if (state is CreationsLoaded) {
            if (state.orders.isEmpty) {
              return _buildEmptyState(context);
            }

            final inProgress = state.orders
                .where(
                  (o) =>
                      o.status == OrderStatus.pending ||
                      o.status == OrderStatus.inProgress,
                )
                .toList();

            final completed = state.orders
                .where(
                  (o) =>
                      o.status == OrderStatus.delivered ||
                      o.status == OrderStatus.cancelled,
                )
                .toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (inProgress.isNotEmpty) ...[
                        _buildSectionHeader(
                          'IN PROGRESS (${inProgress.length})',
                        ),
                        _buildGridSliver(inProgress),
                        const SizedBox(height: 24),
                      ],
                      if (completed.isNotEmpty) ...[
                        _buildSectionHeader('COMPLETED (${completed.length})'),
                        _buildGridSliver(completed),
                      ],
                      const SizedBox(height: 80), // Bottom padding for FAB
                    ]),
                  ),
                ),
              ],
            );
          } else if (state is CreationsError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildGridSliver(List<Order> orders) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: () {
            // Navigate to details or play video if delivered
          },
          onDelete: () {
            // Optional: Allow hiding/deleting orders
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: EmptyStateWidget(
        icon: Icons.video_library_outlined,
        title: 'START YOUR FIRST CREATION',
        message:
            'Choose a template to create your stunning wedding invitation.',
        actionLabel: 'BROWSE TEMPLATES',
        onAction: () => Navigator.pushNamed(context, '/search'),
      ),
    );
  }
}
