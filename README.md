# video_snapshot_generator

A Flutter package for generating video snapshots and thumbnails with custom dimensions and quality settings. This package provides a simple and efficient way to generate thumbnails from video files in Flutter applications across all platforms.

<img src="assets/example.gif" width="300" alt="Example GIF showing video snapshot generator in action" />

## Features

- 🎬 Extract frames from video files at specific time positions
- 📏 Customizable frame dimensions (width and height)
- 🎨 Quality control settings (1-100)
- ⏰ Extract frames at specific time positions
- 🖼️ Multiple output formats (JPEG, PNG, WebP)
- 🌐 **Cross-platform support (Android, iOS)**
- 🚀 **Native implementations for optimal performance**
- 🔒 Automatic permission handling
- ⚡ Efficient frame extraction
- 🧪 Comprehensive error handling
- 🔄 Extract multiple frames at different time positions
- 📁 **Automatic storage handling** (no custom output paths needed)
- 🎯 Precise time-based extraction

## Getting Started

### Installation

Add this dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  video_snapshot_generator: ^0.1.1
```

Then run:

```bash
flutter pub get
```

### Platform Setup

**Important**: This package is a Flutter plugin with native implementations. After adding the package to your project, rebuild your app to ensure the native code is properly linked:

```bash
flutter clean
flutter pub get
flutter build ios  # or flutter build apk / flutter build appbundle for Android
```

#### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

For Android 13+ (API level 33+), you may also need:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
```

The native Android implementation is automatically registered via the Flutter plugin system - no manual setup required.

#### iOS

No additional setup required for iOS. The plugin automatically registers native implementations via the Flutter plugin system.

**Note**: After adding the package, rebuild your app (`flutter clean && flutter build ios`) to ensure the native code is properly linked.

#### Web, Windows, macOS, Linux

Currently, this package supports Android and iOS platforms. Desktop and web support may be added in future versions.

## Usage

### Basic Usage

```dart
import 'package:video_snapshot_generator/video_snapshot_generator.dart';

// Generate a thumbnail with default settings
final result = await VideoSnapshotGenerator.generateThumbnail(
  videoPath: '/path/to/video.mp4',
);

print('Thumbnail generated successfully!');
print('Dimensions: ${result.width}x${result.height}');
print('Data size: ${result.dataSize} bytes');
print('Format: ${result.format}');
print('Time position: ${result.timeMs}ms');
```

### Advanced Usage

```dart
import 'package:video_snapshot_generator/video_snapshot_generator.dart';

// Generate a thumbnail with custom settings
final result = await VideoSnapshotGenerator.generateThumbnail(
  videoPath: '/path/to/video.mp4',
  options: ThumbnailOptions(
    width: 640,
    height: 480,
    quality: 90,
    timeMs: 5000, // Generate at 5 seconds
    format: ThumbnailFormat.png,
  ),
);

// Extract multiple frames at different time positions
final results = await VideoSnapshotGenerator.generateMultipleThumbnails(
  videoPath: '/path/to/video.mp4',
  timePositions: [0, 5000, 10000, 15000], // 0s, 5s, 10s, 15s
  options: ThumbnailOptions(
    width: 320,
    height: 240,
    quality: 75,
  ),
);

// Generate thumbnail from options object
final options = ThumbnailOptions(
  videoPath: '/path/to/video.mp4',
  width: 640,
  height: 480,
  quality: 90,
  timeMs: 5000,
  format: ThumbnailFormat.png,
);
final result = await VideoSnapshotGenerator.generateThumbnailFromOptions(options);

// Check platform capabilities
final isSupported = await VideoSnapshotGenerator.isVideoFormatSupported('/path/to/video.mp4');
final supportedFormats = VideoSnapshotGenerator.getSupportedVideoFormats();
final supportedOutputFormats = VideoSnapshotGenerator.getSupportedOutputFormats();
final isAvailable = await VideoSnapshotGenerator.isPlatformAvailable();

print('Video format supported: $isSupported');
print('Supported video formats: $supportedFormats');
print('Supported output formats: $supportedOutputFormats');
print('Platform available: $isAvailable');
```

### ThumbnailOptions

The `ThumbnailOptions` class allows you to customize the frame extraction:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `int` | 320 | Width of the frame in pixels |
| `height` | `int` | 240 | Height of the frame in pixels |
| `quality` | `int` | 75 | Quality of the frame from 1-100 |
| `timeMs` | `int` | 0 | Time position in milliseconds to extract from |
| `format` | `ThumbnailFormat` | `ThumbnailFormat.jpeg` | Output format |

**Note**: Output storage is handled automatically by the cross-platform package. Custom output paths are not supported.

