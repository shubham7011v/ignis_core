import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../bloc/creations_bloc.dart';
import '../bloc/creations_state.dart';
import '../widgets/order_card.dart';

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
          'MY ORDERS',
          style: GoogleFonts.cinzel(
            color: IgnisTheme.goldAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<CreationsBloc, CreationsState>(
        builder: (context, state) {
          if (state is CreationsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: IgnisTheme.goldAccent),
            );
          } else if (state is CreationsLoaded) {
            if (state.orders.isEmpty) {
              return _buildEmptyState();
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return OrderCard(
                  order: order,
                  onTap: () {
                    // Navigate to details or play video if delivered
                  },
                  onDelete: () {
                    // Optional: Allow hiding/deleting orders
                    // context.read<CreationsBloc>().add(DeleteOrderEvent(order.id));
                  },
                );
              },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.white12,
          ),
          const SizedBox(height: 16),
          Text(
            'YOU HAVEN\'T CREATED ANY INVITES YET',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              color: Colors.white24,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
