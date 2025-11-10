package com.example.video_snapshot_generator_example

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "cross_platform_video_thumbnails"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPlatformAvailable" -> {
                    result.success(true)
                }
                "generateThumbnail" -> {
                    try {
                        val videoPath = call.argument<String>("videoPath")
                        val timePosition = call.argument<Double>("timePosition") ?: 0.0
                        val width = call.argument<Int>("width") ?: 320
                        val height = call.argument<Int>("height") ?: 240
                        val quality = call.argument<Double>("quality") ?: 0.8
                        val format = call.argument<String>("format") ?: "jpeg"
                        val maintainAspectRatio = call.argument<Boolean>("maintainAspectRatio") ?: false

                        if (videoPath == null) {
                            result.error("INVALID_ARGUMENT", "Video path is required", null)
                            return@setMethodCallHandler
                        }

                        val thumbnail = generateThumbnail(
                            videoPath,
                            (timePosition * 1_000_000).toLong(), // Convert seconds to microseconds
                            width,
                            height,
                            quality.toFloat(),
                            format,
                            maintainAspectRatio
                        )

                        if (thumbnail != null) {
                            result.success(thumbnail)
                        } else {
                            result.error("GENERATION_FAILED", "Failed to generate thumbnail", null)
                        }
                    } catch (e: Exception) {
                        result.error("EXCEPTION", e.message, null)
                    }
                }
                "generateThumbnails" -> {
                    try {
                        val optionsList = call.argument<List<Map<String, Any>>>("optionsList")
                        if (optionsList == null || optionsList.isEmpty()) {
                            result.error("INVALID_ARGUMENT", "Options list is required", null)
                            return@setMethodCallHandler
                        }

                        val thumbnails = mutableListOf<Map<String, Any>>()
                        for (options in optionsList) {
                            val videoPath = options["videoPath"] as? String
                            if (videoPath == null) {
                                thumbnails.add(mapOf("error" to "Video path is required"))
                                continue
                            }

                            val timePosition = (options["timePosition"] as? Double) ?: 0.0
                            val width = (options["width"] as? Int) ?: 320
                            val height = (options["height"] as? Int) ?: 240
                            val quality = (options["quality"] as? Double) ?: 0.8
                            val format = (options["format"] as? String) ?: "jpeg"
                            val maintainAspectRatio = (options["maintainAspectRatio"] as? Boolean) ?: false

                            val thumbnail = generateThumbnail(
                                videoPath,
                                (timePosition * 1_000_000).toLong(), // Convert seconds to microseconds
                                width,
                                height,
                                quality.toFloat(),
                                format,
                                maintainAspectRatio
                            )

                            if (thumbnail != null) {
                                thumbnails.add(thumbnail)
                            } else {
                                thumbnails.add(mapOf("error" to "Failed to generate thumbnail"))
                            }
                        }

                        result.success(thumbnails)
                    } catch (e: Exception) {
                        result.error("EXCEPTION", e.message, null)
                    }
                }
                "isVideoFormatSupported" -> {
                    try {
                        val videoPath = call.argument<String>("videoPath")
                        if (videoPath == null) {
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        val file = File(videoPath)
                        if (!file.exists()) {
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        val extension = file.extension.lowercase()
                        val supportedFormats = listOf("mp4", "mov", "3gp", "avi", "mkv", "webm")
                        result.success(supportedFormats.contains(extension))
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun generateThumbnail(
        videoPath: String,
        timeUs: Long,
        width: Int,
        height: Int,
        quality: Float,
        format: String,
        maintainAspectRatio: Boolean
    ): Map<String, Any>? {
        val timePositionSeconds = timeUs / 1_000_000.0
        val retriever = MediaMetadataRetriever()
        return try {
            // Set data source
            if (videoPath.startsWith("http://") || videoPath.startsWith("https://")) {
                retriever.setDataSource(videoPath, HashMap())
            } else {
                retriever.setDataSource(videoPath)
            }

            // Get frame at specified time
            val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                retriever.getFrameAtTime(timeUs, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
            } else {
                retriever.getFrameAtTime(timeUs)
            }

            if (bitmap == null) {
                return null
            }

            // Scale bitmap if needed
            val scaledBitmap = if (maintainAspectRatio) {
                scaleBitmapMaintainingAspectRatio(bitmap, width, height)
            } else {
                Bitmap.createScaledBitmap(bitmap, width, height, true)
            }

            // Compress to byte array
            val outputStream = ByteArrayOutputStream()
            val compressFormat = when (format.lowercase()) {
                "png" -> Bitmap.CompressFormat.PNG
                "webp" -> Bitmap.CompressFormat.WEBP
                else -> Bitmap.CompressFormat.JPEG
            }
            val qualityInt = (quality * 100).toInt().coerceIn(0, 100)
            scaledBitmap.compress(compressFormat, qualityInt, outputStream)
            val data = outputStream.toByteArray()

            // Save dimensions before recycling
            val finalWidth = scaledBitmap.width
            val finalHeight = scaledBitmap.height

            // Clean up
            scaledBitmap.recycle()
            if (scaledBitmap != bitmap) {
                bitmap.recycle()
            }

            mapOf(
                "data" to data,
                "width" to finalWidth,
                "height" to finalHeight,
                "format" to format.lowercase(),
                "timePosition" to timePositionSeconds
            )
        } catch (e: Exception) {
            null
        } finally {
            try {
                retriever.release()
            } catch (e: Exception) {
                // Ignore release errors
            }
        }
    }

    private fun scaleBitmapMaintainingAspectRatio(
        bitmap: Bitmap,
        targetWidth: Int,
        targetHeight: Int
    ): Bitmap {
        val bitmapWidth = bitmap.width
        val bitmapHeight = bitmap.height
        val bitmapAspect = bitmapWidth.toFloat() / bitmapHeight.toFloat()
        val targetAspect = targetWidth.toFloat() / targetHeight.toFloat()

        return if (bitmapAspect > targetAspect) {
            // Bitmap is wider than target - scale based on height
            val scaledWidth = (targetHeight * bitmapAspect).toInt()
            Bitmap.createScaledBitmap(bitmap, scaledWidth, targetHeight, true)
        } else {
            // Bitmap is taller than target - scale based on width
            val scaledHeight = (targetWidth / bitmapAspect).toInt()
            Bitmap.createScaledBitmap(bitmap, targetWidth, scaledHeight, true)
        }
    }
}
