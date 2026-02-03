import '../repositories/session_repository.dart';
import '../engine/domain/models/session_state.dart';
import '../engine/domain/models/session_enums.dart';
import '../engine/data/handlers/websocket_session_handler.dart';

/// WebSocket implementation of SessionRepository
class WebSocketSessionRepository implements SessionRepository {
  final WebSocketSessionHandler _handler;

  WebSocketSessionRepository(this._handler);

  @override
  Stream<SessionState> get sessionStateStream => _handler.sessionStateStream;

  @override
  Stream<SessionEventType> get eventStream => _handler.eventStream;

  @override
  Future<void> connect(String serverUrl, String authToken) async {
    await _handler.connect(serverUrl, authToken);
  }

  @override
  Future<void> disconnect() async {
    // Cannot dispose singleton handler
  }

  @override
  Future<void> leaveRoom() async {
    _handler.leaveRoom('');
  }

  @override
  Future<void> deleteAccount() async {
    _handler.deleteAccount();
  }

  @override
  Future<void> dispose() async {
    // Cannot dispose singleton handler
  }
}
