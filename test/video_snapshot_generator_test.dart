import 'package:flutter_test/flutter_test.dart';
import 'package:video_snapshot_generator/video_snapshot_generator.dart';

void main() {
  group('VideoSnapshotGenerator Tests', () {
    test('should create ThumbnailOptions with default values', () {
      const options = ThumbnailOptions(
        videoPath: '/test/video.mp4',
      );

      expect(options.videoPath, '/test/video.mp4');
      expect(options.width, 320);
      expect(options.height, 240);
      expect(options.quality, 75);
      expect(options.timeMs, 0);
      expect(options.format, ThumbnailFormat.jpeg);
    });

    test('should create ThumbnailOptions with custom values', () {
      const options = ThumbnailOptions(
        videoPath: '/test/video.mp4',
        width: 640,
        height: 480,
        quality: 90,
        timeMs: 5000,
        format: ThumbnailFormat.png,
      );

      expect(options.videoPath, '/test/video.mp4');
      expect(options.width, 640);
      expect(options.height, 480);
      expect(options.quality, 90);
      expect(options.timeMs, 5000);
      expect(options.format, ThumbnailFormat.png);
    });

    test('should copy ThumbnailOptions with new values', () {
      const original = ThumbnailOptions(
        videoPath: '/test/video.mp4',
        width: 320,
        height: 240,
      );

      final copied = original.copyWith(
        width: 640,
        quality: 90,
      );

      expect(copied.videoPath, '/test/video.mp4');
      expect(copied.width, 640);
      expect(copied.height, 240);
      expect(copied.quality, 90);
      expect(copied.timeMs, 0);
      expect(copied.format, ThumbnailFormat.jpeg);
    });

    test('should create successful ThumbnailResult', () {
      const result = ThumbnailResult.success(
        path: '/output/thumbnail.jpg',
        width: 320,
        height: 240,
        dataSize: 1024,
        format: 'JPEG',
        timeMs: 5000,
      );

      expect(result.success, true);
      expect(result.path, '/output/thumbnail.jpg');
      expect(result.width, 320);
      expect(result.height, 240);
      expect(result.dataSize, 1024);
      expect(result.format, 'JPEG');
      expect(result.timeMs, 5000);
      expect(result.errorMessage, null);
    });

    test('should create error ThumbnailResult', () {
      const result = ThumbnailResult.error(
        errorMessage: 'Video file not found',
      );

      expect(result.success, false);
      expect(result.path, '');
      expect(result.width, 0);
      expect(result.height, 0);
      expect(result.dataSize, 0);
      expect(result.format, null);
      expect(result.timeMs, null);
      expect(result.errorMessage, 'Video file not found');
    });

    test('should copy ThumbnailResult with new values', () {
      const original = ThumbnailResult.success(
        path: '/output/thumbnail.jpg',
        width: 320,
        height: 240,
        dataSize: 1024,
        format: 'JPEG',
        timeMs: 5000,
      );

      final copied = original.copyWith(
        width: 640,
        format: 'PNG',
      );

      expect(copied.path, '/output/thumbnail.jpg');
      expect(copied.width, 640);
      expect(copied.height, 240);
      expect(copied.dataSize, 1024);
      expect(copied.format, 'PNG');
      expect(copied.timeMs, 5000);
      expect(copied.success, true);
    });

    test('should handle ThumbnailFormat enum values', () {
      expect(ThumbnailFormat.jpeg, isA<ThumbnailFormat>());
      expect(ThumbnailFormat.png, isA<ThumbnailFormat>());
      expect(ThumbnailFormat.webP, isA<ThumbnailFormat>());
    });

    test('should validate ThumbnailOptions equality', () {
      const options1 = ThumbnailOptions(
        videoPath: '/test/video.mp4',
        width: 320,
        height: 240,
        quality: 75,
        timeMs: 0,
        format: ThumbnailFormat.jpeg,
      );

      const options2 = ThumbnailOptions(
        videoPath: '/test/video.mp4',
        width: 320,
        height: 240,
        quality: 75,
        timeMs: 0,
        format: ThumbnailFormat.jpeg,
      );

      expect(options1, equals(options2));
      expect(options1.hashCode, equals(options2.hashCode));
    });

    test('should validate ThumbnailResult equality', () {
      const result1 = ThumbnailResult.success(
        path: '/output/thumbnail.jpg',
        width: 320,
        height: 240,
        dataSize: 1024,
        format: 'JPEG',
        timeMs: 5000,
      );

      const result2 = ThumbnailResult.success(
        path: '/output/thumbnail.jpg',
        width: 320,
        height: 240,
        dataSize: 1024,
        format: 'JPEG',
        timeMs: 5000,
      );

      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('should handle ThumbnailOptions toString', () {
      const options = ThumbnailOptions(
        videoPath: '/test/video.mp4',
        width: 640,
        height: 480,
        quality: 90,
        timeMs: 5000,
        format: ThumbnailFormat.png,
      );

      final string = options.toString();
      expect(string, contains('ThumbnailOptions'));
      expect(string, contains('/test/video.mp4'));
      expect(string, contains('640'));
      expect(string, contains('480'));
      expect(string, contains('90'));
      expect(string, contains('5000'));
      expect(string, contains('ThumbnailFormat.png'));
    });

    test('should handle ThumbnailResult toString for success', () {
      const result = ThumbnailResult.success(
        path: '/output/thumbnail.jpg',
        width: 320,
        height: 240,
        dataSize: 1024,
        format: 'JPEG',
        timeMs: 5000,
      );

      final string = result.toString();
      expect(string, contains('ThumbnailResult.success'));
      expect(string, contains('/output/thumbnail.jpg'));
      expect(string, contains('320'));
      expect(string, contains('240'));
      expect(string, contains('1024'));
      expect(string, contains('JPEG'));
      expect(string, contains('5000'));
    });

    test('should handle ThumbnailResult toString for error', () {
      const result = ThumbnailResult.error(
        errorMessage: 'Video file not found',
      );

      final string = result.toString();
      expect(string, contains('ThumbnailResult.error'));
      expect(string, contains('Video file not found'));
    });
  });
}
