import 'dart:ui' show Offset;

/// Full-bleed cartoon Singapore backgrounds used for the Home stage map.
///
/// Every asset is a 941:1672 scene with a winding path receding from the
/// bottom foreground toward the top. One background is assigned per plan week.
const List<String> kHomeStageBackgroundAssets = <String>[
  'assets/images/home/backgrounds/bg_gardens_by_the_bay.webp',
  'assets/images/home/backgrounds/bg_east_coast_beach.webp',
  'assets/images/home/backgrounds/bg_kampong_glam.webp',
  'assets/images/home/backgrounds/bg_clarke_quay_night.webp',
  'assets/images/home/backgrounds/bg_supertree_grove.webp',
  'assets/images/home/backgrounds/bg_marina_bay_sunset.webp',
  'assets/images/home/backgrounds/bg_jewel_waterfall.webp',
  'assets/images/home/backgrounds/bg_palawan_sunset.webp',
];

/// Aspect ratio (height / width) of every background asset (1672 / 941).
const double kHomeStageBackgroundAspect = 1672 / 941;

/// Shared vertical (dy) sequence for the seven day-slot anchors, day 1 (near
/// the bottom foreground) to day 7 (further up the receding path).
///
/// Spacing is uniform by design (equal 0.095 steps) so stage stones sit at
/// consistent vertical intervals on every background, regardless of how
/// winding that background's path is. Horizontal (dx) placement below stays
/// hand-tuned per background so the path itself keeps its natural curve.
const List<double> _kHomeStageAnchorDys = <double>[
  0.94,
  0.845,
  0.75,
  0.655,
  0.56,
  0.465,
  0.37,
];

/// Builds the 7 anchor points for a background from its hand-tuned dx values,
/// pairing each with the shared uniform [_kHomeStageAnchorDys] sequence.
List<Offset> _anchorsFromDx(List<double> dxValues) {
  return [
    for (var i = 0; i < dxValues.length; i++)
      Offset(dxValues[i], _kHomeStageAnchorDys[i]),
  ];
}

/// Hand-tuned horizontal (dx) path anchors per background, in 0..1 space.
///
/// The dx coordinates were tuned by eye against each rendered background so
/// the stage stones sit visually on the drawn road/path; dy is uniform (see
/// [_kHomeStageAnchorDys]) and shared across every background.
final Map<String, List<Offset>> _kHomeStageAnchorsByAsset = <String, List<Offset>>{
  'assets/images/home/backgrounds/bg_gardens_by_the_bay.webp': _anchorsFromDx(
    const <double>[0.40, 0.45, 0.54, 0.47, 0.42, 0.48, 0.53],
  ),
  'assets/images/home/backgrounds/bg_east_coast_beach.webp': _anchorsFromDx(
    const <double>[0.40, 0.34, 0.29, 0.37, 0.43, 0.43, 0.42],
  ),
  'assets/images/home/backgrounds/bg_kampong_glam.webp': _anchorsFromDx(
    const <double>[0.45, 0.47, 0.52, 0.45, 0.44, 0.50, 0.53],
  ),
  'assets/images/home/backgrounds/bg_clarke_quay_night.webp': _anchorsFromDx(
    const <double>[0.38, 0.29, 0.40, 0.51, 0.56, 0.55, 0.52],
  ),
  'assets/images/home/backgrounds/bg_supertree_grove.webp': _anchorsFromDx(
    const <double>[0.45, 0.38, 0.42, 0.39, 0.35, 0.33, 0.34],
  ),
  'assets/images/home/backgrounds/bg_marina_bay_sunset.webp': _anchorsFromDx(
    const <double>[0.31, 0.28, 0.38, 0.47, 0.51, 0.51, 0.50],
  ),
  'assets/images/home/backgrounds/bg_jewel_waterfall.webp': _anchorsFromDx(
    const <double>[0.34, 0.35, 0.41, 0.45, 0.44, 0.41, 0.44],
  ),
  'assets/images/home/backgrounds/bg_palawan_sunset.webp': _anchorsFromDx(
    const <double>[0.34, 0.27, 0.35, 0.42, 0.44, 0.44, 0.43],
  ),
};

final List<Offset> _kFallbackStageAnchors = _anchorsFromDx(
  const <double>[0.38, 0.34, 0.42, 0.47, 0.45, 0.43, 0.44],
);

/// Normalized 7-point path anchors for [backgroundAsset].
List<Offset> homeStageAnchorsForBackground(String backgroundAsset) {
  return _kHomeStageAnchorsByAsset[backgroundAsset] ?? _kFallbackStageAnchors;
}

/// Stable 32-bit FNV-1a hash over the UTF-16 code units of [input].
///
/// Used instead of [String.hashCode] because the latter is not guaranteed to
/// be stable across Dart runtimes/sessions. This function is a pure, stable
/// mapping so a given plan id always yields the same background ordering.
int stableFnv1aHash(String input) {
  const int fnvOffsetBasis = 0x811c9dc5;
  const int fnvPrime = 0x01000193;
  var hash = fnvOffsetBasis;
  for (var i = 0; i < input.length; i++) {
    hash ^= input.codeUnitAt(i);
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }
  return hash;
}

/// Deterministic background ordering for a plan.
///
/// The sequence is derived only from [planId] (via [stableFnv1aHash] seeding a
/// small LCG), so the same plan id yields an identical sequence every session
/// with no persistence. A chosen background never equals either of the two
/// backgrounds used immediately before it, avoiding visible repeats.
List<String> homeStageBackgroundSequence({
  required String planId,
  required int weekCount,
  List<String> palette = kHomeStageBackgroundAssets,
}) {
  if (weekCount <= 0 || palette.isEmpty) {
    return const <String>[];
  }
  if (palette.length == 1) {
    return List<String>.filled(weekCount, palette.first);
  }

  var state = stableFnv1aHash('runiac-stage-bg::$planId');
  int nextRandom() {
    // Numerical Recipes LCG constants; keeps values within 32 bits.
    state = (state * 1664525 + 1013904223) & 0xFFFFFFFF;
    return state;
  }

  final result = <String>[];
  String? previous;
  String? beforePrevious;
  for (var week = 0; week < weekCount; week++) {
    final candidates = <String>[
      for (final option in palette)
        if (option != previous && option != beforePrevious) option,
    ];
    // With a palette of 3+ entries the exclusion of the last two used
    // backgrounds always leaves at least one candidate.
    final pool = candidates.isEmpty ? palette : candidates;
    final choice = pool[nextRandom() % pool.length];
    result.add(choice);
    beforePrevious = previous;
    previous = choice;
  }
  return result;
}
