import 'dart:math';

class TextGroup {
  String index;
  ConrnerPoints conrnerPoints;
  String text;

  TextGroup(
      {required this.index, required this.conrnerPoints, required this.text});

  @override
  String toString() {
    return "$index: ${conrnerPoints.toString()}";
  }
}

class ConrnerPoints {
  Point pointLT;
  Point pointRT;
  Point pointRB;
  Point pointLB;

  ConrnerPoints(
      {required this.pointLT,
      required this.pointRT,
      required this.pointRB,
      required this.pointLB});

  @override
  String toString() {
    return "[$pointLT, $pointRT, $pointRB, $pointLB]";
  }
}

Point comparePointLeft(Point pointDefault, Point pointLT, Point pointLB) {
  Point point = pointDefault;
  if (point.x >= pointLT.x) {
    point = pointLT;
  }
  if (point.x >= pointLB.x) {
    point = pointLB;
  }
  return point;
}

Point comparePointRight(Point pointDefault, Point pointRT, Point pointRB) {
  Point point = pointDefault;
  if (point.x <= pointRT.x) {
    point = pointRT;
  }
  if (point.x <= pointRB.x) {
    point = pointRB;
  }
  return point;
}

Point comparePointTop(Point pointDefault, Point pointLT, Point pointRT) {
  Point point = pointDefault;
  if (point.y >= pointLT.y) {
    point = pointLT;
  }
  if (point.y >= pointRT.y) {
    point = pointRT;
  }
  return point;
}

Point comparePointBottom(Point pointDefault, Point pointLB, Point pointRB) {
  Point point = pointDefault;
  if (point.y <= pointLB.y) {
    point = pointLB;
  }
  if (point.y <= pointRB.y) {
    point = pointRB;
  }
  return point;
}

//-------------------------------------------------
class KeyValueFilter {
  TextGroup keyTG;
  List<TextGroup> valueTG;

  KeyValueFilter({required this.keyTG, required this.valueTG});

  sortListValueTG() {
    valueTG.sort(
      (a, b) => a.conrnerPoints.pointLT.x.compareTo(b.conrnerPoints.pointLT.x),
    );
  }

  @override
  String toString() {
    return "${keyTG.index}: ${valueTG.toString()}";
  }
}
