import 'package:flutter/material.dart';

import '../bloc/session_state.dart';
import '../widgets/session_top_bar.dart';
import '../widgets/session_background.dart';
import '../widgets/floating_emoji_layer.dart';
import '../managers/turn_popup_manager.dart';
import '../handlers/navigation_handler.dart';

class SessionView extends StatelessWidget {
  final SessionBlocState state;
  final SessionBlocState visualState;
  final AnimationController entryController;
  final TurnPopupManager turnPopups;
  final NavigationHandler navigation;
  final List<FloatingEmoji> activeEmojis;
  final void Function(bool show) onSetChatVisible;
  final void Function(bool show) onSetEmojiVisible;

  const SessionView({
    super.key,
    required this.state,
    required this.visualState,
    required this.entryController,
    required this.turnPopups,
    required this.navigation,
    required this.activeEmojis,
    required this.onSetChatVisible,
    required this.onSetEmojiVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          const SessionBackground(),
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildAnimatedEntry(
                  controller: entryController,
                  interval: const Interval(
                    0.0,
                    0.4,
                    curve: Curves.easeOutCubic,
                  ),
                  slideBegin: const Offset(0, -0.5),
                  child: SessionTopBar(
                    state: visualState,
                    onChatTap: () => onSetChatVisible(true),
                  ),
                ),

                const SizedBox(height: 10),

                // Main Content Area (Vivaah content will go here)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_outline,
                          color: Colors.white24,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Ignis Core Session",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Feedback Popups
                turnPopups.buildPopup() ?? const SizedBox.shrink(),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Action Layers (Emojis, etc)
          _buildActionLayers(),
        ],
      ),
    );
  }

  Widget _buildAnimatedEntry({
    required AnimationController controller,
    required Interval interval,
    required Offset slideBegin,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: slideBegin,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: interval)),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: controller,
          curve: Interval(interval.begin, interval.end, curve: Curves.easeOut),
        ),
        child: child,
      ),
    );
  }

  Widget _buildActionLayers() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [FloatingEmojiLayer(activeEmojis: activeEmojis)],
        ),
      ),
    );
  }
}
