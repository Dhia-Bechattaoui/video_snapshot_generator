/// Result of a thumbnail generation or frame extraction operation.
class ThumbnailResult {
  /// Creates a [ThumbnailResult] for a successful operation.
  const ThumbnailResult.success({
    required this.path,
    required this.width,
    required this.height,
    required this.dataSize,
    this.format,
    this.timeMs,
  }) : errorMessage = null;

  /// Creates a [ThumbnailResult] for a failed operation.
  const ThumbnailResult.error({required this.errorMessage})
    : path = '',
      width = 0,
      height = 0,
      dataSize = 0,
      format = null,
      timeMs = null;

  /// The file path where the thumbnail was saved (empty if operation failed).
  final String path;

  /// The actual width of the generated thumbnail in pixels (0 if operation failed).
  final int width;

  /// The actual height of the generated thumbnail in pixels (0 if operation failed).
  final int height;

  /// The size of the thumbnail file in bytes (0 if operation failed).
  final int dataSize;

  /// The format of the generated thumbnail (null if operation failed).
  final String? format;

  /// The time position in milliseconds where the frame was extracted (null if operation failed).
  final int? timeMs;

  /// Error message if the operation failed (null if operation succeeded).
  final String? errorMessage;

  /// Whether the operation was successful.
  bool get success => errorMessage == null;

  /// Creates a copy of this [ThumbnailResult] with the given fields replaced.
  ThumbnailResult copyWith({
    String? path,
    int? width,
    int? height,
    int? dataSize,
    String? format,
    int? timeMs,
    String? errorMessage,
  }) {
    if (errorMessage != null) {
      return ThumbnailResult.error(errorMessage: errorMessage);
    }
    return ThumbnailResult.success(
      path: path ?? this.path,
      width: width ?? this.width,
      height: height ?? this.height,
      dataSize: dataSize ?? this.dataSize,
      format: format ?? this.format,
      timeMs: timeMs ?? this.timeMs,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'ThumbnailResult.success(path: $path, width: $width, height: $height, '
          'dataSize: $dataSize, format: $format, timeMs: $timeMs)';
    } else {
      return 'ThumbnailResult.error(errorMessage: $errorMessage)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThumbnailResult &&
        other.path == path &&
        other.width == width &&
        other.height == height &&
        other.dataSize == dataSize &&
        other.format == format &&
        other.timeMs == timeMs &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      path,
      width,
      height,
      dataSize,
      format,
      timeMs,
      errorMessage,
    );
  }
}
