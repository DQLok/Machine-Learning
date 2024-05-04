import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

class SelectPicture extends StatefulWidget {
  const SelectPicture({super.key, required this.title});
  final String title;

  @override
  State<SelectPicture> createState() => _SelectPictureState();
}

class _SelectPictureState extends State<SelectPicture> {
  late ImagePicker _picker;
  File? _image;
  String result = "Results will be show here";
  dynamic imageLabeler;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    final ImageLabelerOptions options =
        ImageLabelerOptions(confidenceThreshold: 0.5);
    imageLabeler = ImageLabeler(options: options);
  }

  @override
  void dispose() {
    super.dispose();
  }

  chooseImages() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        doImageLabeling();
      });
    }
  }

  captureImages() async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        doImageLabeling();
      });
    }
  }

  doImageLabeling() async {
    InputImage inputImage = InputImage.fromFile(_image!);
    List<ImageLabel> labels = [];
    if (Platform.isAndroid || Platform.isIOS) {
      labels = await imageLabeler.processImage(inputImage);
    }

    result = "";
    for (ImageLabel label in labels) {
      final String text = label.label;
      // final int index = label.index;
      final double confidence = label.confidence;
      result += "$text  ${confidence.toStringAsFixed(2)}\n";
    }
    setState(() {
      result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: const BoxDecoration(color: Colors.grey),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  width: 100,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Stack(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 510,
                            width: 500,
                            color: Colors.grey,
                          ),
                          Center(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.transparent,
                                    shadowColor: Colors.transparent),
                                onPressed: chooseImages,
                                onLongPress: captureImages,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: _image != null
                                      ? Image.file(
                                          _image!,
                                          width: 335,
                                          height: 495,
                                          fit: BoxFit.fill,
                                        )
                                      : Container(
                                          width: 340,
                                          height: 330,
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.black,
                                            size: 100,
                                          ),
                                        ),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    result,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
