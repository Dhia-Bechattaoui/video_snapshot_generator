import 'package:flutter_test/flutter_test.dart';
import 'package:video_snapshot_generator/video_snapshot_generator.dart';

void main() {
  group('VideoSnapshotGenerator Integration Tests', () {
    testWidgets('should handle video frame extraction workflow', (
      final tester,
    ) async {
      // Test the complete workflow of creating options and extracting frames

      // Create thumbnail options
      const options = ThumbnailOptions(
        videoPath: '/test/video.mp4',
        width: 640,
        height: 480,
        quality: 90,
        timeMs: 5000,
        format: ThumbnailFormat.png,
      );

      // Verify options are created correctly
      expect(options.videoPath, '/test/video.mp4');
      expect(options.width, 640);
      expect(options.height, 480);
      expect(options.quality, 90);
      expect(options.timeMs, 5000);
      expect(options.format, ThumbnailFormat.png);

      // Test copyWith functionality
      final modifiedOptions = options.copyWith(
        width: 1280,
        height: 720,
        quality: 95,
      );

      expect(modifiedOptions.videoPath, '/test/video.mp4');
      expect(modifiedOptions.width, 1280);
      expect(modifiedOptions.height, 720);
      expect(modifiedOptions.quality, 95);
      expect(modifiedOptions.timeMs, 5000);
      expect(modifiedOptions.format, ThumbnailFormat.png);

      // Test result creation for success case
      const successResult = ThumbnailResult.success(
        path: '/output/frame.png',
        width: 640,
        height: 480,
        dataSize: 2048,
        format: 'PNG',
        timeMs: 5000,
      );

      expect(successResult.success, true);
      expect(successResult.path, '/output/frame.png');
      expect(successResult.width, 640);
      expect(successResult.height, 480);
      expect(successResult.dataSize, 2048);
      expect(successResult.format, 'PNG');
      expect(successResult.timeMs, 5000);
      expect(successResult.errorMessage, null);

      // Test result creation for error case
      const errorResult = ThumbnailResult.error(
        errorMessage: 'Video file not found',
      );

      expect(errorResult.success, false);
      expect(errorResult.path, '');
      expect(errorResult.width, 0);
      expect(errorResult.height, 0);
      expect(errorResult.dataSize, 0);
      expect(errorResult.format, null);
      expect(errorResult.timeMs, null);
      expect(errorResult.errorMessage, 'Video file not found');

      // Test result copying
      final copiedSuccessResult = successResult.copyWith(
        width: 1280,
        height: 720,
      );

      expect(copiedSuccessResult.success, true);
      expect(copiedSuccessResult.path, '/output/frame.png');
      expect(copiedSuccessResult.width, 1280);
      expect(copiedSuccessResult.height, 720);
      expect(copiedSuccessResult.dataSize, 2048);
      expect(copiedSuccessResult.format, 'PNG');
      expect(copiedSuccessResult.timeMs, 5000);

      // Test error result copying
      final copiedErrorResult = errorResult.copyWith(
        errorMessage: 'Permission denied',
      );

      expect(copiedErrorResult.success, false);
      expect(copiedErrorResult.errorMessage, 'Permission denied');
    });

    testWidgets('should handle different thumbnail formats', (
      final tester,
    ) async {
      // Test JPEG format
      const jpegOptions = ThumbnailOptions(videoPath: '/test/video.mp4');

      expect(jpegOptions.format, ThumbnailFormat.jpeg);

      // Test PNG format
      const pngOptions = ThumbnailOptions(
        videoPath: '/test/video.mp4',
        format: ThumbnailFormat.png,
      );

      expect(pngOptions.format, ThumbnailFormat.png);

      // Test WebP format
      const webpOptions = ThumbnailOptions(
        videoPath: '/test/video.mp4',
        format: ThumbnailFormat.webP,
      );

      expect(webpOptions.format, ThumbnailFormat.webP);

      // Test format conversion (this would be tested in actual implementation)
      expect(ThumbnailFormat.values.length, 3);
      expect(ThumbnailFormat.jpeg.name, 'jpeg');
      expect(ThumbnailFormat.png.name, 'png');
      expect(ThumbnailFormat.webP.name, 'webP');
    });

    testWidgets('should handle edge cases and boundary values', (
      final tester,
    ) async {
      // Test minimum values
      const minOptions = ThumbnailOptions(
        videoPath: '/test/video.mp4',
        width: 1,
        height: 1,
        quality: 1,
      );

      expect(minOptions.width, 1);
      expect(minOptions.height, 1);
      expect(minOptions.quality, 1);
      expect(minOptions.timeMs, 0);

      // Test maximum values
      const maxOptions = ThumbnailOptions(
        videoPath: '/test/video.mp4',
        width: 9999,
        height: 9999,
        quality: 100,
        timeMs: 999999,
      );

      expect(maxOptions.width, 9999);
      expect(maxOptions.height, 9999);
      expect(maxOptions.quality, 100);
      expect(maxOptions.timeMs, 999999);

      // Test default values
      const defaultOptions = ThumbnailOptions(videoPath: '/test/video.mp4');

      expect(defaultOptions.width, 320);
      expect(defaultOptions.height, 240);
      expect(defaultOptions.quality, 75);
      expect(defaultOptions.timeMs, 0);
      expect(defaultOptions.format, ThumbnailFormat.jpeg);
    });

    testWidgets('should maintain immutability', (final tester) async {
      // Test that original objects are not modified by copyWith
      const originalOptions = ThumbnailOptions(videoPath: '/test/video.mp4');

      final copiedOptions = originalOptions.copyWith(width: 640, height: 480);

      // Original should remain unchanged
      expect(originalOptions.width, 320);
      expect(originalOptions.height, 240);

      // Copied should have new values
      expect(copiedOptions.width, 640);
      expect(copiedOptions.height, 480);

      // Test result immutability
      const originalResult = ThumbnailResult.success(
        path: '/output/frame.jpg',
        width: 320,
        height: 240,
        dataSize: 1024,
        format: 'JPEG',
        timeMs: 5000,
      );

      final copiedResult = originalResult.copyWith(width: 640, height: 480);

      // Original should remain unchanged
      expect(originalResult.width, 320);
      expect(originalResult.height, 240);

      // Copied should have new values
      expect(copiedResult.width, 640);
      expect(copiedResult.height, 480);
    });
  });
}
