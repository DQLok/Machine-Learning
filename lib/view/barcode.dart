// ignore_for_file: constant_pattern_never_matches_value_type

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

class Barcode extends StatefulWidget {
  const Barcode({Key? key}) : super(key: key);
  @override
  _BarcodeState createState() => _BarcodeState();
}

class _BarcodeState extends State<Barcode> {
  late ImagePicker imagePicker;
  File? _image;
  String result = 'results will be shown here';
  dynamic barcodeScanner;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    barcodeScanner = BarcodeScanner(formats: formats);
  }

  @override
  void dispose() {
    super.dispose();
  }

  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doBarcodeScanning();
    });
  }

  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        doBarcodeScanning();
      });
    }
  }

  doBarcodeScanning() async {
    InputImage inputImage = InputImage.fromFile(_image!);
    List<Barcode> barcodes = [];
    if (Platform.isAndroid || Platform.isIOS) {
      barcodes = await barcodeScanner.processImage(inputImage);
    }

    for (Barcode barcode in barcodes) {
      // final BarcodeType type = barcode.type;
      // final Rect boundingBox = barcode.boundingBox;
      // final String? displayValue = barcode.displayValue;
      // final String? rawValue = barcode.rawValue;

      // See API reference for complete list of supported types
      switch (barcode) {
        case BarcodeType.wifi:
          BarcodeWifi? barcodeWifi = barcode as BarcodeWifi;
          result = "Wifi: ${barcodeWifi.password}";
          break;
        case BarcodeType.url:
          BarcodeUrl barcodeUrl = barcode as BarcodeUrl;
          result = "Url: ${barcodeUrl.url}";
          break;
      }
      setState(() {
        result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        color: Colors.grey,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  width: 100,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Stack(children: <Widget>[
                    Stack(children: <Widget>[
                      Center(
                        child: Container(
                          color: Colors.amber,
                          height: 350,
                          width: 350,
                        ),
                      ),
                    ]),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            shadowColor: Colors.transparent),
                        onPressed: _imgFromGallery,
                        onLongPress: _imgFromCamera,
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          child: _image != null
                              ? Image.file(
                                  _image!,
                                  width: 325,
                                  height: 325,
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
                        ),
                      ),
                    ),
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    result,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
