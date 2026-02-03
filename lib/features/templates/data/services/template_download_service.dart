import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../domain/models/template.dart';

/// Service for downloading and caching video templates from YouTube
class TemplateDownloadService {
  final _yt = YoutubeExplode();

  /// Downloads a template video from YouTube and caches it locally
  /// Returns the path to the cached video file
  Future<File> downloadTemplate(Template template) async {
    if (template.youtubeId == null) {
      throw Exception('Template ${template.id} does not have a YouTube ID');
    }

    // Check if already cached
    final cachedFile = await _getCachedFile(template.id);
    if (await cachedFile.exists()) {
      return cachedFile;
    }

    // Download from YouTube
    final manifest = await _yt.videos.streamsClient.getManifest(
      template.youtubeId!,
    );
    final streamInfo = manifest.muxed.withHighestBitrate();

    // Create cache directory
    await cachedFile.parent.create(recursive: true);

    // Download video
    final stream = _yt.videos.streamsClient.get(streamInfo);
    final output = cachedFile.openWrite();

    await stream.pipe(output);
    await output.flush();
    await output.close();

    return cachedFile;
  }

  /// Downloads template with progress callback
  Future<File> downloadTemplateWithProgress(
    Template template,
    void Function(double progress) onProgress,
  ) async {
    if (template.youtubeId == null) {
      throw Exception('Template ${template.id} does not have a YouTube ID');
    }

    final cachedFile = await _getCachedFile(template.id);
    if (await cachedFile.exists()) {
      onProgress(1.0);
      return cachedFile;
    }

    final manifest = await _yt.videos.streamsClient.getManifest(
      template.youtubeId!,
    );
    final streamInfo = manifest.muxed.withHighestBitrate();

    await cachedFile.parent.create(recursive: true);

    final stream = _yt.videos.streamsClient.get(streamInfo);
    final output = cachedFile.openWrite();

    final totalBytes = streamInfo.size.totalBytes;
    var downloadedBytes = 0;

    await for (final chunk in stream) {
      output.add(chunk);
      downloadedBytes += chunk.length;
      onProgress(downloadedBytes / totalBytes);
    }

    await output.flush();
    await output.close();

    return cachedFile;
  }

  /// Gets the cached file path for a template
  Future<File> _getCachedFile(String templateId) async {
    final cacheDir = await getApplicationDocumentsDirectory();
    return File('${cacheDir.path}/templates/$templateId.mp4');
  }

  /// Checks if a template is already cached
  Future<bool> isTemplateCached(String templateId) async {
    final file = await _getCachedFile(templateId);
    return file.exists();
  }

  /// Gets the cache size for a template in bytes
  Future<int?> getCachedTemplateSize(String templateId) async {
    final file = await _getCachedFile(templateId);
    if (await file.exists()) {
      return file.length();
    }
    return null;
  }

  /// Clears the cached template
  Future<void> clearCachedTemplate(String templateId) async {
    final file = await _getCachedFile(templateId);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Clears all cached templates
  Future<void> clearAllCachedTemplates() async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final templatesDir = Directory('${cacheDir.path}/templates');
    if (await templatesDir.exists()) {
      await templatesDir.delete(recursive: true);
    }
  }

  void dispose() {
    _yt.close();
  }
}
