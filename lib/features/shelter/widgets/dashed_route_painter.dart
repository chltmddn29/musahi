import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';

/// 화면 좌표 [points]를 잇는 점선 경로.
class DashedRoutePainter extends CustomPainter {
  final List<Offset> points;

  const DashedRoutePainter(this.points);

  static const double _dash = 8;
  static const double _gap = 6;

  static final _paint = Paint()
    ..color = AppColors.primary
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final route = Path()..addPolygon(points, false);
    for (final metric in route.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), _paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedRoutePainter oldDelegate) =>
      !listEquals(oldDelegate.points, points);
}
