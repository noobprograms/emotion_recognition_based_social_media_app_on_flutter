import 'dart:math';
import 'dart:typed_data';
import 'dart:developer' as dev;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart';
import 'camera_view.dart';
import 'face_detector_painter.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector();
  bool isBusy = false;
  CustomPaint? customPaint;
  var result;

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/converted_model.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      customPaint: customPaint,
      onImage: (inputImage) {
        loadModel();
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.front,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
      // var cropped = cropImage(inputImage);
      runModel(inputImage);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  // Uint8List cropImage(InputImage inputImage) {
  //   // Get the dimensions of the input image
  //   final Uint8List? imageData = inputImage.bytes;
  //   final int imageWidth = rightC.toInt() - leftC.toInt();
  //   final int imageHeight = bottomC.toInt() - topC.toInt();

  //   final int cropLeft = leftC.toInt();
  //   final int cropTop = topC.toInt();

  //   final Uint8List croppedBytes = Uint8List(imageWidth * imageHeight * 4);

  //   for (int y = 0; y < imageHeight; y++) {
  //     final int yOffset = y * imageWidth;
  //     final int croppedOffset = y * imageWidth * 4;
  //     for (int x = 0; x < imageWidth; x++) {
  //       final int xOffset = x + cropLeft;
  //       final int sourceOffset =
  //           (xOffset + (cropTop + yOffset) * imageWidth) * 4;

  //       croppedBytes[croppedOffset + x * 4] = imageData![sourceOffset];
  //       croppedBytes[croppedOffset + x * 4 + 1] = imageData[sourceOffset + 1];
  //       croppedBytes[croppedOffset + x * 4 + 2] = imageData[sourceOffset + 2];
  //       croppedBytes[croppedOffset + x * 4 + 3] = imageData[sourceOffset + 3];
  //     }
  //   }

  //   return croppedBytes;
  // }

  runModel(blist) async {
    if (blist != null) {
      var recognitions = await Tflite.runModelOnBinary(
          binary: blist, numResults: 2, threshold: 0.1, asynch: true);
      recognitions?.forEach((element) {
        setState(() {
          result = element["label"];
          dev.log(result);
        });
      });
    }
  }
}
