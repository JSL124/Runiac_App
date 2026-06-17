import 'run_location_sample.dart';

class RunMapViewState {
  RunMapViewState({
    this.previewPosition,
    this.currentPosition,
    List<List<RunLocationSample>> routeSegments =
        const <List<RunLocationSample>>[],
    List<List<RunLocationSample>>? acceptedRouteSegments,
  }) : acceptedRouteSegments = List<List<RunLocationSample>>.unmodifiable(
         (acceptedRouteSegments ?? routeSegments).map(
           List<RunLocationSample>.unmodifiable,
         ),
       );

  const RunMapViewState.empty()
    : previewPosition = null,
      currentPosition = null,
      acceptedRouteSegments = const <List<RunLocationSample>>[];

  final RunLocationSample? previewPosition;
  final RunLocationSample? currentPosition;
  final List<List<RunLocationSample>> acceptedRouteSegments;

  List<List<RunLocationSample>> get routeSegments => acceptedRouteSegments;

  RunLocationSample? get displayPosition {
    return currentPosition ?? previewPosition;
  }

  int get routePointCount {
    return acceptedRouteSegments.fold<int>(
      0,
      (total, segment) => total + segment.length,
    );
  }

  bool get hasRoutePolyline {
    return acceptedRouteSegments.any((segment) => segment.length > 1);
  }
}
