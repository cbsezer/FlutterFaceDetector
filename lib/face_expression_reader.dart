import 'dart:html';
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
}
