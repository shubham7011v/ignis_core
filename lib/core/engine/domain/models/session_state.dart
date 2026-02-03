import 'package:equatable/equatable.dart';
import 'participant.dart';
import 'session_error.dart';

enum SessionPhase { idle, active, finished }

class SessionState extends Equatable {
  final String roomId;
  final List<Participant> participants;
  final SessionPhase currentPhase;
  final bool isSyncing;
  final SessionError? error;
  final int? createdAt;

  const SessionState({
    required this.roomId,
    required this.participants,
    required this.currentPhase,
    this.isSyncing = false,
    this.error,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    roomId,
    participants,
    currentPhase,
    isSyncing,
    error,
    createdAt,
  ];

  // Factory for initial/empty state
  factory SessionState.initial() {
    return const SessionState(
      roomId: '000',
      participants: [],
      currentPhase: SessionPhase.idle,
      isSyncing: false,
    );
  }

  SessionState copyWith({
    String? roomId,
    List<Participant>? participants,
    SessionPhase? currentPhase,
    bool? isSyncing,
    SessionError? error,
    int? createdAt,
    bool clearError = false,
  }) {
    return SessionState(
      roomId: roomId ?? this.roomId,
      participants: participants ?? this.participants,
      currentPhase: currentPhase ?? this.currentPhase,
      isSyncing: isSyncing ?? this.isSyncing,
      error: clearError ? null : (error ?? this.error),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
