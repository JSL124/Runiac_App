import 'package:flutter/material.dart';

import '../../domain/models/run_map_view_state.dart';

typedef RunMapboxSurfaceBuilder =
    Widget Function(BuildContext context, RunMapboxSurfaceConfig config);

class RunMapboxSurfaceConfig {
  const RunMapboxSurfaceConfig({
    required this.accessToken,
    required this.mapViewState,
    required this.isFollowingRunner,
    required this.showRecenterButton,
    required this.recenterButtonBottom,
    this.recenterRequestId = 0,
    this.onManualPan,
    this.onRecenter,
  });

  final String accessToken;
  final RunMapViewState mapViewState;
  final bool isFollowingRunner;
  final int recenterRequestId;
  final VoidCallback? onManualPan;
  final VoidCallback? onRecenter;
  final bool showRecenterButton;
  final double recenterButtonBottom;
}