### ThumbnailResult

The `ThumbnailResult` class contains information about the extracted frame:

| Property | Type | Description |
|----------|------|-------------|
| `width` | `int` | Actual width of the extracted frame |
| `height` | `int` | Actual height of the extracted frame |
| `dataSize` | `int` | Size of the frame data in bytes |
| `format` | `String?` | Format of the extracted frame |
| `timeMs` | `int?` | Time position in milliseconds where the frame was extracted |
| `path` | `String` | **Note**: This field is maintained for compatibility but is empty as storage is handled automatically |

**Note**: The cross-platform package handles storage internally. The `path` field is empty as thumbnails are stored automatically.

### ThumbnailFormat

Supported output formats:

- `ThumbnailFormat.jpeg` - JPEG format (default)
- `ThumbnailFormat.png` - PNG format
- `ThumbnailFormat.webP` - WebP format

### Available Methods

The package provides several methods for thumbnail generation and platform capability checking:

#### `generateThumbnail()`
Generate a single thumbnail with optional custom settings:
```dart
final result = await VideoSnapshotGenerator.generateThumbnail(
  videoPath: '/path/to/video.mp4',
  options: ThumbnailOptions(width: 640, height: 480),
);
```

#### `generateMultipleThumbnails()`
Generate multiple thumbnails at different time positions:
```dart
final results = await VideoSnapshotGenerator.generateMultipleThumbnails(
  videoPath: '/path/to/video.mp4',
  timePositions: [0, 5000, 10000],
  options: ThumbnailOptions(width: 320, height: 240),
);
```

#### `generateThumbnailFromOptions()`
Generate a thumbnail using a pre-configured options object:
```dart
final options = ThumbnailOptions(
  videoPath: '/path/to/video.mp4',
  width: 640,
  height: 480,
  quality: 90,
  timeMs: 5000,
  format: ThumbnailFormat.png,
);
final result = await VideoSnapshotGenerator.generateThumbnailFromOptions(options);
```

### Platform Capability Checking

The package provides methods to check platform capabilities and supported formats:

#### `isVideoFormatSupported(String videoPath)`
Check if the current platform supports a specific video format:
```dart
final isSupported = await VideoSnapshotGenerator.isVideoFormatSupported('/path/to/video.mp4');
if (isSupported) {
  // Generate thumbnail
} else {
  // Handle unsupported format
}
```

#### `getSupportedVideoFormats()`
Get a list of video formats supported by the current platform:
```dart
final formats = VideoSnapshotGenerator.getSupportedVideoFormats();
// Returns: ['mp4', 'mov', 'avi', 'mkv', 'webm', ...]
```

#### `getSupportedOutputFormats()`
Get a list of output image formats supported by the current platform:
```dart
final outputFormats = VideoSnapshotGenerator.getSupportedOutputFormats();
// Returns: [ThumbnailFormat.jpeg, ThumbnailFormat.png, ThumbnailFormat.webP]
```

#### `isPlatformAvailable()`
Check if the current platform is available and ready to use:
```dart
final isAvailable = await VideoSnapshotGenerator.isPlatformAvailable();
if (isAvailable) {
  // Platform is ready for thumbnail generation
} else {
  // Platform not available
}
```

## Error Handling

The package throws `ThumbnailException` when frame extraction fails:

