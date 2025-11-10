import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart' show Directory, File, Platform;

/// Handles automatic storage of thumbnail files.
class StorageHandler {
  StorageHandler._();

  /// Saves thumbnail data to a file and returns the file path.
  ///
  /// [data] - The thumbnail image data as bytes
  /// [format] - The format string (JPEG, PNG, WebP)
  /// [videoPath] - The original video path (used for naming)
  /// [timeMs] - The time position in milliseconds (used for naming)
  ///
  /// Returns the path to the saved file.
  static Future<String> saveThumbnail({
    required List<int> data,
    required String format,
    String? videoPath,
    int? timeMs,
  }) async {
    try {
      // Get the appropriate directory for the current platform
      final directory = await _getThumbnailDirectory();

      // Generate a unique filename
      final filename = _generateFilename(
        format: format,
        videoPath: videoPath,
        timeMs: timeMs,
      );

      // Create the full path
      final filePath = path.join(directory.path, filename);

      // Write the file
      final file = File(filePath);
      await file.writeAsBytes(data);

      return filePath;
    } catch (e) {
      // If storage fails, throw an exception
      throw Exception('Failed to save thumbnail: $e');
    }
  }

  /// Gets the appropriate directory for storing thumbnails based on the platform.
  static Future<Directory> _getThumbnailDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // For mobile platforms, use application documents directory
      final dir = await getApplicationDocumentsDirectory();
      final thumbnailDir = Directory(path.join(dir.path, 'thumbnails'));
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }
      return thumbnailDir;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop platforms, use application support directory
      final dir = await getApplicationSupportDirectory();
      final thumbnailDir = Directory(path.join(dir.path, 'thumbnails'));
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }
      return thumbnailDir;
    } else {
      // For web, use temporary directory
      final dir = await getTemporaryDirectory();
      final thumbnailDir = Directory(path.join(dir.path, 'thumbnails'));
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }
      return thumbnailDir;
    }
  }

  /// Generates a unique filename for the thumbnail.
  static String _generateFilename({
    required String format,
    String? videoPath,
    int? timeMs,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final videoName = videoPath != null
        ? path.basenameWithoutExtension(videoPath)
        : 'video';
    final timeSuffix = timeMs != null ? '_${timeMs}ms' : '';
    final extension = _getFileExtension(format);

    return '$videoName$timeSuffix$timestamp.$extension';
  }

  /// Gets the file extension for the given format.
  static String _getFileExtension(String format) {
    switch (format.toUpperCase()) {
      case 'JPEG':
      case 'JPG':
        return 'jpg';
      case 'PNG':
        return 'png';
      case 'WEBP':
        return 'webp';
      default:
        return 'jpg';
    }
  }
}
