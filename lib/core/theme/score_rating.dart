import 'package:flutter/painting.dart';

/// Four-band rating used everywhere a score is shown.
enum ScoreRating {
  excellent('Excellent', Color(0xFF30B35F)),
  good('Good', Color(0xFF86B817)),
  mediocre('Mediocre', Color(0xFFFF9F0A)),
  poor('Poor', Color(0xFFFF453A));

  const ScoreRating(this.label, this.color);

  final String label;
  final Color color;

  static ScoreRating fromScore(int score) {
    if (score >= 75) return ScoreRating.excellent;
    if (score >= 50) return ScoreRating.good;
    if (score >= 25) return ScoreRating.mediocre;
    return ScoreRating.poor;
  }
}
