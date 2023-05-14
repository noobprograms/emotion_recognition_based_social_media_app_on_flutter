import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

var leftC;
var topC;
var bottomC;
var rightC;
double translateX(
    double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.Rotation_90deg:
      return x *
          size.width /
          (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);
    case InputImageRotation.Rotation_270deg:
      return size.width -
          x *
              size.width /
              (Platform.isIOS
                  ? absoluteImageSize.width
                  : absoluteImageSize.height);
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double translateY(
    double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.Rotation_90deg:
    case InputImageRotation.Rotation_270deg:
      return y *
          size.height /
          (Platform.isIOS ? absoluteImageSize.height : absoluteImageSize.width);
    default:
      return y * size.height / absoluteImageSize.height;
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.faces, this.absoluteImageSize, this.rotation);

  final List<Face> faces;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  static var leftC;
  static var topC;
  static var bottomC;
  static var rightC;
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Color.fromARGB(255, 79, 243, 8);

    for (final Face face in faces) {
      leftC =
          translateX(face.boundingBox.left, rotation, size, absoluteImageSize);
      topC =
          translateY(face.boundingBox.top, rotation, size, absoluteImageSize);
      rightC =
          translateX(face.boundingBox.right, rotation, size, absoluteImageSize);
      bottomC = translateY(
          face.boundingBox.bottom, rotation, size, absoluteImageSize);
      print(leftC);
      print(topC);
      print(rightC);
      print(bottomC);
      canvas.drawRect(
        Rect.fromLTRB(
            // translateX(face.boundingBox.left, rotation, size, absoluteImageSize),
            // translateY(face.boundingBox.top, rotation, size, absoluteImageSize),
            // translateX(face.boundingBox.right, rotation, size, absoluteImageSize),
            // translateY(
            //     face.boundingBox.bottom, rotation, size, absoluteImageSize),
            leftC,
            topC,
            rightC,
            bottomC),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}
