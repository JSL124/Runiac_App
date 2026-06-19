enum CoachingSummarySource {
  ruleBased,
  aiGenerated;

  String get sectionTitle {
    return switch (this) {
      CoachingSummarySource.ruleBased => 'Coaching Summary',
      CoachingSummarySource.aiGenerated => 'AI Coaching Summary',
    };
  }
}

class CoachingSummarySnapshot {
  const CoachingSummarySnapshot({
    required CoachingSummarySource source,
    required String headline,
    required String message,
    required String nextAction,
    List<String> bullets = const [],
  }) : this._(
         source: source,
         headline: headline,
         message: message,
         nextAction: nextAction,
         bullets: bullets,
       );

  const CoachingSummarySnapshot._({
    required this.source,
    required this.headline,
    required this.message,
    required this.nextAction,
    required this._bullets,
  });

  final CoachingSummarySource source;
  final String headline;
  final String message;
  final List<String> _bullets;
  final String nextAction;

  String get sectionTitle => source.sectionTitle;
  List<String> get bullets => List.unmodifiable(_bullets);
}
