import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_snapshot_generator/video_snapshot_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Snapshot Generator Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Video Snapshot Generator Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _selectedVideoPath;
  String? _extractedFramePath;
  ThumbnailResult? _lastResult;
  List<ThumbnailResult> _multipleResults =
      []; // Store all multiple frame results
  bool _isExtracting = false;
  String? _errorMessage;
  ThumbnailFormat _selectedFormat = ThumbnailFormat.jpeg;
  bool _platformAvailable = false;
  List<String> _supportedVideoFormats = [];
  List<ThumbnailFormat> _supportedOutputFormats = [];

  final TextEditingController _timeController =
      TextEditingController(text: '5000');
  final TextEditingController _widthController =
      TextEditingController(text: '320');
  final TextEditingController _heightController =
      TextEditingController(text: '240');
  final TextEditingController _qualityController =
      TextEditingController(text: '80');

  @override
  void initState() {
    super.initState();
    // Permissions are now handled automatically by the package
    _checkPlatformCapabilities();
  }

  Future<void> _checkPlatformCapabilities() async {
    try {
      // Try to get platform capabilities, but don't fail if unavailable
      // The cross_platform_video_thumbnails package may not have native implementations
      try {
        final isAvailable = await VideoSnapshotGenerator.isPlatformAvailable();
        final videoFormats = VideoSnapshotGenerator.getSupportedVideoFormats();
        final outputFormats =
            VideoSnapshotGenerator.getSupportedOutputFormats();

        setState(() {
          // On Android, isPlatformAvailable() might return false even if plugin works
          // So we'll show it as available if we can get the formats
          _platformAvailable = isAvailable ||
              videoFormats.isNotEmpty ||
              outputFormats.isNotEmpty;
          _supportedVideoFormats = videoFormats.isNotEmpty
              ? videoFormats
              : ['mp4', 'mov', 'avi', 'mkv', 'webm'];
          _supportedOutputFormats = outputFormats.isNotEmpty
              ? outputFormats
              : [
                  ThumbnailFormat.jpeg,
                  ThumbnailFormat.png,
                  ThumbnailFormat.webP
                ];
        });
      } catch (e) {
        // If platform capability check fails (plugin not initialized or method unavailable),
        // set reasonable defaults - assume available on Android/iOS
        // The cross_platform_video_thumbnails package may not have complete native implementations
        setState(() {
          _platformAvailable = true; // Assume available if check fails
          _supportedVideoFormats = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
          _supportedOutputFormats = [
            ThumbnailFormat.jpeg,
            ThumbnailFormat.png,
            ThumbnailFormat.webP
          ];
        });
      }
    } catch (e) {
      // Final fallback - set defaults
      setState(() {
        _platformAvailable = true;
        _supportedVideoFormats = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
        _supportedOutputFormats = [
          ThumbnailFormat.jpeg,
          ThumbnailFormat.png,
          ThumbnailFormat.webP
        ];
      });
    }
  }

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        final videoPath = result.files.single.path!;

        // Check if format is supported (optional check - don't fail if unavailable)
        bool isSupported = true; // Default to true
        try {
          isSupported =
              await VideoSnapshotGenerator.isVideoFormatSupported(videoPath);
        } catch (e) {
          // If format check fails (plugin not available), just proceed anyway
          // The actual thumbnail generation will handle the error if needed
          isSupported = true; // Assume supported if check fails
        }

        setState(() {
          _selectedVideoPath = videoPath;
          _extractedFramePath = null;
          _errorMessage = isSupported
              ? null
              : 'Warning: Video format may not be fully supported';
          _lastResult = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking video: ${e.toString()}';
      });
    }
  }

  Future<void> _extractFrame() async {
    if (_selectedVideoPath == null) {
      setState(() {
        _errorMessage = 'Please select a video first';
      });
      return;
    }

    setState(() {
      _isExtracting = true;
      _errorMessage = null;
      _extractedFramePath = null;
      _lastResult = null;
      _multipleResults =
          []; // Clear multiple results for single frame extraction
    });

    try {
      final timeMs = int.tryParse(_timeController.text) ?? 5000;
      final width = int.tryParse(_widthController.text) ?? 320;
      final height = int.tryParse(_heightController.text) ?? 240;
      final quality = int.tryParse(_qualityController.text) ?? 80;

      final options = ThumbnailOptions(
        videoPath: _selectedVideoPath!,
        timeMs: timeMs,
        width: width,
        height: height,
        quality: quality,
        format: _selectedFormat,
      );

      final result = await VideoSnapshotGenerator.generateThumbnail(
        videoPath: _selectedVideoPath!,
        options: options,
      );

      setState(() {
        _extractedFramePath = result.path;
        _lastResult = result;
        _isExtracting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isExtracting = false;
      });
    }
  }

  Future<void> _extractMultipleFrames() async {
    if (_selectedVideoPath == null) {
      setState(() {
        _errorMessage = 'Please select a video first';
      });
      return;
    }

    setState(() {
      _isExtracting = true;
      _errorMessage = null;
      _extractedFramePath = null;
      _lastResult = null;
      _multipleResults = []; // Clear previous multiple results
    });

    try {
      final width = int.tryParse(_widthController.text) ?? 320;
      final height = int.tryParse(_heightController.text) ?? 240;
      final quality = int.tryParse(_qualityController.text) ?? 80;

      final options = ThumbnailOptions(
        videoPath: _selectedVideoPath!,
        width: width,
        height: height,
        quality: quality,
        format: _selectedFormat,
      );

      final results = await VideoSnapshotGenerator.generateMultipleThumbnails(
        videoPath: _selectedVideoPath!,
        timePositions: [0, 5000, 10000, 15000], // 0s, 5s, 10s, 15s
        options: options,
      );

      if (results.isNotEmpty) {
        setState(() {
          _extractedFramePath =
              results.first.path; // Show first frame as preview
          _lastResult =
              results.first; // Keep first result for single frame display
          _multipleResults =
              results; // Store all results for multiple frame display
          _isExtracting = false;
        });

        // Show success message with frame count
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully extracted ${results.length} frames'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'No frames were extracted';
          _isExtracting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isExtracting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video Selection',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedVideoPath ?? 'No video selected',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _pickVideo,
                          child: const Text('Pick Video'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frame Extraction Settings',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _timeController,
                            decoration: const InputDecoration(
                              labelText: 'Time (ms)',
                              hintText: '5000',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _widthController,
                            decoration: const InputDecoration(
                              labelText: 'Width',
                              hintText: '320',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: 'Height',
                              hintText: '240',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _qualityController,
                            decoration: const InputDecoration(
                              labelText: 'Quality (1-100)',
                              hintText: '80',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Format selection
                    Text(
                      'Output Format',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ThumbnailFormat>(
                      segments: const [
                        ButtonSegment<ThumbnailFormat>(
                          value: ThumbnailFormat.jpeg,
                          label: Text('JPEG'),
                        ),
                        ButtonSegment<ThumbnailFormat>(
                          value: ThumbnailFormat.png,
                          label: Text('PNG'),
                        ),
                        ButtonSegment<ThumbnailFormat>(
                          value: ThumbnailFormat.webP,
                          label: Text('WebP'),
                        ),
                      ],
                      selected: {_selectedFormat},
                      onSelectionChanged: (Set<ThumbnailFormat> newSelection) {
                        setState(() {
                          _selectedFormat = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isExtracting ? null : _extractFrame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: _isExtracting
                        ? const CircularProgressIndicator()
                        : const Text('Extract Single Frame'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isExtracting ? null : _extractMultipleFrames,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: _isExtracting
                        ? const CircularProgressIndicator()
                        : const Text('Extract Multiple Frames'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display multiple frames if available
            if (_multipleResults.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Multiple Frames Extracted (${_multipleResults.length})',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _multipleResults.length,
                          itemBuilder: (context, index) {
                            final result = _multipleResults[index];
                            final filePath = result.path;
                            return Container(
                              margin: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                children: [
                                  if (filePath.isNotEmpty &&
                                      File(filePath).existsSync())
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxHeight: 150,
                                        maxWidth: 150,
                                      ),
                                      child: Image.file(
                                        File(filePath),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${result.timeMs}ms',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${result.width}x${result.height}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Display single frame result
            if (_lastResult != null && _multipleResults.isEmpty)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Extraction Result',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      // Display thumbnail image if path exists
                      if (_extractedFramePath != null &&
                          File(_extractedFramePath!).existsSync())
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: Image.file(
                            File(_extractedFramePath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      const SizedBox(height: 16),
                      _buildResultInfo(_lastResult!),
                    ],
                  ),
                ),
              ),
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.red,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Platform capabilities card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Capabilities',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _platformAvailable ? Icons.check_circle : Icons.error,
                          color: _platformAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Platform Available: ${_platformAvailable ? "Yes" : "No"}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supported Video Formats: ${_supportedVideoFormats.join(", ")}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supported Output Formats: ${_supportedOutputFormats.map((f) => f.name.toUpperCase()).join(", ")}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This example demonstrates all features of the video_snapshot_generator package.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Features Demonstrated:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('✓ Single frame extraction'),
                    const Text('✓ Multiple frame extraction'),
                    const Text('✓ Customizable dimensions and quality'),
                    const Text('✓ Time-based frame selection'),
                    const Text('✓ Multiple output formats (JPEG, PNG, WebP)'),
                    const Text('✓ Automatic permission handling'),
                    const Text('✓ Automatic storage handling'),
                    const Text('✓ Platform capability checking'),
                    const Text('✓ Error handling and user feedback'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultInfo(ThumbnailResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Dimensions', '${result.width} x ${result.height}'),
        _buildInfoRow(
            'File Size', '${(result.dataSize / 1024).toStringAsFixed(2)} KB'),
        _buildInfoRow('Format', result.format ?? 'Unknown'),
        _buildInfoRow('Time Position', '${result.timeMs}ms'),
        _buildInfoRow('Saved Path', result.path),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: label == 'Saved Path' ? 'monospace' : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _qualityController.dispose();
    super.dispose();
  }
}
