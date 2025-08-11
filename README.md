# video_snapshot_generator

A Flutter package for generating video snapshots and thumbnails with custom dimensions and quality settings. This package provides a simple and efficient way to generate thumbnails from video files in Flutter applications across all platforms.

## Features

- 🎬 Extract frames from video files at specific time positions
- 📏 Customizable frame dimensions (width and height)
- 🎨 Quality control settings (1-100)
- ⏰ Extract frames at specific time positions
- 🖼️ Multiple output formats (JPEG, PNG, WebP)
- 🌐 **Full cross-platform support (Android, iOS, Web, Windows, macOS, Linux)**
- 🚀 **WASM compatible for web applications**
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
  video_snapshot_generator: ^0.0.2
```

Then run:

```bash
flutter pub get
```

### Platform Setup

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

#### iOS

No additional setup required for iOS.

#### Web

No additional setup required for web. **Fully WASM compatible!**

#### Desktop (Windows, macOS, Linux)

No additional setup required for desktop platforms.

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

## Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| Android | ✅ Full | Requires storage permissions |
| iOS | ✅ Full | No additional setup required |
| Web | ✅ Full | **WASM compatible, no additional setup** |
| Windows | ✅ Full | No additional setup required |
| macOS | ✅ Full | No additional setup required |
| Linux | ✅ Full | No additional setup required |

## WASM Compatibility

This package is fully compatible with WebAssembly (WASM) and can be used in Flutter web applications without any platform-specific code. The underlying `cross_platform_video_thumbnails` package handles all platform differences automatically.

## Performance Considerations

- **Memory usage**: Large video files may consume significant memory during processing
- **Processing time**: Frame extraction time depends on video size and complexity
- **Storage**: Extracted frames are stored automatically by the cross-platform package
- **Quality vs. Size**: Higher quality settings result in larger file sizes
- **Cross-platform**: Performance may vary between platforms due to native implementations

## Best Practices

1. **Request permissions early**: Request storage permissions before attempting to extract frames
2. **Handle errors gracefully**: Always wrap frame extraction in try-catch blocks
3. **Use appropriate dimensions**: Choose dimensions that balance quality and performance
4. **Validate input**: Ensure video paths exist and parameters are within valid ranges
5. **Platform testing**: Test on all target platforms to ensure consistent behavior
6. **Automatic storage**: The package handles storage automatically - no need to manage output paths

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

This package depends on:
- `cross_platform_video_thumbnails`: Core cross-platform video frame extraction functionality with WASM support

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

## Acknowledgments

- [cross_platform_video_thumbnails](https://pub.dev/packages/cross_platform_video_thumbnails) package for cross-platform functionality and WASM support
- Flutter team for the excellent framework
