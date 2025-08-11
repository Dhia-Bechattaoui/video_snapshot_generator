/// Exception thrown when thumbnail generation fails.
class ThumbnailException implements Exception {
  /// Creates a [ThumbnailException] with the given [message].
  const ThumbnailException(this.message);

  /// The error message describing what went wrong.
  final String message;

  @override
  String toString() => 'ThumbnailException: $message';
}
