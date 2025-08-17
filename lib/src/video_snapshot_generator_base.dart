import 'package:cross_platform_video_thumbnails/cross_platform_video_thumbnails.dart'
    as cross_platform;

import 'exceptions/thumbnail_exception.dart';
import 'models/thumbnail_options.dart';
import 'models/thumbnail_result.dart';

/// A class for generating video snapshots and thumbnails.
///
/// This class provides methods to generate thumbnails from video files at specific
/// time positions with customizable dimensions and quality settings.
///
/// This implementation uses cross_platform_video_thumbnails for full platform support
/// including Android, iOS, Web, Windows, macOS, and Linux with WASM compatibility.
class VideoSnapshotGenerator {
  VideoSnapshotGenerator._();

  /// Generates a thumbnail from a video file at the specified time position.
  ///
  /// [videoPath] - The path to the video file
  /// [options] - Optional configuration for thumbnail generation
  ///
  /// Returns a [ThumbnailResult] containing the result of the operation.
  static Future<ThumbnailResult> generateThumbnail({
    required String videoPath,
    ThumbnailOptions? options,
  }) async {
    final opts = options?.copyWith(videoPath: videoPath) ??
        ThumbnailOptions(videoPath: videoPath);

    try {
      // Initialize the cross-platform package
      await cross_platform.CrossPlatformVideoThumbnails.initialize();

      // Convert our options to cross-platform format
      final crossPlatformOptions = _convertOptions(opts);

      // Delegate to cross_platform_video_thumbnails
      final result =
          await cross_platform.CrossPlatformVideoThumbnails.generateThumbnail(
        videoPath,
        crossPlatformOptions,
      );

      // Convert the result to our ThumbnailResult format
      return ThumbnailResult.success(
        path: '', // cross-platform package returns data, not path
        width: result.width,
        height: result.height,
        dataSize: result.size,
        format: _convertFormatBack(result.format),
        timeMs: (result.timePosition * 1000)
            .round(), // Convert seconds to milliseconds
      );
    } catch (e) {
      if (e is ThumbnailException) {
        rethrow;
      }
      throw ThumbnailException('Error generating thumbnail: ${e.toString()}');
    }
  }

  /// Generates multiple thumbnails from a video file at different time positions.
  ///
  /// [videoPath] - The path to the video file
  /// [timePositions] - List of time positions in milliseconds
  /// [options] - Optional configuration for thumbnail generation
  ///
  /// Returns a list of [ThumbnailResult] containing the results of the operations.
  static Future<List<ThumbnailResult>> generateMultipleThumbnails({
    required String videoPath,
    required List<int> timePositions,
    ThumbnailOptions? options,
  }) async {
    final results = <ThumbnailResult>[];

    for (final timeMs in timePositions) {
      final frameOptions = options?.copyWith(
            videoPath: videoPath,
            timeMs: timeMs,
          ) ??
          ThumbnailOptions(
            videoPath: videoPath,
            timeMs: timeMs,
          );

      try {
        final result = await generateThumbnail(
          videoPath: videoPath,
          options: frameOptions,
        );
        results.add(result);
      } catch (e) {
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
      ThumbnailOptions options) {
    return generateThumbnail(
      videoPath: options.videoPath,
      options: options,
    );
  }

  /// Converts our ThumbnailOptions to cross_platform_video_thumbnails format
  static cross_platform.ThumbnailOptions _convertOptions(
      ThumbnailOptions options) {
    return cross_platform.ThumbnailOptions(
      timePosition: options.timeMs / 1000.0, // Convert milliseconds to seconds
      width: options.width,
      height: options.height,
      quality: options.quality / 100.0, // Convert 1-100 to 0.0-1.0
      format: _convertFormat(options.format),
      maintainAspectRatio: true,
    );
  }

  /// Converts our ThumbnailFormat to cross_platform_video_thumbnails format
  static cross_platform.ThumbnailFormat _convertFormat(ThumbnailFormat format) {
    switch (format) {
      case ThumbnailFormat.jpeg:
        return cross_platform.ThumbnailFormat.jpeg;
      case ThumbnailFormat.png:
        return cross_platform.ThumbnailFormat.png;
      case ThumbnailFormat.webP:
        return cross_platform.ThumbnailFormat.webp;
    }
    // This should never be reached as all enum values are covered
    // ignore: dead_code
    throw ArgumentError('Unsupported format: $format');
  }

  /// Converts cross_platform_video_thumbnails format back to our format
  static String _convertFormatBack(cross_platform.ThumbnailFormat format) {
    switch (format) {
      case cross_platform.ThumbnailFormat.jpeg:
        return 'JPEG';
      case cross_platform.ThumbnailFormat.png:
        return 'PNG';
      case cross_platform.ThumbnailFormat.webp:
        return 'WebP';
    }
    // This should never be reached as all enum values are covered
    // ignore: dead_code
    throw ArgumentError('Unsupported format: $format');
  }

  /// Check if the platform supports the given video format
  static Future<bool> isVideoFormatSupported(String videoPath) async {
    await cross_platform.CrossPlatformVideoThumbnails.initialize();
    return cross_platform.CrossPlatformVideoThumbnails.isVideoFormatSupported(
        videoPath);
  }

  /// Get the list of supported video formats for the current platform
  static List<String> getSupportedVideoFormats() {
    return cross_platform.CrossPlatformVideoThumbnails
        .getSupportedVideoFormats();
  }

  /// Check if the current platform is available and ready to use
  static Future<bool> isPlatformAvailable() async {
    await cross_platform.CrossPlatformVideoThumbnails.initialize();
    return cross_platform.CrossPlatformVideoThumbnails.isPlatformAvailable();
  }

  /// Get the list of supported output formats for the current platform
  static List<ThumbnailFormat> getSupportedOutputFormats() {
    final crossPlatformFormats =
        cross_platform.CrossPlatformVideoThumbnails.getSupportedOutputFormats();
    return crossPlatformFormats.map(_convertFormatFromCrossPlatform).toList();
  }

  /// Converts cross_platform_video_thumbnails format to our format
  static ThumbnailFormat _convertFormatFromCrossPlatform(
      cross_platform.ThumbnailFormat format) {
    switch (format) {
      case cross_platform.ThumbnailFormat.jpeg:
        return ThumbnailFormat.jpeg;
      case cross_platform.ThumbnailFormat.png:
        return ThumbnailFormat.png;
      case cross_platform.ThumbnailFormat.webp:
        return ThumbnailFormat.webP;
    }
    // This should never be reached as all enum values are covered
    // ignore: dead_code
    throw ArgumentError('Unsupported format: $format');
  }
}
