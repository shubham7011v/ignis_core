import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../utils/app_logger.dart';
import '../../models/system_status.dart';
import '../../config/api_config.dart';
import '../../../features/auth/auth.dart';

class SystemStatusService {
  final AuthBloc _authBloc;

  final _statusController = StreamController<SystemStatus>.broadcast();
  Stream<SystemStatus> get statusStream => _statusController.stream;

  SystemStatus _currentStatus = SystemStatus.healthy();
  SystemStatus get currentStatus => _currentStatus;

  StreamSubscription? _sessionSub;
  StreamSubscription? _authSub;
  Timer? _connectivityTimer;
  Timer? _syncTimeout;
  int _updateVersion = 0;

  // Backoff Configuration
  Duration _currentPingInterval = const Duration(seconds: 10);
  int _consecutiveFailures = 0;

  SystemStatusService({required AuthBloc authBloc}) : _authBloc = authBloc {
    _init();
  }

  void _init() {
    _authSub = _authBloc.stream.listen((_) => _updateStatus());

    // Start dynamic ping loop
    _scheduleNextPing();
    _updateStatus();
  }

  void _scheduleNextPing() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer(_currentPingInterval, _performPeriodicCheck);
  }

  Future<void> _performPeriodicCheck() async {
    await _updateStatus();
    _scheduleNextPing();
  }

  Future<void> refresh() async {
    await _updateStatus();
    _scheduleNextPing(); // Reset timer if manually refreshed
  }

  Future<void> _updateStatus() async {
    final version = ++_updateVersion;

    // 1. Connectivity Check (Async)
    final hasInternet = await _checkInternet();

    // If a newer update has started, abort this one to prevent UI "flicker" or stale states
    if (version != _updateVersion) return;

    // Update Backoff Logic
    if (hasInternet) {
      _consecutiveFailures = 0;
      _currentPingInterval = const Duration(seconds: 10);
    } else {
      if (_consecutiveFailures == 0) {
        // First failure: Retry quickly to confirm it's not a blip
        _currentPingInterval = const Duration(seconds: 2);
      } else {
        // Exponential backoff
        final nextMs = (_currentPingInterval.inMilliseconds * 1.5).round();
        _currentPingInterval = Duration(
          milliseconds: nextMs > 60000 ? 60000 : nextMs,
        );
      }
      _consecutiveFailures++;
      AppLogger.networkEvent(
        'Connection lost. Next ping in ${_currentPingInterval.inSeconds}s',
      );
    }

    // Fetch latest states AFTER completing the async internet check
    final authState = _authBloc.state;

    if (!hasInternet) {
      _emit(SystemStatus.noInternet());
      return;
    }

    // 2. Auth Status
    if (authState is AuthLoading || authState is AuthInitial) {
      _emit(SystemStatus.syncing());
      return;
    }

    if (authState is AuthFailure) {
      _emit(SystemStatus.authIssue());
      return;
    }

    // 3. Handle Backend Server Status (Real Ping)
    final serverStatus = await _checkServerHealth();

    if (serverStatus == 503) {
      _emit(SystemStatus.maintenance());
      return;
    }

    if (serverStatus != 200) {
      _emit(SystemStatus.serverDown());
      return;
    }

    _emit(SystemStatus.healthy());
  }

  /// Returns HTTP status code of the health endpoint.
  /// Returns 0 if connection fails entirely (timeout/network error).
  Future<int> _checkServerHealth() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/health');
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 5)); // Short timeout for pings

      return response.statusCode;
    } catch (e) {
      AppLogger.warning('Server Health Check Failed: $e');
      return 0;
    }
  }

  Future<bool> _checkInternet() async {
    try {
      // Use a short timeout to prevent long DNS hangs that pin the UI to "Initializing..."
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _emit(SystemStatus status) {
    if (_currentStatus.type == status.type) return;

    // Manage Syncing Timeout
    if (status.type == SystemStatusType.syncing) {
      _syncTimeout ??= Timer(const Duration(seconds: 20), () {
        // If we are still syncing after 20 seconds, force an update to show real bottleneck
        _syncTimeout = null;
        _handleSyncTimeout();
      });
    } else {
      _syncTimeout?.cancel();
      _syncTimeout = null;
    }

    _currentStatus = status;
    _statusController.add(status);
  }

  void _handleSyncTimeout() {
    final authState = _authBloc.state;

    if (authState is AuthLoading || authState is AuthInitial) {
      _emit(SystemStatus.authIssue()); // Assume auth is stuck
    }
  }

  void dispose() {
    _sessionSub?.cancel();
    _authSub?.cancel();
    _connectivityTimer?.cancel();
    _statusController.close();
  }
}
