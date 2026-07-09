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

/// Hand-tuned normalized path anchors per background.
///
/// Each list holds the seven day-slot anchor points in 0..1 space, ordered
/// day 1 (near the bottom foreground) to day 7 (further up the receding path).
/// The coordinates were tuned by eye against each rendered background so the
/// stage stones sit visually on the drawn road/path.
const Map<String, List<Offset>> _kHomeStageAnchorsByAsset =
    <String, List<Offset>>{
  'assets/images/home/backgrounds/bg_gardens_by_the_bay.webp': <Offset>[
    Offset(0.40, 0.95),
    Offset(0.45, 0.85),
    Offset(0.54, 0.74),
    Offset(0.47, 0.64),
    Offset(0.42, 0.56),
    Offset(0.48, 0.50),
    Offset(0.53, 0.45),
  ],
  'assets/images/home/backgrounds/bg_east_coast_beach.webp': <Offset>[
    Offset(0.40, 0.95),
    Offset(0.34, 0.84),
    Offset(0.29, 0.72),
    Offset(0.37, 0.61),
    Offset(0.43, 0.51),
    Offset(0.43, 0.42),
    Offset(0.42, 0.33),
  ],
  'assets/images/home/backgrounds/bg_kampong_glam.webp': <Offset>[
    Offset(0.45, 0.93),
    Offset(0.47, 0.82),
    Offset(0.52, 0.70),
    Offset(0.45, 0.60),
    Offset(0.44, 0.50),
    Offset(0.50, 0.41),
    Offset(0.53, 0.32),
  ],
  'assets/images/home/backgrounds/bg_clarke_quay_night.webp': <Offset>[
    Offset(0.38, 0.94),
    Offset(0.29, 0.83),
    Offset(0.40, 0.71),
    Offset(0.51, 0.60),
    Offset(0.56, 0.50),
    Offset(0.55, 0.41),
    Offset(0.52, 0.33),
  ],
  'assets/images/home/backgrounds/bg_supertree_grove.webp': <Offset>[
    Offset(0.45, 0.94),
    Offset(0.38, 0.83),
    Offset(0.42, 0.72),
    Offset(0.39, 0.62),
    Offset(0.35, 0.53),
    Offset(0.33, 0.47),
    Offset(0.34, 0.43),
  ],
  'assets/images/home/backgrounds/bg_marina_bay_sunset.webp': <Offset>[
    Offset(0.31, 0.94),
    Offset(0.28, 0.83),
    Offset(0.38, 0.72),
    Offset(0.47, 0.61),
    Offset(0.51, 0.52),
    Offset(0.51, 0.44),
    Offset(0.50, 0.39),
  ],
  'assets/images/home/backgrounds/bg_jewel_waterfall.webp': <Offset>[
    Offset(0.34, 0.94),
    Offset(0.35, 0.84),
    Offset(0.41, 0.74),
    Offset(0.45, 0.65),
    Offset(0.44, 0.57),
    Offset(0.41, 0.51),
    Offset(0.44, 0.47),
  ],
  'assets/images/home/backgrounds/bg_palawan_sunset.webp': <Offset>[
    Offset(0.34, 0.94),
    Offset(0.27, 0.83),
    Offset(0.35, 0.72),
    Offset(0.42, 0.61),
    Offset(0.44, 0.52),
    Offset(0.44, 0.44),
    Offset(0.43, 0.37),
  ],
};

const List<Offset> _kFallbackStageAnchors = <Offset>[
  Offset(0.38, 0.94),
  Offset(0.34, 0.83),
  Offset(0.42, 0.72),
  Offset(0.47, 0.61),
  Offset(0.45, 0.52),
  Offset(0.43, 0.44),
  Offset(0.44, 0.37),
];

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
