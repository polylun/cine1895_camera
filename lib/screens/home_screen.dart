
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  CameraController? _camera;
  List<CameraDescription>? _cams;
  bool _initializing = true;

  // Overlay video
  VideoPlayerController? _video;
  double _overlayOpacity = 0.6;
  bool _includeOverlayOnCapture = false;

  // Transform controls
  Offset _overlayOffset = Offset.zero;
  double _overlayScale = 1.0;

  // For capturing the composited preview
  final GlobalKey _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await [Permission.camera, Permission.storage].request();
    _cams = await availableCameras();
    _camera = CameraController(
      _cams!.first,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _camera!.initialize();
    if (!mounted) return;
    setState(() => _initializing = false);
  }

  @override
  void dispose() {
    _camera?.dispose();
    _video?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result == null) return;
    final file = File(result.files.single.path!);
    _video?.dispose();
    _video = VideoPlayerController.file(file);
    await _video!.initialize();
    _video!
      ..setLooping(true)
      ..play();
    setState(() {});
  }

  Future<void> _capture() async {
    if (_camera == null) return;
    if (_includeOverlayOnCapture) {
      // Capture composited stack as image
      final boundary = _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/cine1895_${DateTime.now().millisecondsSinceEpoch}.png';
      final f = File(path)..writeAsBytesSync(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved composited image: ${f.path}')));
    } else {
      // Capture camera image only
      final XFile x = await _camera!.takePicture();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved camera image: ${x.path}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cine1895 Camera'),
        actions: [
          IconButton(
            onPressed: _pickVideo,
            icon: const Icon(Icons.video_file_outlined),
            tooltip: 'Pick overlay video (MP4)',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _camera!.value.previewSize!.width / _camera!.value.previewSize!.height,
                  child: RepaintBoundary(
                    key: _captureKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_camera!),
                        if (_video != null && _video!.value.isInitialized)
                          Transform.translate(
                            offset: _overlayOffset,
                            child: Transform.scale(
                              scale: _overlayScale,
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onPanUpdate: (d) => setState(() => _overlayOffset += d.delta),
                                onScaleUpdate: (details) => setState(() {
                                  _overlayScale = details.scale.clamp(0.2, 5.0);
                                }),
                                child: Opacity(
                                  opacity: _overlayOpacity,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: _video!.value.size.width,
                                      height: _video!.value.size.height,
                                      child: VideoPlayer(_video!),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildControls(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _capture,
        label: const Text('CAPTURE'),
        icon: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Overlay opacity'),
              Expanded(
                child: Slider(
                  value: _overlayOpacity,
                  onChanged: (v) => setState(() => _overlayOpacity = v),
                  min: 0.0,
                  max: 1.0,
                ),
              ),
              Text(_overlayOpacity.toStringAsFixed(2)),
            ],
          ),
          Row(
            children: [
              const Text('Include overlay on capture'),
              const SizedBox(width: 8),
              Switch(
                value: _includeOverlayOnCapture,
                onChanged: (v) => setState(() => _includeOverlayOnCapture = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
