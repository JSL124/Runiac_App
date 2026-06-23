import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:runiac_app/features/run/domain/models/cadence_graph_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/pace_graph_snapshot.dart';

import '../../data/advanced_analysis_demo_snapshots.dart';
import 'advanced_analysis_chart_helpers.dart';
import 'advanced_analysis_theme.dart';

class AdvancedAnalysisPaceChartPainter extends CustomPainter {
  const AdvancedAnalysisPaceChartPainter({this.graph});

  final PaceGraphSnapshot? graph;

  @override
  void paint(Canvas canvas, Size size) {
    final graph = this.graph;
    if (graph != null && graph.isAvailable && graph.hasDistanceAxis) {
      _paintSnapshotGraph(canvas, size, graph);
      return;
    }

    if (graph == null) {
      _paintDemoGraph(canvas, size);
    }
  }

  List<String> get snapshotXAxisLabels {
    final graph = this.graph;
    if (graph == null || !graph.hasDistanceAxis) {
      return const [];
    }
    return graph.distanceAxisLabels;
  }

  List<double> get snapshotXProgressFractions {
    final graph = this.graph;
    if (graph == null || !graph.hasDistanceAxis) {
      return const [];
    }
    return graph.points.map((point) {
      return point.distanceProgressFraction!.clamp(0.0, 1.0).toDouble();
    }).toList();
  }

  void _paintDemoGraph(Canvas canvas, Size size) {
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

  void _paintSnapshotGraph(Canvas canvas, Size size, PaceGraphSnapshot graph) {
    final plot = AdvancedAnalysisChartGeometry(
      size,
      left: 34,
      top: 12,
      right: 8,
      bottom: 24,
    );
    final rangeMin = graph.paceRangeMinSecondsPerKm;
    final rangeMax = graph.paceRangeMaxSecondsPerKm;
    if (rangeMin == null || rangeMax == null || rangeMax <= rangeMin) {
      return;
    }

    double xFor(double progress) {
      return plot.left + progress.clamp(0.0, 1.0) * plot.width;
    }

    double yFor(int paceSecondsPerKm) {
      return plot.top +
          ((paceSecondsPerKm - rangeMin) / (rangeMax - rangeMin)) * plot.height;
    }

    drawAdvancedAnalysisGrid(
      canvas,
      plot,
      graph.yAxisLabels,
      graph.distanceAxisLabels,
    );

    final offsets = graph.points.map((point) {
      return Offset(
        xFor(point.distanceProgressFraction!),
        yFor(point.paceSecondsPerKm),
      );
    }).toList();
    drawAdvancedAnalysisLineArea(
      canvas,
      offsets,
      plot.bottom,
      advancedAnalysisOrange08,
      advancedAnalysisBlue,
    );
    _drawSnapshotMarker(
      canvas,
      graph.points,
      offsets,
      graph.slowestPacePoint,
      fillColor: advancedAnalysisCard,
      strokeColor: advancedAnalysisBlue30,
      radius: 5,
      strokeWidth: 2,
    );
    _drawSnapshotMarker(
      canvas,
      graph.points,
      offsets,
      graph.bestPacePoint,
      fillColor: advancedAnalysisCard,
      strokeColor: advancedAnalysisOrange,
      radius: 6,
      strokeWidth: 3,
    );
  }

  void _drawSnapshotMarker(
    Canvas canvas,
    List<PaceGraphPoint> points,
    List<Offset> offsets,
    PaceGraphPoint? marker, {
    required Color fillColor,
    required Color strokeColor,
    required double radius,
    required double strokeWidth,
  }) {
    if (marker == null) {
      return;
    }

    for (var i = 0; i < points.length; i++) {
      if (identical(points[i], marker)) {
        final center = offsets[i];
        canvas
          ..drawCircle(center, radius + 1, Paint()..color = fillColor)
          ..drawCircle(
            center,
            radius,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          );
        return;
      }
    }
  }

  @override
  bool shouldRepaint(covariant AdvancedAnalysisPaceChartPainter oldDelegate) {
    return oldDelegate.graph != graph;
  }
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
  const AdvancedAnalysisCadenceChartPainter({
    this.graph,
    this.showDemoFallback = true,
  });

  final CadenceGraphSnapshot? graph;
  final bool showDemoFallback;

  @override
  void paint(Canvas canvas, Size size) {
    final graph = this.graph;
    if (graph != null && graph.isAvailable && graph.points.isNotEmpty) {
      _paintSnapshotGraph(canvas, size, graph);
      return;
    }

    if (graph != null) {
      return;
    }

    if (showDemoFallback) {
      _paintDemoGraph(canvas, size);
    }
  }

  void _paintDemoGraph(Canvas canvas, Size size) {
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
    final offsets = advancedAnalysisCadencePoints
        .map((p) => Offset(xFor(p.x), yFor(p.y)))
        .toList();
    drawAdvancedAnalysisLineArea(
      canvas,
      offsets,
      plot.bottom,
      advancedAnalysisBlue07,
      advancedAnalysisBlue,
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
      demoCadenceGraphTargetLabel,
      Offset(plot.right - 96, bandTop - 13),
      advancedAnalysisBlue45,
      10,
    );
  }

  void _paintSnapshotGraph(
    Canvas canvas,
    Size size,
    CadenceGraphSnapshot graph,
  ) {
    final plot = AdvancedAnalysisChartGeometry(
      size,
      left: 34,
      top: 14,
      right: 8,
      bottom: 24,
    );
    final rangeMin = graph.cadenceRangeMinSpm;
    final rangeMax = graph.cadenceRangeMaxSpm;
    if (rangeMin == null || rangeMax == null || rangeMax <= rangeMin) {
      return;
    }

    double xFor(double progress) {
      return plot.left + progress.clamp(0.0, 1.0) * plot.width;
    }

    double yFor(int cadenceSpm) {
      return plot.bottom -
          ((cadenceSpm - rangeMin) / (rangeMax - rangeMin)) * plot.height;
    }

    drawAdvancedAnalysisGrid(
      canvas,
      plot,
      graph.yAxisLabels.reversed.toList(growable: false),
      graph.xAxisLabels,
    );

    final offsets = graph.points.map((point) {
      return Offset(xFor(point.progressFraction), yFor(point.cadenceSpm));
    }).toList();
    drawAdvancedAnalysisLineArea(
      canvas,
      offsets,
      plot.bottom,
      advancedAnalysisBlue07,
      advancedAnalysisBlue,
    );

    final targetMin = graph.targetMinCadenceSpm;
    final targetMax = graph.targetMaxCadenceSpm;
    final targetLabel = graph.targetLabel;
    if (targetMin != null &&
        targetMax != null &&
        targetMax > targetMin &&
        targetMin >= rangeMin &&
        targetMax <= rangeMax) {
      final bandTop = yFor(targetMax);
      final bandBottom = yFor(targetMin);
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
      if (targetLabel != null && targetLabel.isNotEmpty) {
        drawAdvancedAnalysisText(
          canvas,
          targetLabel,
          Offset(plot.right - 112, bandTop - 13),
          advancedAnalysisBlue45,
          10,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant AdvancedAnalysisCadenceChartPainter oldDelegate,
  ) {
    return oldDelegate.graph != graph ||
        oldDelegate.showDemoFallback != showDemoFallback;
  }
}
