import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../bloc/session_bloc.dart';
import '../bloc/session_state.dart';

import '../../../../core/engine/engine.dart' as engine;
import '../widgets/session_view.dart';
import '../widgets/floating_emoji_layer.dart';
import '../utils/session_constants.dart';
import '../managers/turn_popup_manager.dart';
import '../handlers/navigation_handler.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late TurnPopupManager _turnPopups;
  late NavigationHandler _navigation;

  final List<FloatingEmoji> _activeEmojis = [];
  bool? _isWebSocket;

  @override
  void initState() {
    super.initState();

    _turnPopups = TurnPopupManager(setState: setState);
    _navigation = NavigationHandler(
      context: context,
      setState: setState,
      isWebSocket: () => _isWebSocket == true,
    );

    _entryController = AnimationController(
      vsync: this,
      duration: SessionDurations.entryAnimationDuration,
    );

    AppLogger.sessionEvent('Screen initialized');
    _entryController.forward().then((_) {
      if (mounted) {
        context.read<SessionBloc>().handler.signalClientReady();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isWebSocket == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      _isWebSocket = args is Map && args['useWebSocket'] == true;
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _turnPopups.dispose();
    super.dispose();
  }

  void _handleSideEffect(BuildContext context, SessionSideEffect effect) {
    if (effect is SessionNavigateToHome) {
      _navigation.leaveGame('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionBlocState>(
      listenWhen: (prev, curr) =>
          curr.effect != null ||
          (curr.lastEvent != engine.SessionEventType.none &&
              prev.lastEventTimestamp != curr.lastEventTimestamp),
      listener: (context, state) {
        if (state.effect != null) {
          _handleSideEffect(context, state.effect!);
        }

        if (state.lastEvent == engine.SessionEventType.emojiReceived) {
          final senderId = state.lastEventActorId;
          if (senderId != null) {
            setState(() {
              _activeEmojis.add(
                FloatingEmoji(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  emoji: '❤️',
                  position: const Offset(200, 400),
                ),
              );
            });
          }
        }
      },
      child: BlocBuilder<SessionBloc, SessionBlocState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final shouldLeave = await _navigation.showLeaveDialog();
              if (shouldLeave == true) {
                _navigation.leaveGame('/home');
              }
            },
            child: SessionView(
              state: state,
              visualState: state,
              entryController: _entryController,
              turnPopups: _turnPopups,
              navigation: _navigation,
              activeEmojis: _activeEmojis,
              onSetChatVisible: (show) => {},
              onSetEmojiVisible: (show) => {},
            ),
          );
        },
      ),
    );
  }
}
