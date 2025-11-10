import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_io/io.dart' show Platform;

/// Handles automatic permission requests for video thumbnail generation.
class PermissionHandler {
  PermissionHandler._();

  /// Automatically requests necessary permissions for the current platform.
  /// Returns true if permissions are granted, false otherwise.
  static Future<bool> requestPermissions() async {
    try {
      // For web, permissions are handled by the browser
      if (kIsWeb) {
        return true;
      }

      if (Platform.isAndroid) {
        // For Android, request storage permissions
        // Android 13+ uses READ_MEDIA_VIDEO, older versions use READ_EXTERNAL_STORAGE
        try {
          // Try videos permission first (Android 13+)
          final videosStatus = await Permission.videos.request();
          if (videosStatus.isGranted) {
            return true;
          }
        } catch (e) {
          // Videos permission might not be available on older Android versions
        }

        // Fallback to storage permission
        try {
          final storageStatus = await Permission.storage.request();
          return storageStatus.isGranted;
        } catch (e) {
          // If storage permission also fails, return true to allow operation
          // The underlying operation will handle permission errors
          return true;
        }
      } else if (Platform.isIOS) {
        // iOS typically doesn't need explicit permissions for file access
        // but we check photos permission if accessing photo library
        try {
          final photosStatus = await Permission.photos.status;
          if (photosStatus.isDenied) {
            await Permission.photos.request();
          }
        } catch (e) {
          // If permission check fails, continue anyway
        }
        return true;
      }

      // For desktop platforms (Windows, macOS, Linux), permissions are typically not needed
      return true;
    } catch (e) {
      // If permission handling fails, return true to allow the operation to proceed
      // The underlying operation will handle permission errors appropriately
      return true;
    }
  }

  /// Checks if permissions are already granted.
  static Future<bool> hasPermissions() async {
    try {
      // For web, permissions are handled by the browser
      if (kIsWeb) {
        return true;
      }

      if (Platform.isAndroid) {
        try {
          // Try videos permission first (Android 13+)
          final videosStatus = await Permission.videos.status;
          if (videosStatus.isGranted) {
            return true;
          }
        } catch (e) {
          // Videos permission might not be available
        }

        // Check storage permission
        try {
          final storageStatus = await Permission.storage.status;
          return storageStatus.isGranted;
        } catch (e) {
          return true; // Assume granted if check fails
        }
      }

      // For iOS and other platforms, assume permissions are available
      return true;
    } catch (e) {
      return true;
    }
  }
}
