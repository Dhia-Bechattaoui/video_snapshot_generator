import Flutter
import UIKit
import AVFoundation

public class VideoSnapshotGeneratorPlugin: NSObject, FlutterPlugin {
    private let CHANNEL = "video_snapshot_generator"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "video_snapshot_generator", binaryMessenger: registrar.messenger())
        let instance = VideoSnapshotGeneratorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isPlatformAvailable":
            result(true)

        case "generateThumbnail":
            handleGenerateThumbnail(call: call, result: result)

        case "generateThumbnails":
            handleGenerateThumbnails(call: call, result: result)

        case "isVideoFormatSupported":
            handleIsVideoFormatSupported(call: call, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleGenerateThumbnail(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let videoPath = args["videoPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Video path is required", details: nil))
            return
        }

        let timePosition = (args["timePosition"] as? Double) ?? 0.0
        let width = args["width"] as? Int ?? 320
        let height = args["height"] as? Int ?? 240
        let quality = args["quality"] as? Double ?? 0.8
        let format = args["format"] as? String ?? "jpeg"
        let maintainAspectRatio = args["maintainAspectRatio"] as? Bool ?? false

        generateThumbnail(
            videoPath: videoPath,
            timePosition: timePosition,
            width: width,
            height: height,
            quality: quality,
            format: format,
            maintainAspectRatio: maintainAspectRatio,
            completion: { thumbnail in
                if let thumbnail = thumbnail {
                    result(thumbnail)
                } else {
                    result(FlutterError(code: "GENERATION_FAILED", message: "Failed to generate thumbnail", details: nil))
                }
            }
        )
    }

    private func handleGenerateThumbnails(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let optionsList = args["optionsList"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Options list is required", details: nil))
            return
        }

        var thumbnails: [[String: Any]] = []
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 2) // Limit to 2 concurrent operations
        let resultQueue = DispatchQueue(label: "thumbnail.results.queue") // Serial queue for thread-safe array access

        for options in optionsList {
            guard let videoPath = options["videoPath"] as? String else {
                resultQueue.async {
                    thumbnails.append(["error": "Video path is required"])
                }
                continue
            }

            let timePosition = (options["timePosition"] as? Double) ?? 0.0
            let width = options["width"] as? Int ?? 320
            let height = options["height"] as? Int ?? 240
            let quality = (options["quality"] as? Double) ?? 0.8
            let format = options["format"] as? String ?? "jpeg"
            let maintainAspectRatio = options["maintainAspectRatio"] as? Bool ?? false

            group.enter()
            // Limit concurrent operations
            semaphore.wait()
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.generateThumbnail(
                    videoPath: videoPath,
                    timePosition: timePosition,
                    width: width,
                    height: height,
                    quality: quality,
                    format: format,
                    maintainAspectRatio: maintainAspectRatio,
                    completion: { thumbnail in
                        resultQueue.async {
                            if let thumbnail = thumbnail {
                                thumbnails.append(thumbnail)
                            } else {
                                thumbnails.append(["error": "Failed to generate thumbnail"])
                            }
                            semaphore.signal()
                            group.leave()
                        }
                    }
                )
            }
        }

        group.notify(queue: .main) {
            result(thumbnails)
        }
    }

    private func handleIsVideoFormatSupported(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let videoPath = args["videoPath"] as? String else {
            result(false)
            return
        }

        let supportedFormats = ["mp4", "mov", "3gp", "avi", "mkv", "webm"]
        let fileExtension = (videoPath as NSString).pathExtension.lowercased()
        result(supportedFormats.contains(fileExtension))
    }

    private func generateThumbnail(
        videoPath: String,
        timePosition: Double,
        width: Int,
        height: Int,
        quality: Double,
        format: String,
        maintainAspectRatio: Bool,
        completion: @escaping ([String: Any]?) -> Void
    ) {
        let url: URL
        if videoPath.hasPrefix("http://") || videoPath.hasPrefix("https://") {
            guard let httpUrl = URL(string: videoPath) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            url = httpUrl
        } else {
            url = URL(fileURLWithPath: videoPath)
        }

        let asset = AVAsset(url: url)
        
        // Load asset properties asynchronously to ensure tracks are ready
        let keys = ["tracks", "duration", "playable"]
        asset.loadValuesAsynchronously(forKeys: keys) {
            var error: NSError?
            let tracksStatus = asset.statusOfValue(forKey: "tracks", error: &error)
            let durationStatus = asset.statusOfValue(forKey: "duration", error: &error)
            
            // Check if loading failed
            if tracksStatus == .failed || durationStatus == .failed {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Validate that the asset is playable and has tracks
            guard asset.isPlayable else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Get video tracks to validate the asset
            let videoTracks = asset.tracks(withMediaType: .video)
            guard !videoTracks.isEmpty else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Validate time position is within video duration
            let duration = asset.duration
            let durationSeconds = CMTimeGetSeconds(duration)
            let clampedTime: Double
            if timePosition < 0 {
                clampedTime = 0.0
            } else if durationSeconds.isFinite && timePosition > durationSeconds {
                clampedTime = max(0.0, durationSeconds - 0.1) // Slightly before end
            } else {
                clampedTime = timePosition
            }
            
            self.generateThumbnailFromAsset(
                asset: asset,
                timePosition: clampedTime,
                width: width,
                height: height,
                quality: quality,
                format: format,
                maintainAspectRatio: maintainAspectRatio,
                completion: completion
            )
        }
    }
    
    private func generateThumbnailFromAsset(
        asset: AVAsset,
        timePosition: Double,
        width: Int,
        height: Int,
        quality: Double,
        format: String,
        maintainAspectRatio: Bool,
        completion: @escaping ([String: Any]?) -> Void
    ) {
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = CMTime(seconds: 0.5, preferredTimescale: 600)
        imageGenerator.requestedTimeToleranceBefore = CMTime(seconds: 0.5, preferredTimescale: 600)
        imageGenerator.maximumSize = CGSize(width: width * 2, height: height * 2) // Generate at higher resolution for better quality
        
        // Use the already-clamped time position
        let time = CMTime(seconds: timePosition, preferredTimescale: 600)

        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { (requestedTime, cgImage, actualTime, result, error) in
            // Always complete on main thread
            defer {
                // Cleanup is handled automatically by ARC
            }
            
            if let error = error {
                // Log error for debugging but don't expose details to user
                NSLog("AVAssetImageGenerator error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let cgImage = cgImage, result == .succeeded else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            // Scale image on background queue for performance
            DispatchQueue.global(qos: .userInitiated).async {
                let scaledImage: CGImage
                if maintainAspectRatio {
                    scaledImage = self.scaleImageMaintainingAspectRatio(
                        cgImage: cgImage,
                        targetWidth: width,
                        targetHeight: height
                    )
                } else {
                    scaledImage = self.scaleImage(cgImage: cgImage, width: width, height: height)
                }

                // Convert to UIImage for encoding
                let uiImage = UIImage(cgImage: scaledImage)

                // Encode to requested format
                guard let imageData = self.encodeImage(image: uiImage, format: format, quality: quality) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                let finalWidth = scaledImage.width
                let finalHeight = scaledImage.height

                DispatchQueue.main.async {
                    completion([
                        "data": FlutterStandardTypedData(bytes: imageData),
                        "width": finalWidth,
                        "height": finalHeight,
                        "format": format,
                        "timePosition": actualTime.seconds
                    ])
                }
            }
        }
    }

    private func scaleImageMaintainingAspectRatio(cgImage: CGImage, targetWidth: Int, targetHeight: Int) -> CGImage {
        let sourceWidth = cgImage.width
        let sourceHeight = cgImage.height
        let sourceAspect = Double(sourceWidth) / Double(sourceHeight)
        let targetAspect = Double(targetWidth) / Double(targetHeight)

        var drawWidth = targetWidth
        var drawHeight = targetHeight
        var drawX = 0
        var drawY = 0

        if sourceAspect > targetAspect {
            // Source is wider - fit to width
            drawHeight = Int(Double(targetWidth) / sourceAspect)
            drawY = (targetHeight - drawHeight) / 2
        } else {
            // Source is taller - fit to height
            drawWidth = Int(Double(targetHeight) * sourceAspect)
            drawX = (targetWidth - drawWidth) / 2
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: targetWidth,
            height: targetHeight,
            bitsPerComponent: 8,
            bytesPerRow: targetWidth * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        context?.setFillColor(UIColor.black.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
        context?.interpolationQuality = .high
        context?.draw(cgImage, in: CGRect(x: drawX, y: drawY, width: drawWidth, height: drawHeight))

        return context?.makeImage() ?? cgImage
    }

    private func scaleImage(cgImage: CGImage, width: Int, height: Int) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        context?.interpolationQuality = .high
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context?.makeImage() ?? cgImage
    }

    private func encodeImage(image: UIImage, format: String, quality: Double) -> Data? {
        let qualityValue = CGFloat(quality)

        switch format.lowercased() {
        case "png":
            return image.pngData()

        case "webp":
            // WebP is not natively supported on iOS, fallback to JPEG
            return image.jpegData(compressionQuality: qualityValue)

        case "jpeg", "jpg":
            fallthrough
        default:
            return image.jpegData(compressionQuality: qualityValue)
        }
    }
}

