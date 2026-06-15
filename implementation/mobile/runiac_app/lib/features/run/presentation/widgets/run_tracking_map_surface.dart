import 'package:flutter/material.dart';

import '../../domain/models/run_map_view_state.dart';
import 'run_map_placeholder.dart';
import 'run_mapbox_run_map.dart';
import 'run_mapbox_surface_config.dart';

const _mapboxPublicAccessToken = String.fromEnvironment(
  'MAPBOX_PUBLIC_ACCESS_TOKEN',
);
const _mapboxSurfaceSelectedKey = Key('run_mapbox_surface_selected');
const _mapboxPlaceholderSelectedKey = Key('run_mapbox_placeholder_selected');

class RunTrackingMapSurface extends StatelessWidget {
  const RunTrackingMapSurface({
    super.key,
    this.mapViewState = const RunMapViewState.empty(),
    this.isFollowingRunner = true,
    this.onManualPan,
    this.onRecenter,
    this.showRecenterButton = true,
    this.recenterButtonBottom = 176,
    this.recenterRequestId = 0,
    this.mapboxAccessToken,
    this.mapboxBuilder,
  });

  final RunMapViewState mapViewState;
  final bool isFollowingRunner;
  final VoidCallback? onManualPan;
  final VoidCallback? onRecenter;
  final bool showRecenterButton;
  final double recenterButtonBottom;
  final int recenterRequestId;
  final String? mapboxAccessToken;
  final RunMapboxSurfaceBuilder? mapboxBuilder;

  @override
  Widget build(BuildContext context) {
    final accessToken = (mapboxAccessToken ?? _mapboxPublicAccessToken).trim();
    if (accessToken.isEmpty) {
      _debugLogMapboxBranch('placeholder fallback selected');
      return KeyedSubtree(
        key: _mapboxPlaceholderSelectedKey,
        child: RunMapPlaceholder(
          mapViewState: mapViewState,
          isFollowingRunner: isFollowingRunner,
          onManualPan: onManualPan,
          onRecenter: onRecenter,
          showRecenterButton: showRecenterButton,
          recenterButtonBottom: recenterButtonBottom,
        ),
      );
    }

    if (!accessToken.startsWith('pk.')) {
      _debugLogMapboxBranch('invalid token fallback selected');
      return KeyedSubtree(
        key: _mapboxPlaceholderSelectedKey,
        child: RunMapPlaceholder(
          mapViewState: mapViewState,
          isFollowingRunner: isFollowingRunner,
          onManualPan: onManualPan,
          onRecenter: onRecenter,
          showRecenterButton: showRecenterButton,
          recenterButtonBottom: recenterButtonBottom,
        ),
      );
    }

    _debugLogMapboxBranch('mapbox path selected');
    final builder = mapboxBuilder ?? _defaultMapboxBuilder;
    return KeyedSubtree(
      key: _mapboxSurfaceSelectedKey,
      child: builder(
        context,
        RunMapboxSurfaceConfig(
          accessToken: accessToken,
          mapViewState: mapViewState,
          isFollowingRunner: isFollowingRunner,
          recenterRequestId: recenterRequestId,
          onManualPan: onManualPan,
          onRecenter: onRecenter,
          showRecenterButton: showRecenterButton,
          recenterButtonBottom: recenterButtonBottom,
        ),
      ),
    );
  }

  void _debugLogMapboxBranch(String branch) {
    assert(() {
      debugPrint('Runiac Mapbox QA: $branch');
      return true;
    }());
  }
}

Widget _defaultMapboxBuilder(
  BuildContext context,
  RunMapboxSurfaceConfig config,
) {
  return RunMapboxRunMap(config: config);
}
