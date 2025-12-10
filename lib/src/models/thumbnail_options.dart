import 'package:flutter/foundation.dart';

/// Configuration options for video thumbnail generation.
@immutable
class ThumbnailOptions {
  /// Creates [ThumbnailOptions] with the given parameters.
  const ThumbnailOptions({
    required this.videoPath,
    this.width = 320,
    this.height = 240,
    this.quality = 75,
    this.timeMs = 0,
    this.format = ThumbnailFormat.jpeg,
  });

  /// The path to the video file.
  final String videoPath;

  /// The width of the generated thumbnail in pixels.
  /// Defaults to 320.
  final int width;

  /// The height of the generated thumbnail in pixels.
  /// Defaults to 240.
  final int height;

  /// The quality of the generated thumbnail (1-100).
  /// Defaults to 75.
  final int quality;

  /// The time position in milliseconds to extract the thumbnail from.
  /// Defaults to 0 (beginning of video).
  final int timeMs;

  /// The format of the generated thumbnail.
  /// Defaults to [ThumbnailFormat.jpeg].
  final ThumbnailFormat format;

  /// Creates a copy of this [ThumbnailOptions] with the given fields replaced.
  ThumbnailOptions copyWith({
    final String? videoPath,
    final int? width,
    final int? height,
    final int? quality,
    final int? timeMs,
    final ThumbnailFormat? format,
  }) => ThumbnailOptions(
    videoPath: videoPath ?? this.videoPath,
    width: width ?? this.width,
    height: height ?? this.height,
    quality: quality ?? this.quality,
    timeMs: timeMs ?? this.timeMs,
    format: format ?? this.format,
  );

  @override
  String toString() =>
      'ThumbnailOptions(videoPath: $videoPath, width: $width, height: $height, '
      'quality: $quality, timeMs: $timeMs, format: $format)';

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ThumbnailOptions &&
        other.videoPath == videoPath &&
        other.width == width &&
        other.height == height &&
        other.quality == quality &&
        other.timeMs == timeMs &&
        other.format == format;
  }

  @override
  int get hashCode =>
      Object.hash(videoPath, width, height, quality, timeMs, format);
}

/// Supported thumbnail image formats.
///
/// These correspond to the video_thumbnail package's ImageFormat enum.
enum ThumbnailFormat {
  /// JPEG format
  jpeg,

  /// PNG format
  png,

  /// WebP format
  webP,
}
