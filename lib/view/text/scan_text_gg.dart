import 'dart:math';

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
  //point
  List<Point> listPoint = [];
  List<Point> listCornerBlock = [];
  List<int> leftRight = [];
  Map<String, String> keyss = {};
  Map<String, String> valuess = {};
  Map<String, Map<String, String>> mapKeyValue = {};
  Map<String, Map<String, String>> mapKeyValueInfor = {};
  Map<String, String> infors = {};
  int difference = 15;
  Map<String, String> onlyValue = {};
  Map<String, Map<Map<String, String>, bool>> finalFilter = {};

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
                      children: [
                        Text("infor blocks"),
                        Column(
                          children: List.generate(
                              blocks.length,
                              (index) => Container(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.blue))),
                                    child: formatBlocks(
                                        index,
                                        blocks.elementAt(index).cornerPoints,
                                        blocks.elementAt(index).text),
                                  )),
                        ),
                        Text("filter cornerPoints blocks"),
                        Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("left - index: ${leftRight.first}"),
                                    Text(listPoint.first.toString())
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "top - index: ${leftRight.elementAt(2)}"),
                                    Text(listPoint.elementAt(2).toString())
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "right - index: ${leftRight.elementAt(1)}"),
                                    Text(listPoint.elementAt(1).toString())
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("bottom - index: ${leftRight.last}"),
                                    Text(listPoint.last.toString())
                                  ],
                                )
                              ],
                            )),
                        Text("keys blocks - left"),
                        Container(
                          margin: const EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(
                                keyss.length,
                                (index) => Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blueAccent)),
                                          child: Text(
                                            keyss.keys.elementAt(index),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blueAccent)),
                                          child: Text(
                                            keyss.values.elementAt(index),
                                          ),
                                        ),
                                      ],
                                    )),
                          ),
                        ),
                        const Divider(),
                        Text("values blocks - right"),
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: Column(
                            children: List.generate(
                                valuess.length,
                                (index) => Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueAccent)),
                                            child: Text(
                                                valuess.keys.elementAt(index))),
                                        Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueAccent)),
                                            child: Text(valuess.values
                                                .elementAt(index))),
                                      ],
                                    )),
                          ),
                        ),
                        const Divider(),
                        Text("information blocks - center"),
                        Container(
                          margin: const EdgeInsets.all(5),
                          alignment: Alignment.centerRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: List.generate(
                                infors.length,
                                (index) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueAccent)),
                                            child: Text(
                                                infors.keys.elementAt(index))),
                                        Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueAccent)),
                                            child: Text(infors.values
                                                .elementAt(index))),
                                      ],
                                    )),
                          ),
                        ),
                        const Divider(),
                        Text("Match keys and values blocks"),
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: Column(
                            children: List.generate(
                                mapKeyValue.length,
                                (index) => Row(
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueAccent)),
                                            child: Text(mapKeyValue.keys
                                                .elementAt(index))),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.blueAccent)),
                                                child: Text(mapKeyValue.values
                                                    .elementAt(index)
                                                    .keys
                                                    .first),
                                              ),
                                              Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .blueAccent)),
                                                  child: Text(mapKeyValue.values
                                                      .elementAt(index)
                                                      .values
                                                      .first)),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                          ),
                        ),
                        const Divider(),
                        Text("Values > keys blocks"),
                        Container(
                          margin: const EdgeInsets.all(5),
                          alignment: Alignment.centerRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: List.generate(
                                onlyValue.length,
                                (index) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueAccent)),
                                            child: Text(onlyValue.keys
                                                .elementAt(index))),
                                        Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueAccent)),
                                            child: Text(onlyValue.values
                                                .elementAt(index))),
                                      ],
                                    )),
                          ),
                        ),
                        const Divider(),
                        Text("Match information and values blocks"),
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: Column(
                            children: List.generate(
                                mapKeyValueInfor.length,
                                (index) => Row(
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueAccent)),
                                            child: Text(mapKeyValueInfor.keys
                                                .elementAt(index))),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.blueAccent)),
                                                child: Text(mapKeyValueInfor
                                                    .values
                                                    .elementAt(index)
                                                    .keys
                                                    .first),
                                              ),
                                              Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .blueAccent)),
                                                  child: Text(mapKeyValueInfor
                                                      .values
                                                      .elementAt(index)
                                                      .values
                                                      .first)),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                          ),
                        ),
                        const Divider(),
                        Text("FINAL"),
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: Column(
                            children: List.generate(
                                finalFilter.length,
                                (index) => Row(
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueAccent)),
                                            child: Text(finalFilter.keys
                                                .elementAt(index))),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.blueAccent)),
                                                child: Text(finalFilter.values
                                                    .elementAt(index)
                                                    .keys
                                                    .first
                                                    .keys
                                                    .first),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.blueAccent)),
                                                child: Text(finalFilter.values
                                                    .elementAt(index)
                                                    .keys
                                                    .first
                                                    .values
                                                    .first),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                          ),
                        ),
                      ],
                    ),
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
      _text = 'Recognized text:\n\n${/*recognizedText.text*/ "---"}';
      _customPaint = null;
      processBlocks();
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void processBlocks() {
    if (blocks.isNotEmpty) {
      filterBlocks();
      //----lấy 4 góc mặc định block---
      listCornerBlock.clear();
      listCornerBlock.add(Point(blocks.first.cornerPoints.first.x,
          blocks.first.cornerPoints.first.y));
      listCornerBlock.add(Point(blocks.first.cornerPoints.elementAt(1).x,
          blocks.first.cornerPoints.elementAt(1).y));
      listCornerBlock.add(Point(blocks.last.cornerPoints.elementAt(2).x,
          blocks.last.cornerPoints.elementAt(2).y));
      listCornerBlock.add(Point(
          blocks.last.cornerPoints.last.x, blocks.last.cornerPoints.last.y));
      //-------check lại 4 góc---------
      leftRight.clear();
      leftRight.addAll([0, 0, 0, 0]);
      Point minPointLeft = listCornerBlock.first;
      Point maxPointRight = listCornerBlock.elementAt(1);
      Point minPointTop = listCornerBlock.first;
      Point maxPointBottom = listCornerBlock.last;
      for (var i = 0; i < blocks.length; i++) {
        Point tmpL = comparePointLeft(
            minPointLeft,
            blocks.elementAt(i).cornerPoints.first,
            blocks.elementAt(i).cornerPoints.last);
        Point tmpR = comparePointRight(
            maxPointRight,
            blocks.elementAt(i).cornerPoints.elementAt(1),
            blocks.elementAt(i).cornerPoints.elementAt(2));
        Point tmpT = comparePointTop(
            minPointTop,
            blocks.elementAt(i).cornerPoints.first,
            blocks.elementAt(i).cornerPoints.elementAt(1));
        Point tmpB = comparePointBottom(
            maxPointBottom,
            blocks.elementAt(i).cornerPoints.last,
            blocks.elementAt(i).cornerPoints.elementAt(2));
        if (checkPoint(tmpL, blocks.elementAt(i).cornerPoints.first,
            blocks.elementAt(i).cornerPoints.last)) {
          leftRight[0] = i;
          minPointLeft = tmpL;
        }
        if (checkPoint(tmpR, blocks.elementAt(i).cornerPoints.elementAt(1),
            blocks.elementAt(i).cornerPoints.elementAt(2))) {
          leftRight[1] = i;
          maxPointRight = tmpR;
        }
        if (checkPoint(tmpT, blocks.elementAt(i).cornerPoints.first,
            blocks.elementAt(i).cornerPoints.elementAt(1))) {
          leftRight[2] = i;
          minPointTop = tmpT;
        }
        if (checkPoint(tmpB, blocks.elementAt(i).cornerPoints.last,
            blocks.elementAt(i).cornerPoints.elementAt(2))) {
          leftRight[3] = i;
          maxPointBottom = tmpB;
        }
      }
      listPoint
          .addAll([minPointLeft, maxPointRight, minPointTop, maxPointBottom]);
      //------cach1-----------
      filterKeyValue();
      //-------------------
      // filterBlocks();
    }
  }

  //--check 4 góc---
  Point comparePointLeft(Point pointDefault, Point point1, Point point2) {
    Point point = pointDefault;
    if (point.x >= point1.x) {
      point = point1;
    }
    if (point.x >= point2.x) {
      point = point2;
    }
    return point;
  }

  Point comparePointRight(Point pointDefault, Point point1, Point point2) {
    Point point = pointDefault;
    if (point.x <= point1.x) {
      point = point1;
    }
    if (point.x <= point2.x) {
      point = point2;
    }
    return point;
  }

  Point comparePointTop(Point pointDefault, Point point1, Point point2) {
    Point point = pointDefault;
    if (point.y >= point1.y) {
      point = point1;
    }
    if (point.y >= point2.y) {
      point = point2;
    }
    return point;
  }

  Point comparePointBottom(Point pointDefault, Point point1, Point point2) {
    Point point = pointDefault;
    if (point.y <= point1.y) {
      point = point1;
    }
    if (point.y <= point2.y) {
      point = point2;
    }
    return point;
  }

  bool checkPoint(Point pointDefault, Point point1, Point point2) {
    return (pointDefault.x == point1.x && pointDefault.y == point1.y) ||
            (pointDefault.x == point2.x && pointDefault.y == point2.y)
        ? true
        : false;
  }
  //-----------------------

  filterBlocks() {
    blocks.sort(
      (a, b) => a.cornerPoints.first.y.compareTo(b.cornerPoints.first.y),
    );
  }

  //----chia key value độc lập ----
  filterKeyValue() {
    for (var i = 0; i < blocks.length; i++) {
      int count = 0;
      if (checkPointFilterLeft(
          listPoint.first,
          blocks.elementAt(i).cornerPoints.first,
          blocks.elementAt(i).cornerPoints.last)) {
        keyss.addAll({"$i": blocks.elementAt(i).text});
        count++;
      }
      if (checkPointFilterRight(
          listPoint.elementAt(1),
          blocks.elementAt(i).cornerPoints.elementAt(1),
          blocks.elementAt(i).cornerPoints.elementAt(2))) {
        valuess.addAll({"$i": blocks.elementAt(i).text});
        count++;
      }
      if (count == 0) {
        infors.addAll({"$i": blocks.elementAt(i).text});
      }
      if (count == 2) {
        infors.addAll({"$i": blocks.elementAt(i).text});
        if (keyss.isNotEmpty) {
          keyss.remove(keyss.keys.elementAt(keyss.length - 1));
        }
        if (valuess.isNotEmpty) {
          valuess.remove(valuess.keys.elementAt(valuess.length - 1));
        }
      }
    }
    getKeyValue();
  }

  bool checkPointFilterLeft(Point pointDefault, Point point1, Point point2) {
    return point1.x - pointDefault.x <= difference ||
            point2.x - pointDefault.x <= difference
        ? true
        : false;
  }

  bool checkPointFilterRight(Point pointDefault, Point point1, Point point2) {
    return pointDefault.x - point1.x <= difference ||
            pointDefault.x - point2.x <= difference
        ? true
        : false;
  }
  //---------------

  //-----gọp key value----
  getKeyValue() {
    mapKeyValue.clear();
    if (keyss.length > valuess.length) {
      for (var i = 0; i < keyss.keys.length; i++) {
        int indexK = int.parse(keyss.keys.elementAt(i));
        String childKey = keyss.values.elementAt(i);
        String childValue = "";
        for (var j = 0; j < valuess.keys.length; j++) {
          int indexV = int.parse(valuess.keys.elementAt(j));
          if (checkKeyvalue(blocks.elementAt(indexK).cornerPoints,
              blocks.elementAt(indexV).cornerPoints)) {
            if (keyss.values.elementAt(i) != valuess.values.elementAt(j)) {
              childValue = valuess.values.elementAt(j);
            }
          }
        }
        mapKeyValue.addAll({
          "$indexK": {childKey: childValue}
        });
      }
      //--kiểm tra key rỗng
      onlyValue.clear();
      valuess.forEach((key, value) {
        if (!mapKeyValue.values
            .any((element) => element.values.first == value)) {
          onlyValue.addAll({key: value});
        }
      });
      getKeyValueWithInfor();
    }
    //--------------------
    insertInfor();
  }

  bool checkKeyvalue(List<Point<int>> point1, List<Point<int>> point2) {
    return (point1.elementAt(1).y - point2.first.y).abs() < difference ||
        (point1.elementAt(2).y - point2.last.y).abs() < difference;
  }
  //--------------------

  getKeyValueWithInfor() {
    mapKeyValueInfor.clear();
    if (infors.length > onlyValue.length) {
      for (var i = 0; i < infors.keys.length; i++) {
        int indexK = int.parse(infors.keys.elementAt(i));
        String childKey = infors.values.elementAt(i);
        String childValue = "";
        for (var j = 0; j < onlyValue.keys.length; j++) {
          int indexV = int.parse(onlyValue.keys.elementAt(j));
          if (checkKeyvalue(blocks.elementAt(indexK).cornerPoints,
              blocks.elementAt(indexV).cornerPoints)) {
            if (keyss.values.elementAt(i) != onlyValue.values.elementAt(j)) {
              childValue = onlyValue.values.elementAt(j);
            }
          }
        }
        mapKeyValueInfor.addAll({
          "$indexK": {childKey: childValue}
        });
      }
    }
  }

  //---chèn đầy đủ thông tin----
  insertInfor() {
    finalFilter.clear();
    for (var i = 0; i < blocks.length; i++) {
      int indexKeyValue = getIndex(mapKeyValue.keys.toList(growable: false), i);
      if (indexKeyValue != -1) {
        finalFilter.addAll({
          "$i": {mapKeyValue.values.elementAt(indexKeyValue): false}
        });
      }
      int indexKeyValueInfor =
          getIndex(mapKeyValueInfor.keys.toList(growable: false), i);
      if (indexKeyValueInfor != -1) {
        finalFilter.addAll({
          "$i": {mapKeyValueInfor.values.elementAt(indexKeyValueInfor): false}
        });
      }
      // int indexInfor = getIndex(infors.keys.toList(growable: false), i);
      // if (indexInfor != -1) {
      //   finalFilter.addAll({
      //     "$i": {
      //       {infors.values.elementAt(indexInfor): ""}: true
      //     }
      //   });
      // }
    }
  }

  //--------------------------
  int getIndex(List<String> list, int index) {
    // ignore: unrelated_type_equality_checks
    return list.indexWhere((element) => element == "$index");
  }

  //-------------
  Widget formatBlocks(int index, List<Point<int>> cornerPoints, String text) {
    return Row(
      children: [
        Text("$index: "),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cornerPoints.first.toString()),
                  Text(cornerPoints.elementAt(1).toString()),
                ],
              ),
              Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent)),
                  child: Text(text)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cornerPoints.last.toString()),
                  Text(cornerPoints.elementAt(2).toString())
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
