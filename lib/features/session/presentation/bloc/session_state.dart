import 'package:equatable/equatable.dart';
import '../../../../core/engine/engine.dart' as engine;
import '../../../../core/error/failure.dart';

sealed class SessionSideEffect {
  const SessionSideEffect();
}

class SessionNavigateToHome extends SessionSideEffect {
  const SessionNavigateToHome();
}

class SessionBlocState extends Equatable {
  final engine.SessionState engineState;

  // -- Engine Update Events --
  final engine.SessionEventType lastEvent;
  final String? lastEventActorId;
  final int
  lastEventTimestamp; // Used to trigger animations on same-type events

  // -- Player Info --
  final Map<String, String> pNames;

  // -- History --
  final List<Map<String, dynamic>> chatMessages;
  final Map<String, bool> typingStatus;

  // -- Error State --
  final Failure? failure;

  // -- Side Effects --
  final SessionSideEffect? effect;

  const SessionBlocState({
    required this.engineState,
    required this.lastEvent,
    this.lastEventActorId,
    this.lastEventTimestamp = 0,
    required this.pNames,
    required this.chatMessages,
    required this.typingStatus,
    this.failure,
    this.effect,
  });

  factory SessionBlocState.initial() => SessionBlocState(
    engineState: engine.SessionState.initial(),
    lastEvent: engine.SessionEventType.none,
    lastEventTimestamp: 0,
    pNames: const {},
    chatMessages: const [],
    typingStatus: const {},
    effect: null,
  );

  SessionBlocState copyWith({
    engine.SessionState? engineState,
    engine.SessionEventType? lastEvent,
    String? lastEventActorId,
    int? lastEventTimestamp,
    Map<String, String>? pNames,
    List<Map<String, dynamic>>? chatMessages,
    Map<String, bool>? typingStatus,
    Failure? failure,
    bool clearFailure = false,
    SessionSideEffect? Function()? effect,
  }) {
    return SessionBlocState(
      engineState: engineState ?? this.engineState,
      lastEvent: lastEvent ?? this.lastEvent,
      lastEventActorId: lastEventActorId ?? this.lastEventActorId,
      lastEventTimestamp: lastEventTimestamp ?? this.lastEventTimestamp,
      pNames: pNames ?? this.pNames,
      chatMessages: chatMessages ?? this.chatMessages,
      typingStatus: typingStatus ?? this.typingStatus,
      failure: clearFailure ? null : (failure ?? this.failure),
      effect: effect != null ? effect() : this.effect,
    );
  }

  String getPlayerName(String id) => pNames[id] ?? id;

  @override
  List<Object?> get props => [
    engineState,
    lastEvent,
    lastEventActorId,
    lastEventTimestamp,
    pNames,
    chatMessages,
    typingStatus,
    failure,
    effect,
  ];
}
