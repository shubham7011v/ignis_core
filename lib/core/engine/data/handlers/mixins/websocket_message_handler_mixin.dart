import 'dart:convert';
import '../../../../di/service_locator.dart';
import '../../../../error/failure.dart';
import '../../../../../../features/auth/domain/models/user_stats.dart';
import '../../../../../../features/social/domain/models/friend_record.dart';
import '../../../../constants/sound_assets.dart';
import '../../../domain/models/participant.dart';
import '../../../domain/models/room_event.dart';
import '../../../domain/models/session_enums.dart';
import '../../../domain/models/session_state.dart';
import '../../../../utils/app_logger.dart';
import 'websocket_handler_base.dart';

mixin WebSocketMessageHandlerMixin on WebSocketHandlerBase {
  SessionEventType _lastEventType = SessionEventType.none;
  int _lastEventTimestamp = 0;

  SessionEventType get lastEventType => _lastEventType;
  int get lastEventTimestamp => _lastEventTimestamp;
  void handleMessage(dynamic data) {
    lastMessageTime = DateTime.now(); // Reset watchdog

    try {
      final msg = jsonDecode(data as String) as Map<String, dynamic>;
      final type = msg['type'] as String;

      if (type != 'PONG') {
        AppLogger.sessionEvent('📥 [WebSocket] Received: $type');
      }

      if (type == 'PONG') {
        AppLogger.sessionEvent('🏓 [WebSocket] PONG'); // Heartbeat response
        return;
      }

      switch (type) {
        case 'AUTH_OK':
          authTimeoutTimer?.cancel();
          AppLogger.sessionEvent(
            '✅ Auth successful: ${msg['data']} (ID: $connectionId)',
          );
          connectionStatus = ConnectionStatus.connected;

          if (connectionCompleter != null &&
              !connectionCompleter!.isCompleted) {
            connectionCompleter!.complete();
          }

          onAuthSuccess(msg['data'] as Map<String, dynamic>);
          break;

        case 'STATS_UPDATE':
          _processStatsUpdate(msg['data'] as Map<String, dynamic>);
          break;

        case 'AUTH_FAIL':
          _processAuthFail(msg['data'] as Map<String, dynamic>);
          break;

        case 'GAME_STATE':
          handleGameState(msg['data'] as Map<String, dynamic>);
          break;

        case 'ERROR':
          _processError(msg['data'] as Map<String, dynamic>);
          break;

        case 'LEADERBOARD_DATA':
          _processLeaderboardData((msg['data'] as List<dynamic>?) ?? []);
          break;

        case 'FRIEND_LIST':
          _processFriendList((msg['data'] as List<dynamic>?) ?? []);
          break;

        case 'ROOM_CREATED':
          _processRoomCreated(msg['data'] as Map<String, dynamic>);
          break;

        case 'ROOM_JOINED':
          _processRoomJoined(msg['data'] as Map<String, dynamic>);
          break;

        case 'ROOM_UPDATE':
          _processRoomUpdate(msg['data'] as Map<String, dynamic>);
          break;

        case 'CHALLENGE_CLAIM_OK':
          _processChallengeClaimOk(msg['data'] as Map<String, dynamic>);
          break;

        case 'CHAT':
          _processChat(msg['data'] as Map<String, dynamic>);
          break;

        case 'EMOJI':
          _processEmoji(msg['data'] as Map<String, dynamic>);
          break;

        case 'TYPING':
          _processTyping(msg['data'] as Map<String, dynamic>);
          break;
      }
    } catch (e, stack) {
      AppLogger.sessionError(
        'Error handling WebSocket message',
        exception: e,
        stackTrace: stack,
      );
    }
  }

  // Implementation methods
  void _processStatsUpdate(Map<String, dynamic> data) {
    try {
      final stats = UserStats.fromJson(data);
      if (!statsController.isClosed) {
        statsController.add(stats);
      }
      AppLogger.info(
        'Stats updated: ${stats.invitationsCreated} invites, ${stats.guestsCount} guests',
      );
    } catch (e) {
      AppLogger.sessionError('Failed to parse stats update', exception: e);
    }
  }

  void _processAuthFail(Map<String, dynamic> data) {
    AppLogger.warning('Auth failed: $data');
    if (!errorController.isClosed) {
      errorController.add(
        AuthFailure(data['message'] ?? 'Authentication failed', data),
      );
    }
  }

  void _processError(Map<String, dynamic> errorData) {
    AppLogger.sessionError('Server Error: ${errorData['message']}');
    if (!errorController.isClosed) {
      errorController.add(
        ServerFailure(
          errorData['message'] ?? 'Unknown server error',
          errorData,
        ),
      );
    }
  }

  void _processLeaderboardData(List<dynamic> data) {
    try {
      final leaderboard = data
          .map((u) => UserStats.fromJson(u as Map<String, dynamic>))
          .toList();
      if (!leaderboardController.isClosed) {
        leaderboardController.add(leaderboard);
      }
    } catch (e) {
      AppLogger.sessionError('Failed to parse leaderboard', exception: e);
    }
  }

  void _processFriendList(List<dynamic> data) {
    try {
      final friends = data
          .map((f) => FriendRecord.fromJson(f as Map<String, dynamic>))
          .toList();
      if (!friendsController.isClosed) {
        friendsController.add(friends);
      }
    } catch (e) {
      AppLogger.sessionError('Failed to parse friend list', exception: e);
    }
  }

  void _processRoomCreated(Map<String, dynamic> data) {
    try {
      final evt = RoomCreated.fromJson(data);
      if (!roomEventController.isClosed) {
        roomEventController.add(evt);
      }
    } catch (e) {
      AppLogger.sessionError('Failed to parse ROOM_CREATED', exception: e);
    }
  }

  void _processRoomJoined(Map<String, dynamic> data) {
    try {
      final evt = RoomJoined.fromJson(data);
      if (!roomEventController.isClosed) {
        roomEventController.add(evt);
      }
    } catch (e) {
      AppLogger.sessionError('Failed to parse ROOM_JOINED', exception: e);
    }
  }

  void _processRoomUpdate(Map<String, dynamic> data) {
    try {
      final currentUserId = sl.authRepository.currentUser?.uid;
      final evt = RoomUpdated.fromJson(data, currentUserId: currentUserId);
      AppLogger.sessionEvent(
        '🏠 [WebSocket] Room Update: ${evt.participants.length} players',
      );
      if (!roomEventController.isClosed) {
        roomEventController.add(evt);
      }
    } catch (e) {
      AppLogger.sessionError('Failed to parse ROOM_UPDATE', exception: e);
    }
  }

  void _processChallengeClaimOk(Map<String, dynamic> data) {
    try {
      if (!challengeClaimResultController.isClosed) {
        challengeClaimResultController.add(data);
      }
      sl.audioService.playSfx(SoundAssets.turnAlert);
    } catch (e) {
      AppLogger.sessionError(
        'Failed to parse challenge claim reward',
        exception: e,
      );
    }
  }

  void _processChat(Map<String, dynamic> data) {
    try {
      data['type'] = 'chat';
      if (!chatController.isClosed) {
        chatController.add(data);
      }
    } catch (e) {
      AppLogger.sessionError('Failed to parse chat message', exception: e);
    }
  }

  void _processEmoji(Map<String, dynamic> data) {
    try {
      data['type'] = 'emoji';
      if (!chatController.isClosed) {
        chatController.add(data);
      }
      sl.audioService.playEmojiSound(data['emojiId'] as String);
    } catch (e) {
      AppLogger.sessionError('Failed to parse emoji message', exception: e);
    }
  }

  void _processTyping(Map<String, dynamic> data) {
    try {
      final senderId = data['senderId'] as String;
      final isTyping = data['isTyping'] as bool;

      onTypingStatusChanged(senderId, isTyping);
    } catch (e) {
      AppLogger.sessionError('Failed to parse typing message', exception: e);
    }
  }

  void handleGameState(Map<String, dynamic> stateData) {
    // Standardize logs
    final phaseStr = stateData['phase'] as String;
    final players = (stateData['participants'] as List?)?.length ?? 0;
    AppLogger.sessionEvent(
      '📊 [WebSocket] GAME_STATE: Phase: $phaseStr, Players: $players',
    );

    // Parse participants (Do this EARLY so we can use names in logs)
    final myId = sl.authRepository.currentUser?.uid;
    final participantsList = stateData['participants'] as List<dynamic>? ?? [];
    final participants = participantsList.map((p) {
      final pMap = p as Map<String, dynamic>;
      final pId = pMap['id'] as String?; // Might be null for others
      final sessionId = pMap['sessionId'] as String;
      final isMe = (pId != null && pId == myId);
      final participantId = isMe ? 'me' : (pId ?? sessionId);
      final participantName = pMap['name'] as String;

      // ✅ FIX: Populate pNames map for UI display
      pNames[participantId] = participantName;

      return Participant(
        id: participantId,
        sessionId: sessionId,
        name: participantName,
        avatarUrl: pMap['avatarUrl'] as String?,
        isMe: isMe,
        isActive: pMap['isActive'] as bool? ?? false,
        isDisconnected: pMap['isDisconnected'] as bool? ?? false,
        unitCount: 0, // Default to 0 as legacy field is removed from server
      );
    }).toList();

    // Parse phase
    final phase = SessionPhase.values.firstWhere(
      (p) => p.name == phaseStr,
      orElse: () => SessionPhase.idle,
    );

    // Parse rich event data
    final lastEvent = stateData['lastEvent'] as String?;
    final actorId = stateData['lastEventActorId'] as String?;
    if (lastEvent != null) {
      var logMsg = '🎬 [WebSocket] Last Event: $lastEvent';
      if (actorId != null && actorId.isNotEmpty) {
        // Find actor name for log
        // Try finding by sessionId first (common for events), then id
        final actorName = participants
            .firstWhere(
              (p) => p.sessionId == actorId || p.id == actorId,
              orElse: () => Participant(
                id: 'unknown',
                sessionId: 'unknown',
                name: actorId, // Fallback to ID
                unitCount: 0,
                isMe: false,
              ),
            )
            .name;

        logMsg += ' by $actorName';
      }
      AppLogger.sessionEvent(logMsg);
    }

    final newState = SessionState(
      roomId: 'online',
      participants: participants,
      currentPhase: phase,
      isSyncing: false,
      createdAt: stateData['createdAt'] as int?,
    );

    currentSessionState = newState;
    if (!stateStreamController.isClosed) {
      stateStreamController.add(newState);

      AppLogger.sessionEvent('🧑 [WebSocket] Session Sync Complete');
    }
  }

  // Abstract methods for bridge to main handler
  void onAuthSuccess(Map<String, dynamic> authData);
  void onTypingStatusChanged(String senderId, bool isTyping);
}
