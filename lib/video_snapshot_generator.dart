/// A Flutter package for generating video thumbnails with custom dimensions
/// and quality settings.
///
/// This package provides a simple and efficient way to extract thumbnails
/// from video files in Flutter applications across multiple platforms.
///
/// ## Features
///
/// - Generate thumbnails from video files
/// - Customizable thumbnail dimensions (width and height)
/// - Quality control settings (1-100)
/// - Extract thumbnails at specific time positions
/// - Multiple output formats (JPEG, PNG, WebP)
/// - Cross-platform support (Android, iOS)
/// - Native implementations for optimal performance
/// - Automatic permission handling
/// - Efficient thumbnail generation
/// - Comprehensive error handling
///
/// ## Getting Started
///
/// ```dart
/// import 'package:video_snapshot_generator/video_snapshot_generator.dart';
///
/// // Generate a thumbnail with default settings
/// final result = await VideoSnapshotGenerator.generateThumbnail(
///   videoPath: '/path/to/video.mp4',
/// );
/// ```
///
/// ## Platform Support
///
/// - **Android**: Full support with storage permissions
/// - **iOS**: Full support, no additional setup required
/// - **Web**: Full support with WASM compatibility
/// - **Windows**: Full support, no additional setup required
/// - **macOS**: Full support, no additional setup required
/// - **Linux**: Full support, no additional setup required
///
/// For more information, see the [README](https://github.com/Dhia-Bechattaoui/video_snapshot_generator#readme).
// ignore_for_file: unnecessary_library_name
library video_snapshot_generator;

export 'src/exceptions/thumbnail_exception.dart';
export 'src/models/thumbnail_options.dart';
export 'src/models/thumbnail_result.dart';
export 'src/video_snapshot_generator_base.dart';
