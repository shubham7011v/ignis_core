import 'package:equatable/equatable.dart';
import '../../../../core/engine/engine.dart' as engine;
import '../../../../core/error/failure.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

// -- Action Events --
class SessionResetRequested extends SessionEvent {
  const SessionResetRequested();
}

class SessionHandlerSwapped extends SessionEvent {
  final engine.SessionHandler newHandler;
  const SessionHandlerSwapped(this.newHandler);

  @override
  List<Object?> get props => [newHandler];
}

// -- Engine Update Events --

class EngineStateUpdated extends SessionEvent {
  final engine.SessionState state;
  const EngineStateUpdated(this.state);

  @override
  List<Object?> get props => [state];
}

class EngineEventReceived extends SessionEvent {
  final engine.SessionEventType type;
  final String? actorId;

  const EngineEventReceived(this.type, this.actorId);

  @override
  List<Object?> get props => [type, actorId];
}

class HandlerSyncRequested extends SessionEvent {
  const HandlerSyncRequested();
}

// -- Error Events --
class SessionErrorOccurred extends SessionEvent {
  final Failure error;
  const SessionErrorOccurred(this.error);

  @override
  List<Object?> get props => [error];
}

class SessionErrorCleared extends SessionEvent {
  const SessionErrorCleared();
}

// -- Chat Events --

class SendChatMessage extends SessionEvent {
  final String message;
  const SendChatMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class SendEmojiMessage extends SessionEvent {
  final String emojiId;
  const SendEmojiMessage(this.emojiId);

  @override
  List<Object?> get props => [emojiId];
}

class ChatStreamUpdated extends SessionEvent {
  final Map<String, dynamic> message;
  const ChatStreamUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class SendTypingStatus extends SessionEvent {
  final bool isTyping;
  const SendTypingStatus(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

class TypingStatusChanged extends SessionEvent {
  final String senderId;
  final bool isTyping;
  const TypingStatusChanged(this.senderId, this.isTyping);

  @override
  List<Object?> get props => [senderId, isTyping];
}
