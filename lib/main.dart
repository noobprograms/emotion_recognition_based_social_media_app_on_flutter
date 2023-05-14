import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mood_fresher/Screen/home.dart';
import 'package:mood_fresher/utils/colors.dart';
import 'package:mood_fresher/Screen/feed.dart';

List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDKT85UazLzAy20kAD8cUkGzPHD_Eu74Jg',
        appId: '1:1010399320425:web:9048e6e9c35565c93f85f8',
        messagingSenderId: '1010399320425',
        projectId: 'mood-fresher',
        storageBucket: 'mood-fresher.appspot.com',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Fresher',
      theme: ThemeData.dark()
          .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
      home: FeedScreen(),
    );
  }
}
