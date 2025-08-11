# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2024-12-19

### Changed
- **BREAKING CHANGE**: Replaced `video_thumbnail` dependency with `cross_platform_video_thumbnails`
- **BREAKING CHANGE**: Removed direct dependencies on `path_provider` and `permission_handler`
- Updated package to use cross-platform implementation for full platform support
- **BREAKING CHANGE**: Removed custom output path support - storage is now handled automatically

### Added
- **Full cross-platform support**: Android, iOS, Web, Windows, macOS, Linux
- **WASM compatibility**: Full support for Flutter web applications
- Automatic platform detection and initialization
- Cross-platform thumbnail generation with native implementations
- **Platform capability checking methods**:
  - `isVideoFormatSupported()` - Check if video format is supported
  - `getSupportedVideoFormats()` - Get list of supported video formats
  - `getSupportedOutputFormats()` - Get list of supported output formats
  - `isPlatformAvailable()` - Check if platform is available

### Removed
- Direct `dart:io` imports (replaced with platform-agnostic approach)
- Platform-specific permission handling (now handled by cross-platform package)
- Direct file system operations (now handled by cross-platform package)
- **Custom output path support** - Storage is now handled automatically by the cross-platform package

### Technical Details
- Package now delegates all operations to `cross_platform_video_thumbnails`
- Uses conditional imports and platform-specific implementations
- Maintains backward compatibility with existing API structure
- All tests continue to pass with new implementation
- The `path` field in `ThumbnailResult` is maintained for compatibility but is empty

## [0.0.1] - 2024-12-19

### Added
- Initial release of video_snapshot_generator package
- Core functionality for generating video snapshots and thumbnails
- Support for multiple output formats (JPEG, PNG, WebP)
- Customizable thumbnail dimensions and quality settings
- Time-based thumbnail generation
- Cross-platform support (Android, iOS)
- Automatic permission handling for Android
- Comprehensive error handling
- Example application demonstrating package usage
- Integration tests for core functionality
- Unit tests for all public APIs
- Comprehensive documentation and README
- Support for generating multiple thumbnails at different time positions
- Custom output path support
- Efficient thumbnail generation using video_thumbnail package
- Platform-specific optimizations
- Detailed API documentation with examples
- MIT license for open source usage
- Flutter lints configuration for code quality
- Analysis options for static analysis
- Support for Flutter SDK 3.10.0+
- Support for Dart SDK 3.0.0+
- Support for Android API level 21+
- Support for iOS 11.0+

### Changed
- Package renamed from flutter_video_thumbnails to video_snapshot_generator
- Class renamed from VideoFrameExtractor to VideoSnapshotGenerator
- Method names updated to reflect thumbnail generation focus
- Documentation updated to reflect new package identity
