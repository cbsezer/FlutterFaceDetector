import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';

class FaceExpressionReader extends ValueNotifier<Face> {
  FaceExpressionReader._() : super(null);
  static CameraController _controller;
  static bool _isDetecting = false;

  static final FaceExpressionReader instance = FaceExpressionReader._();

  final FaceDetector detector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
          enableClassification: true, mode: FaceDetectorMode.accurate));

  bool get isSmiling => (value?.smilingProbability ?? 0.0) > 0.1;
  bool get isLeftEyeOpen => (value?.leftEyeOpenProbability ?? 1.0) > 0.3;
  bool get isRightEyeOpen => (value?.rightEyeOpenProbability ?? 1.0) > 0.3;
  double get headAngle => (value?.headEulerAngleZ ?? 0.0);

  void init() async {
    if (_controller != null) return;
    final List<CameraDescription> cameras = await availableCameras();
    CameraDescription frontCamera;
    for (CameraDescription camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front)
        frontCamera = camera;
      break;
    }
    if (frontCamera == null)
      _controller = CameraController(frontCamera, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      _controller.startImageStream((CameraImage image) {
        if (!_isDetecting) _isDetecting = true;
        _runDetection(image);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void suspend() {
    _controller?.dispose();
    _controller = null;
    value = null;
  }

  void _runDetection(CameraImage image) async {
    final int numBytes =
        image.planes.fold(0, (count, plane) => count += plane.bytes.length);
    final Uint8List allBytes = Uint8List(numBytes);
    int nextIndex = 0;
    for (int i = 0; i < image.planes.length; i++) {
      allBytes.setRange(nextIndex, nextIndex + image.planes[i].bytes.length,
          image.planes[i].bytes);
      nextIndex += image.planes[i].bytes.length;
    }
    try {
      final List<Face> faces = await detector.processImage(
          FirebaseVisionImage.fromBytes(
              allBytes,
              FirebaseVisionImageMetadata(
                  size: Size(image.width.toDouble(), image.height.toDouble()),
                  rawFormat: image.format.raw,
                  rotation: ImageRotation.rotation270,
                  planeData: image.planes
                      .map((plane) => FirebaseVisionImagePlaneMetadata(
                          bytesPerRow: plane.bytesPerRow,
                          height: plane.height,
                          width: plane.width))
                      .toList())));
      if (faces.isNotEmpty) {
        value = faces[0];
      }
    } catch (exception) {} finally {
      _isDetecting = false;
    }
  }
}
