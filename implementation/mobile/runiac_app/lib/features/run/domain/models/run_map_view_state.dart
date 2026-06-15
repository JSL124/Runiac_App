import 'run_location_sample.dart';

class RunMapViewState {
  RunMapViewState({
    this.currentPosition,
    List<List<RunLocationSample>> routeSegments =
        const <List<RunLocationSample>>[],
  }) : routeSegments = List<List<RunLocationSample>>.unmodifiable(
         routeSegments.map(List<RunLocationSample>.unmodifiable),
       );

  const RunMapViewState.empty()
    : currentPosition = null,
      routeSegments = const <List<RunLocationSample>>[];

  final RunLocationSample? currentPosition;
  final List<List<RunLocationSample>> routeSegments;

  int get routePointCount {
    return routeSegments.fold<int>(
      0,
      (total, segment) => total + segment.length,
    );
  }

  bool get hasRoutePolyline {
    return routeSegments.any((segment) => segment.length > 1);
  }
}
