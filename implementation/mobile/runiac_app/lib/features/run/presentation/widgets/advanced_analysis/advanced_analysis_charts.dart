import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/advanced_analysis_demo_snapshots.dart';
import 'advanced_analysis_chart_helpers.dart';
import 'advanced_analysis_theme.dart';

class AdvancedAnalysisPaceChartPainter extends CustomPainter {
  const AdvancedAnalysisPaceChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final plot = AdvancedAnalysisChartGeometry(
      size,
      left: 34,
      top: 12,
      right: 8,
      bottom: 24,
    );
    final values = advancedAnalysisPacePoints.map((point) => point.y).toList();
    final min = values.reduce(math.min) - 8;
    final max = values.reduce(math.max) + 8;
    double xFor(double km) => plot.left + (km / 4.03) * plot.width;
    double yFor(double pace) =>
        plot.top + ((pace - min) / (max - min)) * plot.height;

    drawAdvancedAnalysisGrid(
      canvas,
      plot,
      ['6’00”', '6’30”', '7’00”'],
      ['0 km', '1 km', '2 km', '3 km', '4.03 km'],
    );

    final bandTop = yFor(384);
    final bandBottom = yFor(401);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(plot.left, bandTop, plot.right, bandBottom),
        const Radius.circular(4),
      ),
      Paint()..color = advancedAnalysisBlue07,
    );

    final offsets = advancedAnalysisPacePoints
        .map((p) => Offset(xFor(p.x), yFor(p.y)))
        .toList();
    drawAdvancedAnalysisLineArea(
      canvas,
      offsets,
      plot.bottom,
      advancedAnalysisOrange08,
      advancedAnalysisBlue,
    );
    final fast = advancedAnalysisPacePoints.reduce((a, b) => b.y < a.y ? b : a);
    final slow = advancedAnalysisPacePoints.reduce((a, b) => b.y > a.y ? b : a);
    canvas
      ..drawCircle(
        Offset(xFor(slow.x), yFor(slow.y)),
        5,
        Paint()..color = advancedAnalysisCard,
      )
      ..drawCircle(
        Offset(xFor(slow.x), yFor(slow.y)),
        5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = advancedAnalysisBlue30,
      )
      ..drawCircle(
        Offset(xFor(fast.x), yFor(fast.y)),
        7,
        Paint()..color = advancedAnalysisCard,
      )
      ..drawCircle(
        Offset(xFor(fast.x), yFor(fast.y)),
        6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = advancedAnalysisOrange,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AdvancedAnalysisElevationChartPainter extends CustomPainter {
  const AdvancedAnalysisElevationChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final plot = AdvancedAnalysisChartGeometry(
      size,
      left: 30,
      top: 12,
      right: 8,
      bottom: 22,
    );
    double xFor(double km) => plot.left + (km / 4.03) * plot.width;
    double yFor(double m) => plot.bottom - (m / 15) * plot.height;

    drawAdvancedAnalysisGrid(
      canvas,
      plot,
      ['10 m', '0 m'],
      ['0 km', '1 km', '2 km', '3 km', '4 km'],
    );
    final offsets = advancedAnalysisElevationPoints
        .map((p) => Offset(xFor(p.x), yFor(p.y)))
        .toList();
    drawAdvancedAnalysisLineArea(
      canvas,
      offsets,
      plot.bottom,
      advancedAnalysisBlue12,
      advancedAnalysisBlue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AdvancedAnalysisCadenceChartPainter extends CustomPainter {
  const AdvancedAnalysisCadenceChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final plot = AdvancedAnalysisChartGeometry(
      size,
      left: 34,
      top: 14,
      right: 8,
      bottom: 24,
    );
    double xFor(double t) => plot.left + t * plot.width;
    double yFor(double c) => plot.bottom - ((c - 152) / 26) * plot.height;

    drawAdvancedAnalysisGrid(
      canvas,
      plot,
      ['175', '160'],
      ['0:00', '10:00', '20:00', '30:15'],
    );
    final bandTop = yFor(175);
    final bandBottom = yFor(160);
    canvas.drawRect(
      Rect.fromLTRB(plot.left, bandTop, plot.right, bandBottom),
      Paint()..color = advancedAnalysisBlue07,
    );
    drawAdvancedAnalysisDashedLine(
      canvas,
      Offset(plot.left, bandTop),
      Offset(plot.right, bandTop),
    );
    drawAdvancedAnalysisDashedLine(
      canvas,
      Offset(plot.left, bandBottom),
      Offset(plot.right, bandBottom),
    );
    drawAdvancedAnalysisText(
      canvas,
      'Target 160–175',
      Offset(plot.right - 96, bandTop - 13),
      advancedAnalysisBlue45,
      10,
    );
    final offsets = advancedAnalysisCadencePoints
        .map((p) => Offset(xFor(p.x), yFor(p.y)))
        .toList();
    drawAdvancedAnalysisPolyline(canvas, offsets, advancedAnalysisBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
