import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:machine_learning/view/barcode.dart';
import 'package:machine_learning/view/process_camera.dart';
import 'package:machine_learning/view/select_picture.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Barcode()
        // ProcessCamera(cameras: _cameras)
        //ProcessCamera(cameras: _cameras),
        );
  }
}
