import 'websocket_handler_base.dart';

/// Mixin that handles session action methods for WebSocket handler.
mixin WebSocketSessionActionsMixin on WebSocketHandlerBase {
  /// Leave the current room/session
  void leaveRoom(String roomCode) {
    sendMessage({'type': 'LEAVE_ROOM'});
  }
}
