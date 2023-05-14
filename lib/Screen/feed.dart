import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mood_fresher/utils/colors.dart';
import 'package:mood_fresher/utils/global_variable.dart';
import 'package:mood_fresher/widgets/post_card.dart';
import 'package:universal_html/html.dart' as html;
import '../main.dart';

//camera code

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // final CameraStream cameraStream = CameraStream();
  // late StreamSubscription<CameraImage> _cameraSubscription;
  var detectedEmotion = 'neutral';
  var retrievalValue = 'posts';
  CameraController? cameraController;
  int _cameraIndex = 1;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;

  @override
  void initState() {
    super.initState();

    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  Timer? captureTimer;
  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    cameraController = CameraController(
      camera,
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );
    await cameraController?.initialize();
    if (mounted) {
      setState(() {});
    }
    cameraController?.startImageStream(_onCapture);
    const captureDuration = Duration(milliseconds: 100);
    captureTimer = Timer(captureDuration, () {
      cameraController!.stopImageStream();
      const intervalDuration = Duration(seconds: 17);
      captureTimer = Timer(intervalDuration, () {
        cameraController!.startImageStream(_onCapture);
      });
    });
  }

  Future _stopLiveFeed() async {
    await cameraController?.stopImageStream();
    await cameraController?.dispose();
    cameraController = null;
  }

  Future _onCapture(CameraImage image) async {
    // Convert the image bytes to base64
    Uint8List byteData = convertCameraImageToUint8List(image);
    String base64Image = base64Encode(byteData);
    Map<String, dynamic> payload = {
      'image': base64Image,
    };
    String jsonString = jsonEncode(payload);

    var response = await http.post(Uri.parse('http://172.20.10.2:5000/senti'),
        body: jsonString);
    // Check the response status
    if (response.statusCode == 200) {
      print(response.body);

      detectedEmotion = response.body;
    } else {
      print('Failed to send image. Status code: ${response.statusCode}');
    }
    if (detectedEmotion == 'sad' ||
        detectedEmotion == 'angry' ||
        detectedEmotion == 'disgusted') {
      retrievalValue = 'hey';
    } else {
      retrievalValue = 'posts';
    }
  }

  Uint8List convertCameraImageToUint8List(CameraImage image) {
    // Process the CameraImage data and convert it to Uint8List
    // You may need to handle different image formats (YUV, RGBA, etc.) based on your camera settings

    // Example code for YUV_420_888 format
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int? uvPixelStride = image.planes[1].bytesPerPixel;

    Uint8List bytes = Uint8List(image.width * image.height * 3 ~/ 2);

    int uvIndex = 0;
    int pixelIndex = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Y plane
        bytes[pixelIndex] =
            image.planes[0].bytes[y * image.planes[0].bytesPerRow + x];
        pixelIndex++;

        if (x % 2 == 0 && y % 2 == 0) {
          // UV planes
          bytes[width * height + uvIndex] = image.planes[1]
              .bytes[(y >> 1) * uvRowStride + (x >> 1) * uvPixelStride!];
          bytes[width * height + uvIndex + 1] = image.planes[2]
              .bytes[(y >> 1) * uvRowStride + (x >> 1) * uvPixelStride!];
          uvIndex += 2;
        }
      }
    }

    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        title: const Center(
          child: Text("Mood Fresher"),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => Container(
              margin: EdgeInsets.symmetric(
                horizontal: width > webScreenSize ? width * 0.3 : 0,
                vertical: width > webScreenSize ? 15 : 0,
              ),
              child: PostCard(
                snap: snapshot.data!.docs[index].data(),
              ),
            ),
          );
        },
      ),
    );
  }
}
