import 'dart:io';
import '../../domain/entities/wedding_details.dart';

/// Result status of a render operation
enum RenderStatus { initial, rendering, success, failure }

/// Result of a render operation
class RenderResult {
  final RenderStatus status;
  final String? outputPath;
  final String? errorMessage;

  RenderResult({required this.status, this.outputPath, this.errorMessage});

  factory RenderResult.success(String path) =>
      RenderResult(status: RenderStatus.success, outputPath: path);
  factory RenderResult.failure(String message) =>
      RenderResult(status: RenderStatus.failure, errorMessage: message);
}

/// Service for orchestrating client-side video tasks (DEPRECATED)
/// Custom video rendering is now handled by the studio team manually.
class ClientRenderService {
  /// [DEPRECATED] Rendering is now handled by the studio.
  Future<RenderResult> renderInvitation({
    required File templateFile,
    required WeddingDetails details,
    Duration? totalDuration,
    void Function(double progress)? onProgress,
  }) async {
    return RenderResult.failure(
      'Client-side rendering is deprecated. Videos are now manually crafted by the studio.',
    );
  }

  /// Cancels all active rendering sessions
  Future<void> cancelAll() async {
    // No-op as FFmpeg is no longer used
  }
}
