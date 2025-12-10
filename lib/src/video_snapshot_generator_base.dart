import 'package:flutter/services.dart';

import 'exceptions/thumbnail_exception.dart';
import 'models/thumbnail_options.dart';
import 'models/thumbnail_result.dart';
import 'permission_handler.dart';
import 'storage_handler.dart';

/// A class for generating video snapshots and thumbnails.
///
/// This class provides methods to generate thumbnails from video files at
/// specific time positions with customizable dimensions and quality settings.
///
/// This implementation provides full platform support including Android and
/// iOS via native plugins, with direct method channel communication.
class VideoSnapshotGenerator {
  VideoSnapshotGenerator._();

  static const MethodChannel _channel = MethodChannel(
    'video_snapshot_generator',
  );

  /// Generates a thumbnail from a video file at the specified time position.
  ///
  /// [videoPath] - The path to the video file
  /// [options] - Optional configuration for thumbnail generation
  ///
  /// Returns a [ThumbnailResult] containing the result of the operation.
  static Future<ThumbnailResult> generateThumbnail({
    required final String videoPath,
    final ThumbnailOptions? options,
  }) async {
    final opts =
        options?.copyWith(videoPath: videoPath) ??
        ThumbnailOptions(videoPath: videoPath);

    try {
      // Automatically request permissions if needed
      await PermissionHandler.requestPermissions();

      // Prepare method arguments
      final arguments = <String, dynamic>{
        'videoPath': videoPath,
        'timePosition': opts.timeMs / 1000.0, // Convert ms to seconds
        'width': opts.width,
        'height': opts.height,
        'quality': opts.quality / 100.0, // Convert 1-100 to 0.0-1.0
        'format': _formatToString(opts.format),
        'maintainAspectRatio': false,
      };

      // Call native method channel
      final result = await _channel
          .invokeMethod<Map<Object?, Object?>>('generateThumbnail', arguments)
          .catchError((final Object e) {
            // Handle MissingPluginException specifically
            if (e is PlatformException ||
                e.toString().contains('MissingPluginException') ||
                e.toString().contains('No implementation found')) {
              throw ThumbnailException(
                'Video thumbnail plugin is not available. '
                'Please ensure:\n'
                '1. The app has been rebuilt after adding the plugin\n'
                '2. The plugin is properly registered in your platform '
                'configuration\n'
                '3. You are running on a supported platform\n'
                'Original error: $e',
              );
            }
            throw e is Exception ? e : Exception(e.toString());
          });

      if (result == null) {
        throw const ThumbnailException(
          'Failed to generate thumbnail: null result',
        );
      }

      // Extract result data
      final data = result['data'] as Uint8List?;
      final width = result['width'] as int? ?? 0;
      final height = result['height'] as int? ?? 0;
      final format = result['format'] as String? ?? 'jpeg';
      final timePosition = result['timePosition'] as double? ?? 0.0;

      if (data == null) {
        throw const ThumbnailException('Failed to generate thumbnail: no data');
      }

      // Save the thumbnail data to a file automatically
      final savedPath = await StorageHandler.saveThumbnail(
        data: data,
        format: format.toUpperCase(),
        videoPath: videoPath,
        timeMs: opts.timeMs,
      );

      // Return result (convert seconds to milliseconds)
      return ThumbnailResult.success(
        path: savedPath,
        width: width,
        height: height,
        dataSize: data.length,
        format: format.toUpperCase(),
        timeMs: (timePosition * 1000).round(),
      );
    } catch (e) {
      if (e is ThumbnailException) {
        rethrow;
      }
      throw ThumbnailException('Error generating thumbnail: $e');
    }
  }

  /// Generates multiple thumbnails from a video file at different time
  /// positions.
  ///
  /// [videoPath] - The path to the video file
  /// [timePositions] - List of time positions in milliseconds
  /// [options] - Optional configuration for thumbnail generation
  ///
  /// Returns a list of [ThumbnailResult] containing the results of the
  /// operations.
  static Future<List<ThumbnailResult>> generateMultipleThumbnails({
    required final String videoPath,
    required final List<int> timePositions,
    final ThumbnailOptions? options,
  }) async {
    final results = <ThumbnailResult>[];

    for (final timeMs in timePositions) {
      final frameOptions =
          options?.copyWith(videoPath: videoPath, timeMs: timeMs) ??
          ThumbnailOptions(videoPath: videoPath, timeMs: timeMs);

      try {
        final result = await generateThumbnail(
          videoPath: videoPath,
          options: frameOptions,
        );
        results.add(result);
      } on Exception catch (e) {
        // Continue with other thumbnails even if one fails
        // Note: In production, consider using a proper logging framework
        // ignore: avoid_print
        print('Failed to generate thumbnail at ${timeMs}ms: $e');
      }
    }

    return results;
  }

  /// Generates a thumbnail with the specified options.
  ///
  /// [options] - The thumbnail generation options
  ///
  /// Returns a [ThumbnailResult] containing the result of the operation.
  static Future<ThumbnailResult> generateThumbnailFromOptions(
    final ThumbnailOptions options,
  ) => generateThumbnail(videoPath: options.videoPath, options: options);

  /// Check if the platform supports the given video format
  static Future<bool> isVideoFormatSupported(final String videoPath) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isVideoFormatSupported',
        <String, dynamic>{'videoPath': videoPath},
      );
      return result ?? false;
    } on Exception {
      return false;
    }
  }

  /// Get the list of supported video formats for the current platform
  static List<String> getSupportedVideoFormats() =>
      // Return common video formats supported by most platforms
      const ['mp4', 'mov', '3gp', 'avi', 'mkv', 'webm'];

  /// Check if the current platform is available and ready to use
  static Future<bool> isPlatformAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isPlatformAvailable');
      return result ?? false;
    } on Exception {
      return false;
    }
  }

  /// Get the list of supported output formats for the current platform
  static List<ThumbnailFormat> getSupportedOutputFormats() => const [
    ThumbnailFormat.jpeg,
    ThumbnailFormat.png,
    ThumbnailFormat.webP,
  ];

  /// Converts ThumbnailFormat to string for method channel
  static String _formatToString(final ThumbnailFormat format) {
    switch (format) {
      case ThumbnailFormat.jpeg:
        return 'jpeg';
      case ThumbnailFormat.png:
        return 'png';
      case ThumbnailFormat.webP:
        return 'webp';
    }
  }
}
