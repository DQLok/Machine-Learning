import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:machine_learning/view/text/widgets/detector_view.dart';
import 'package:machine_learning/view/text/widgets/text_detector_painter.dart';

class ScanTextGg extends StatefulWidget {
  const ScanTextGg({super.key});

  @override
  State<ScanTextGg> createState() => _ScanTextGgState();
}

class _ScanTextGgState extends State<ScanTextGg> {
  var _script = TextRecognitionScript.latin;
  var _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  List<TextBlock> blocks = [];
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        DetectorView(
          title: 'Text Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
          blocks: Column(
            children: [
              blocks.isEmpty
                  ? const SizedBox()
                  : Column(
                      children: List.generate(
                          blocks.first.cornerPoints.length,
                          (index) => Text(blocks.first.cornerPoints
                              .elementAt(index)
                              .x
                              .toString())),
                    ),
              blocks.isEmpty
                  ? const SizedBox()
                  : Text(blocks.first.lines.first.boundingBox.toString())
            ],
          ),
        ),
        Positioned(
            top: 30,
            left: 100,
            right: 100,
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _buildDropdown(),
                        )),
                    const Spacer(),
                  ],
                ),
              ],
            )),
      ]),
    );
  }

  Widget _buildDropdown() => DropdownButton<TextRecognitionScript>(
        value: _script,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.blue),
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (TextRecognitionScript? script) {
          if (script != null) {
            setState(() {
              _script = script;
              _textRecognizer.close();
              _textRecognizer = TextRecognizer(script: _script);
            });
          }
        },
        items: TextRecognitionScript.values
            .map<DropdownMenuItem<TextRecognitionScript>>((script) {
          return DropdownMenuItem<TextRecognitionScript>(
            value: script,
            child: Text(script.name),
          );
        }).toList(),
      );

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final recognizedText = await _textRecognizer.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = TextRecognizerPainter(
        recognizedText,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      blocks = recognizedText.blocks;
      _text = 'Recognized text:\n\n${recognizedText.text}';
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
