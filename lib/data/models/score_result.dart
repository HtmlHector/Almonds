import '../../core/theme/score_rating.dart';
import 'additive.dart';

enum LevelQuality { good, moderate, bad }

/// One nutrient row (per 100 g) with a traffic-light quality.
class NutrientLevel {
  const NutrientLevel({
    required this.label,
    required this.value,
    required this.unit,
    required this.quality,
    required this.positive,
  });

  final String label;
  final double value;
  final String unit;
  final LevelQuality quality;

  /// True for nutrients that are good in quantity (fibre, protein).
  final bool positive;
}

class ScoreResult {
  const ScoreResult({
    required this.score,
    required this.nutritionPoints,
    required this.additivePoints,
    required this.organicPoints,
    required this.flagged,
    required this.levels,
    required this.cappedByAdditive,
    required this.partialData,
  });

  /// 0–100, higher is better.
  final int score;

  /// 0–60. Null when no nutrition data exists for the product.
  final int? nutritionPoints;

  /// 0–30.
  final int additivePoints;

  /// 0 or 10.
  final int organicPoints;

  final List<Additive> flagged;
  final List<NutrientLevel> levels;

  /// True when a high-risk additive limited the final score.
  final bool cappedByAdditive;

  /// True when the nutrition sub-score had to be left out.
  final bool partialData;

  ScoreRating get rating => ScoreRating.fromScore(score);
}
