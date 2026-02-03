import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../bloc/guests_bloc.dart';
import '../bloc/guests_event.dart';
import '../bloc/guests_state.dart';
import '../../domain/models/guest.dart';
import '../widgets/guest_card.dart';
import '../widgets/add_guest_bottom_sheet.dart';

class GuestListScreen extends StatelessWidget {
  const GuestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IgnisTheme.deepMaroon,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'GUEST LIST',
          style: GoogleFonts.cinzel(
            color: IgnisTheme.goldAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGuest(context),
        backgroundColor: IgnisTheme.actionRed,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: BlocBuilder<GuestsBloc, GuestsState>(
        builder: (context, state) {
          if (state is GuestsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: IgnisTheme.goldAccent),
            );
          } else if (state is GuestsLoaded) {
            return Column(
              children: [
                _RsvpSummary(stats: state.stats),
                Expanded(
                  child: state.guests.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.guests.length,
                          itemBuilder: (context, index) {
                            final guest = state.guests[index];
                            return GuestCard(
                              guest: guest,
                              onStatusChanged: (status) {
                                context.read<GuestsBloc>().add(
                                  UpdateGuestRsvp(guest.id, status),
                                );
                              },
                              onRemove: () {
                                context.read<GuestsBloc>().add(
                                  RemoveGuestEvent(guest.id),
                                );
                              },
                              onSendInvite: () {
                                // Logic to share invite link
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          } else if (state is GuestsError) {
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

  void _showAddGuest(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddGuestBottomSheet(
        onAdd: (name, phone) {
          context.read<GuestsBloc>().add(AddGuest(name, phone));
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
            Icons.people_alt_outlined,
            size: 64,
            color: Colors.white12,
          ),
          const SizedBox(height: 16),
          Text(
            'NO GUESTS ADDED YET',
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

class _RsvpSummary extends StatelessWidget {
  final Map<RsvpStatus, int> stats;

  const _RsvpSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'ACCEPTED',
            value: stats[RsvpStatus.accepted] ?? 0,
            color: Colors.greenAccent,
          ),
          _StatItem(
            label: 'DECLINED',
            value: stats[RsvpStatus.declined] ?? 0,
            color: Colors.redAccent,
          ),
          _StatItem(
            label: 'PENDING',
            value: stats[RsvpStatus.pending] ?? 0,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.cinzel(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
