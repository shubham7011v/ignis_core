import 'dart:async';
import '../../../../core/error/failure.dart';
import '../models/session_state.dart';
import '../models/session_enums.dart';

abstract class SessionHandler {
  Stream<SessionState> get sessionStateStream;
  Stream<SessionEventType> get eventStream;
  Stream<Failure> get errorStream;

  // Optional: detailed getters if needed for specialized UI updates
  String? get activeEventActorId;
  SessionEventType get lastEventType;
  int get lastEventTimestamp;
  // UI Helper Properties (Generic)
  Map<String, String> get pNames;
  Map<String, bool> get typingStatus;
  SessionState get currentState;

  Stream<Map<String, dynamic>> get chatStream;

  void sendChatMessage(String message);
  void sendEmojiMessage(String emojiId);
  void setTypingStatus(bool isTyping);

  /// Signal to server that client UI is ready
  void signalClientReady();

  void resetSession();

  void dispose();
}
