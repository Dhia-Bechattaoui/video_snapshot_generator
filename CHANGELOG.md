# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2024-12-19

### Fixed
- **CRITICAL**: Fixed `MissingPluginException` by properly converting package to Flutter plugin structure
- Moved native Android and iOS implementations from example app to plugin level
- Native implementations are now automatically registered when the package is added to any Flutter app
- Removed duplicate native code from example app that was causing confusion
- Enhanced iOS multiple thumbnail generation with better error handling and resource management

### Changed
- **BREAKING**: Removed dependency on `cross_platform_video_thumbnails` - package is now standalone
- Converted package from pure Dart package to proper Flutter plugin
- Implemented direct method channel communication (removed wrapper dependency)
- Changed method channel name from `cross_platform_video_thumbnails` to `video_snapshot_generator`
- Native implementations now properly registered via plugin system instead of requiring manual setup
- Example app now relies on plugin registration instead of custom native implementations
- Platform support updated: Android and iOS only (web/desktop support may be added in future)

### Technical Details
- Created `android/src/main/kotlin/com/video_snapshot_generator/VideoSnapshotGeneratorPlugin.kt` with proper `FlutterPlugin` implementation
- Created `ios/Classes/VideoSnapshotGeneratorPlugin.swift` with proper `FlutterPlugin` implementation
- Added plugin configuration to `pubspec.yaml` with platform-specific plugin classes
- Added `android/build.gradle` and `ios/video_snapshot_generator.podspec` for proper plugin structure
- Replaced `cross_platform_video_thumbnails` wrapper with direct `MethodChannel` implementation
- Example app `MainActivity.kt` and `AppDelegate.swift` now clean and rely on automatic plugin registration
- Improved iOS thumbnail generation with asynchronous asset loading and resource management

## [0.1.0] - 2024-12-19

### Added
- **Automatic permission handling**: The package now automatically requests and handles permissions on Android and iOS
- **Automatic storage handling**: Thumbnails are automatically saved to platform-appropriate directories with accessible file paths
- **Enhanced example app**: Complete demo showcasing all package features including:
  - Real video file picker
  - Multiple output format selection (JPEG, PNG, WebP)
  - Display of generated thumbnail images
  - Platform capability checking
  - Multiple frame extraction with horizontal scrollable display
  - Comprehensive error handling

### Changed
- **BREAKING CHANGE**: `maintainAspectRatio` now defaults to `false` to use exact dimensions as specified
- Improved error messages for `MissingPluginException` with troubleshooting guidance
- Enhanced platform capability checking with fallback defaults

### Fixed
- Fixed `MissingPluginException` on Android by adding native MethodChannel implementation in MainActivity
- Fixed `MissingPluginException` on iOS by adding native MethodChannel implementation in AppDelegate
- Fixed multiple frame extraction to display all frames instead of just the first one
- Fixed layout overflow issues in example app with scrollable content

### Technical Details
- Added `permission_handler` and `path_provider` dependencies for automatic permission and storage handling
- Implemented `PermissionHandler` class for cross-platform permission management
- Implemented `StorageHandler` class for automatic file storage with platform-specific directories
- Native Android implementation using `MediaMetadataRetriever` for video thumbnail generation
- Native iOS implementation using `AVFoundation` and `AVAssetImageGenerator` for video thumbnail generation
- Example app now demonstrates all README features including format selection, platform capabilities, and multiple frame display

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
