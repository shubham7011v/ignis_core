import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
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

/// Service for orchestrating client-side FFmpeg video rendering
class ClientRenderService {
  /// Renders a wedding invitation video locally on the device
  /// [templateFile] The base template video file (already downloaded)
  /// [details] The wedding details to overlay
  /// [onProgress] Progress callback (0.0 to 1.0)
  Future<RenderResult> renderInvitation({
    required File templateFile,
    required WeddingDetails details,
    Duration? totalDuration,
    void Function(double progress)? onProgress,
  }) async {
    // 1. Validation
    if (!await templateFile.exists()) {
      return RenderResult.failure(
        'Template file not found at ${templateFile.path}',
      );
    }

    final outputDir = await getApplicationDocumentsDirectory();
    final rendersDir = Directory('${outputDir.path}/renders');
    if (!await rendersDir.exists()) {
      await rendersDir.create(recursive: true);
    }

    final outputPath =
        '${rendersDir.path}/invitation_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // 2. Build FFmpeg Filter Complex
    final filterComplex = _buildFilterComplex(details);

    final ffmpegCommand = [
      '-i',
      "'${templateFile.path}'",
      '-vf',
      "\"$filterComplex\"",
      '-c:a',
      'copy',
      '-y',
      "'$outputPath'",
    ].join(' ');

    try {
      final session = await FFmpegKit.executeAsync(
        ffmpegCommand,
        (session) async {
          final returnCode = await session.getReturnCode();
          if (ReturnCode.isSuccess(returnCode)) {
            // Success
          } else if (ReturnCode.isCancel(returnCode)) {
            // Cancelled
          } else {
            // Error
          }
        },
        (log) {
          // Log output
        },
        (statistics) {
          if (onProgress != null && totalDuration != null) {
            final totalMs = totalDuration.inMilliseconds;
            if (totalMs > 0) {
              final currentMs = statistics.getTime();
              if (currentMs > 0) {
                onProgress((currentMs / totalMs).clamp(0.0, 1.0));
              }
            }
          }
        },
      );

      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return RenderResult.success(outputPath);
      } else {
        final logs = await session.getAllLogsAsString();
        return RenderResult.failure('FFmpeg failed: $logs');
      }
    } catch (e) {
      return RenderResult.failure('Rendering error: ${e.toString()}');
    }
  }

  /// Constructs the FFmpeg filter string for overlays
  String _buildFilterComplex(WeddingDetails details) {
    // Escaping text for FFmpeg
    final bride = details.brideName.replaceAll("'", "\\'");
    final groom = details.groomName.replaceAll("'", "\\'");
    final date =
        '${details.weddingDate.day}/${details.weddingDate.month}/${details.weddingDate.year}';
    final venue = details.venue.replaceAll("'", "\\'");

    // Simple text overlays using drawtext filter
    // x=w/2:y=h/2 positions text in the center
    // We'll stack them with different offsets
    return [
      "drawtext=text='$bride & $groom':fontcolor=gold:fontsize=72:x=(w-text_w)/2:y=(h-text_h)/2-100:enable='between(t,2,28)'",
      "drawtext=text='WEDDING INVITATION':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,1,29)'",
      "drawtext=text='$date':fontcolor=white:fontsize=36:x=(w-text_w)/2:y=(h-text_h)/2+100:enable='between(t,3,27)'",
      "drawtext=text='$venue':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2+200:enable='between(t,4,26)'",
    ].join(',');
  }

  /// Cancels all active rendering sessions
  Future<void> cancelAll() async {
    await FFmpegKit.cancel();
  }
}
