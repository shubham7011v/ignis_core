import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/engine/engine.dart' as engine;
import '../../../../core/utils/app_logger.dart';
import 'session_event.dart';
import 'session_state.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/engine/data/handlers/websocket_session_handler.dart';
import '../../../../core/error/failure.dart'; // Explicit import ensuring Failure is available

class SessionBloc extends Bloc<SessionEvent, SessionBlocState> {
  engine.SessionHandler _handler;
  StreamSubscription? _stateSub;
  StreamSubscription? _eventSub;
  StreamSubscription? _chatSub;
  StreamSubscription? _errorSub;

  SessionBloc({engine.SessionHandler? handler})
    : _handler = handler ?? di.sl.sessionHandler,
      super(SessionBlocState.initial()) {
    // Action handlers
    on<HandlerSyncRequested>(_onHandlerSync);
    on<SessionResetRequested>(_onResetRequested);
    on<SessionHandlerSwapped>(_onHandlerSwapped);
    on<SessionErrorOccurred>(_onErrorOccurred);
    on<SessionErrorCleared>(_onErrorCleared);

    // Chat Event Handlers
    on<ChatStreamUpdated>(_onChatStreamUpdated);
    on<SendChatMessage>(_onSendChatMessage);
    on<SendEmojiMessage>(_onSendEmojiMessage);
    on<SendTypingStatus>(_onSendTypingStatus);
    on<TypingStatusChanged>(_onTypingStatusChanged);

    // Engine update handlers
    on<EngineStateUpdated>((event, emit) {
      AppLogger.sessionEvent(
        'EngineStateUpdated',
        data: {'phase': event.state.currentPhase.name},
      );

      final nextState = state.copyWith(
        engineState: event.state,
        pNames: _handler.pNames,
      );

      emit(nextState);
    });

    on<EngineEventReceived>((event, emit) {
      AppLogger.sessionEvent(
        'EngineEventReceived',
        data: {'type': event.type.name, 'actor': event.actorId},
      );

      emit(
        state.copyWith(
          lastEvent: event.type,
          lastEventActorId: event.actorId,
          lastEventTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });

    _initHandler();
    add(const HandlerSyncRequested());
  }

  void _initHandler() {
    _stateSub = _handler.sessionStateStream.listen((newState) {
      if (!isClosed) {
        add(EngineStateUpdated(newState));
      }
    });

    _eventSub = _handler.eventStream.listen((event) {
      if (!isClosed) {
        if (event == engine.SessionEventType.typingStatusChanged) {
          final actorId = _handler.activeEventActorId;
          if (actorId != null) {
            add(
              TypingStatusChanged(
                actorId,
                _handler.typingStatus[actorId] ?? false,
              ),
            );
          }
        } else {
          add(EngineEventReceived(event, _handler.activeEventActorId));
        }
      }
    });

    _chatSub = _handler.chatStream.listen((msg) {
      if (!isClosed) {
        add(ChatStreamUpdated(msg));
      }
    });

    _errorSub = _handler.errorStream.listen((failure) {
      if (!isClosed) {
        add(SessionErrorOccurred(failure));
      }
    });
  }

  void _onResetRequested(
    SessionResetRequested event,
    Emitter<SessionBlocState> emit,
  ) {
    _handler.resetSession();
    emit(SessionBlocState.initial());
    add(const HandlerSyncRequested());
  }

  void _onHandlerSwapped(
    SessionHandlerSwapped event,
    Emitter<SessionBlocState> emit,
  ) {
    _stateSub?.cancel();
    _eventSub?.cancel();
    _chatSub?.cancel();
    _errorSub?.cancel();

    if (_handler is! WebSocketSessionHandler) {
      _handler.dispose();
    }

    _handler = event.newHandler;
    _initHandler();

    emit(SessionBlocState.initial());
    add(const HandlerSyncRequested());
  }

  void _onHandlerSync(
    HandlerSyncRequested event,
    Emitter<SessionBlocState> emit,
  ) {
    AppLogger.info(
      'HandlerSyncRequested: Syncing SessionBloc state with handler',
    );
    emit(
      state.copyWith(
        engineState: _handler.currentState,
        pNames: _handler.pNames,
        lastEvent: _handler.lastEventType,
        lastEventTimestamp: _handler.lastEventTimestamp,
        lastEventActorId: _handler.activeEventActorId,
      ),
    );
  }

  engine.SessionHandler get handler => _handler;

  @override
  Future<void> close() {
    _stateSub?.cancel();
    _eventSub?.cancel();
    _chatSub?.cancel();
    _errorSub?.cancel();

    if (_handler is! WebSocketSessionHandler) {
      _handler.dispose();
    }
    return super.close();
  }

  void _onErrorOccurred(
    SessionErrorOccurred event,
    Emitter<SessionBlocState> emit,
  ) {
    final nextState = state.copyWith(failure: event.error);

    if (event.error is ServerFailure) {
      final failure = event.error as ServerFailure;
      if (failure.originalError is Map) {
        final data = failure.originalError as Map;
        if (data['code'] == 'ROOM_CLOSED') {
          emit(nextState.copyWith(effect: () => const SessionNavigateToHome()));
          emit(nextState.copyWith(effect: () => null));
          return;
        }
      }
    }

    // Rollback for optimistic updates: force re-sync with handler
    add(const HandlerSyncRequested());
  }

  void _onErrorCleared(
    SessionErrorCleared event,
    Emitter<SessionBlocState> emit,
  ) {
    emit(state.copyWith(clearFailure: true));
  }

  // Chat Handlers
  void _onChatStreamUpdated(
    ChatStreamUpdated event,
    Emitter<SessionBlocState> emit,
  ) {
    if (event.message['type'] == 'emoji') {
      add(
        EngineEventReceived(
          engine.SessionEventType.emojiReceived,
          event.message['senderId'] == di.sl.authRepository.currentUser?.uid
              ? 'me'
              : event.message['senderId'],
        ),
      );
    }

    final updatedMessages = List<Map<String, dynamic>>.from(state.chatMessages)
      ..add(event.message);

    if (updatedMessages.length > 50) {
      updatedMessages.removeAt(0);
    }

    emit(state.copyWith(chatMessages: updatedMessages));
  }

  void _onSendChatMessage(
    SendChatMessage event,
    Emitter<SessionBlocState> emit,
  ) {
    _handler.sendChatMessage(event.message);
  }

  void _onSendEmojiMessage(
    SendEmojiMessage event,
    Emitter<SessionBlocState> emit,
  ) {
    _handler.sendEmojiMessage(event.emojiId);
  }

  void _onSendTypingStatus(
    SendTypingStatus event,
    Emitter<SessionBlocState> emit,
  ) {
    _handler.setTypingStatus(event.isTyping);
  }

  void _onTypingStatusChanged(
    TypingStatusChanged event,
    Emitter<SessionBlocState> emit,
  ) {
    final updatedTypingStatus = Map<String, bool>.from(state.typingStatus);
    updatedTypingStatus[event.senderId] = event.isTyping;
    emit(state.copyWith(typingStatus: updatedTypingStatus));
  }
}
