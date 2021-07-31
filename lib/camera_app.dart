import 'package:facedetector/face_expression_reader.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  final FaceExpressionReader _reader = FaceExpressionReader.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _reader.addListener(() {
      setState(() {});
    });
    _reader.init();
  }

  String _expressionToEmoji() {
    if (!_reader.isLeftEyeOpen && _reader.isRightEyeOpen) {
      return '😉';
    } else if (_reader.isSmiling) {
      return '😀';
    } else {
      return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Transform.rotate(
          angle: radians(_reader.headAngle),
          child: Text(
            _expressionToEmoji(),
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
