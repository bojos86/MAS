import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});
  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _init = false;
  XFile? _lastShot;

  @override
  void initState() {
    super.initState();
    _initCam();
  }

  Future<void> _initCam() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(_cameras!.first, ResolutionPreset.medium);
        await _controller!.initialize();
        if (mounted) setState(() => _init = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _take() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final pic = await _controller!.takePicture();
      setState(() => _lastShot = pic);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Captured (demo). OCR parsing to be hooked.')));
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: _init && _controller != null
              ? CameraPreview(_controller!)
              : const Center(child: Text('Camera not ready / permissions needed')),
          ),
        ),
        if (_lastShot != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Last capture: ${_lastShot!.path}'),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: _take, icon: const Icon(Icons.camera), label: const Text('Capture'))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.upload_file), label: const Text('Upload (TBD)'))),
            ],
          ),
        )
      ],
    );
  }
}
