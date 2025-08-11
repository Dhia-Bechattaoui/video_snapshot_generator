import 'package:flutter/material.dart';
import 'package:video_snapshot_generator/video_snapshot_generator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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
  bool _isExtracting = false;
  String? _errorMessage;
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
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }
  }

  Future<void> _pickVideo() async {
    // In a real app, you would use file_picker or similar
    // For this example, we'll use a mock path
    setState(() {
      _selectedVideoPath = '/storage/emulated/0/Download/sample_video.mp4';
      _extractedFramePath = null;
      _errorMessage = null;
    });
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
        format: ThumbnailFormat.jpeg,
      );

      final result = await VideoSnapshotGenerator.generateThumbnail(
        videoPath: _selectedVideoPath!,
        options: options,
      );

      setState(() {
        _extractedFramePath = result.path;
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
        format: ThumbnailFormat.jpeg,
      );

      final results = await VideoSnapshotGenerator.generateMultipleThumbnails(
        videoPath: _selectedVideoPath!,
        timePositions: [0, 5000, 10000, 15000], // 0s, 5s, 10s, 15s
        options: options,
      );

      if (results.isNotEmpty) {
        setState(() {
          _extractedFramePath = results.first.path;
          _isExtracting = false;
        });

        // Show success message with frame count
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully extracted ${results.length} frames'),
            backgroundColor: Colors.green,
          ),
        );
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
      body: Padding(
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
            if (_extractedFramePath != null)
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
                      Text(
                        'Frame saved at:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        _extractedFramePath!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                      ),
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
            const Spacer(),
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
                      'This example demonstrates how to use the video_snapshot_generator package to extract frames from video files with customizable settings.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Features:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Single frame extraction'),
                    const Text('• Multiple frame extraction'),
                    const Text('• Customizable dimensions and quality'),
                    const Text('• Time-based frame selection'),
                    const Text('• Error handling and user feedback'),
                  ],
                ),
              ),
            ),
          ],
        ),
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