```dart
try {
  final result = await VideoSnapshotGenerator.generateThumbnail(
    videoPath: '/path/to/video.mp4',
  );
} on ThumbnailException catch (e) {
  print('Frame extraction failed: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

### Common Error Scenarios

- **File not found**: The specified video file doesn't exist
- **Permission denied**: Storage permissions are not granted
- **Invalid parameters**: Width, height, quality, or time values are out of range
- **Unsupported format**: The video format is not supported
- **Insufficient storage**: Not enough storage space for the frame
- **Plugin not registered**: If you see `MissingPluginException`, rebuild your app after adding the package

### Troubleshooting

**Issue: `MissingPluginException` or "No implementation found"**
- Solution: Rebuild your app after adding the package (`flutter clean && flutter build`)
- Ensure you're using version `^0.1.1` or later which includes proper plugin registration

**Issue: Multiple thumbnail generation fails on iOS**
- Solution: The plugin now includes improved error handling and resource management for concurrent thumbnail generation
- Time positions are automatically validated and clamped to valid ranges
- Asset loading is properly handled asynchronously

**Issue: Thumbnail generation fails for specific time positions**
- Solution: Time positions are automatically clamped to valid ranges (0 to video duration)
- The plugin handles edge cases such as times beyond video duration gracefully

## Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| Android | ✅ Full | Requires storage permissions |
| iOS | ✅ Full | No additional setup required |
| Web | ❌ Not yet | May be added in future versions |
| Windows | ❌ Not yet | May be added in future versions |
| macOS | ❌ Not yet | May be added in future versions |
| Linux | ❌ Not yet | May be added in future versions |

## Native Implementations

This package uses native implementations for optimal performance:
- **Android**: Uses `MediaMetadataRetriever` for efficient frame extraction
- **iOS**: Uses `AVFoundation` and `AVAssetImageGenerator` for high-quality thumbnail generation

All native code is automatically registered via the Flutter plugin system - no manual setup required.

## Performance Considerations

- **Memory usage**: Large video files may consume significant memory during processing
- **Processing time**: Frame extraction time depends on video size and complexity
- **Storage**: Extracted frames are stored automatically by the cross-platform package
- **Quality vs. Size**: Higher quality settings result in larger file sizes
- **Cross-platform**: Performance may vary between platforms due to native implementations
- **Multiple thumbnails**: On iOS, multiple thumbnail generation is optimized with resource management (limited to 2 concurrent operations) to prevent resource exhaustion
- **Asset loading**: Native implementations properly handle asynchronous asset loading to ensure video tracks are ready before generation

## Best Practices

1. **Rebuild after adding**: Always rebuild your app after adding the package (`flutter clean && flutter build`)
2. **Request permissions early**: Request storage permissions before attempting to extract frames
3. **Handle errors gracefully**: Always wrap frame extraction in try-catch blocks
4. **Use appropriate dimensions**: Choose dimensions that balance quality and performance
5. **Validate input**: Ensure video paths exist and parameters are within valid ranges (time positions are automatically validated)
6. **Platform testing**: Test on all target platforms to ensure consistent behavior
7. **Automatic storage**: The package handles storage automatically - no need to manage output paths
8. **Multiple thumbnails**: When generating multiple thumbnails, the plugin handles resource management automatically (iOS limits to 2 concurrent operations)

## Example

Check out the `example/` directory for a complete Flutter application demonstrating how to use this package. The example app includes:

- Video file selection
- Customizable frame extraction options
- Real-time preview
- Multiple frame extraction
- Error handling
- Modern Material 3 UI

## Testing

The package includes comprehensive test coverage:

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test test/integration_test.dart

# Generate test coverage report
flutter test --coverage
```

## DEVELOPMENT REQUIREMENTS

### Quality Standards

- **Pana score**: 160/160 ✅ (Perfect score achieved)
- **Flutter analyze**: 0 issues
- **Dart analysis**: 0 issues
- **Test coverage**: >90%
- **Documentation**: Comprehensive with examples (100% API documentation coverage)

### Platform Support

- iOS
- Android
- Web
- Windows
- macOS
- Linux
- WASM compatible

### Package Structure

- **username**: Dhia-Bechattaoui
- **Dart SDK**: >=3.8.0
- **Flutter**: >=3.32.0
- **.gitignore**: Included
- **CHANGELOG**: Included
- Follows pub.dev publishing guidelines

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Before contributing, please ensure:

1. All tests pass
2. Code follows the project's style guidelines
3. New features include appropriate tests
4. Documentation is updated

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Dependencies

This package is a standalone Flutter plugin with native implementations for:
- **Android**: Using `MediaMetadataRetriever` for efficient thumbnail generation
- **iOS**: Using `AVFoundation` and `AVAssetImageGenerator` for thumbnail generation

The package includes:
- Automatic permission handling (`permission_handler`)
- Automatic file storage (`path_provider`)
- Cross-platform IO utilities (`universal_io`)

## Support

If you encounter any issues or have questions, please:

1. Check the [documentation](https://github.com/Dhia-Bechattaoui/video_snapshot_generator#readme)
2. Search existing [issues](https://github.com/Dhia-Bechattaoui/video_snapshot_generator/issues)
3. Create a new issue with detailed information

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and version history.

## Roadmap

Future versions may include:
- Video metadata extraction
- Batch processing capabilities
- Custom frame shapes
- Advanced filtering options
- Performance optimizations
- Additional output formats

## Recent Updates

### Version 0.1.1 (Latest)

- ✅ **Fixed critical issue**: Converted package to proper Flutter plugin structure
- ✅ **Native implementations**: Moved from example app to plugin level for automatic registration
- ✅ **iOS improvements**: Enhanced multiple thumbnail generation with better error handling and resource management
- ✅ **Quality**: Achieved perfect 160/160 Pana score
- ✅ **Documentation**: 100% API documentation coverage

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## Acknowledgments

- Flutter team for the excellent framework
- All contributors and issue reporters who helped improve this package
