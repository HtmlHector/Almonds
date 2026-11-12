import '../models/additive.dart';
import '../models/nutriments.dart';
import '../models/product.dart';
import '../models/score_result.dart';
import 'additive_catalog.dart';

/// Computes a 0–100 health score:
///
///  * 60 pts – nutrition (Nutri-Score style points from per-100 g values)
///  * 30 pts – additives (each flagged additive removes points by severity)
///  * 10 pts – organic label
///
/// A product containing a high-risk additive can never score above
/// [highRiskCap], mirroring how consumer scanners treat "risky" products.
class ScoringEngine {
  ScoringEngine(this.catalog);

  final AdditiveCatalog catalog;

  static const highRiskCap = 49;

  ScoreResult score(Product product) {
    final flagged = catalog.findIn(
      product.ingredientsText,
      additiveTags: product.additiveTags,
    );

    final nutritionPts = nutritionPoints(product.nutriments);

    var additivePts = 30;
    for (final a in flagged) {
      additivePts -= a.severity.penalty;
    }
    additivePts = additivePts.clamp(0, 30);

    final organicPts = product.isOrganic ? 10 : 0;

    // With no nutrition data, rescale the remaining 40 points to 100 so a
    // missing panel doesn't automatically sink the score.
    var total = nutritionPts == null
        ? ((additivePts + organicPts) / 40 * 100).round()
        : nutritionPts + additivePts + organicPts;

    final hasHighRisk = flagged.any((a) => a.severity == Severity.high);
    var capped = false;
    if (hasHighRisk && total > highRiskCap) {
      total = highRiskCap;
      capped = true;
    }

    return ScoreResult(
      score: total.clamp(0, 100),
      nutritionPoints: nutritionPts,
      additivePoints: additivePts,
      organicPoints: organicPts,
      flagged: flagged..sort((a, b) => b.severity.index - a.severity.index),
      levels: nutrientLevels(product.nutriments),
      cappedByAdditive: capped,
      partialData: nutritionPts == null,
    );
  }

  // ---- Nutrition ---------------------------------------------------------

  /// Nutri-Score (2017, general foods) raw score: −15 (best) … 40 (worst).
  /// Null when there isn't enough data to compute it.
  static int? nutriScoreRaw(Nutriments n) {
    if (n.energyKcal == null || n.sugars == null || n.salt == null) return null;

    int step(double v, double size, {int max = 10}) {
      if (v <= size) return 0;
      return ((v / size).ceil() - 1).clamp(0, max);
    }

    final negative =
        step(n.energyKj!, 335) +
        step(n.sugars!, 4.5) +
        step(n.saturatedFat ?? 0, 1) +
        step(n.sodiumMg!, 90);

    int bands(double v, List<double> limits) =>
        limits.where((l) => v > l).length;

    final fibre = bands(n.fiber ?? 0, [0.9, 1.9, 2.8, 3.7, 4.7]);
    final protein = bands(n.protein ?? 0, [1.6, 3.2, 4.8, 6.4, 8.0]);

    // Protein is ignored when negative points are already high.
    return negative - fibre - (negative >= 11 ? 0 : protein);
  }

  /// Maps the raw Nutri-Score onto 0–60. Null when data is insufficient.
  static int? nutritionPoints(Nutriments n) {
    final raw = nutriScoreRaw(n);
    if (raw == null) return null;
    return (60 * (40 - raw) / 55).round().clamp(0, 60);
  }

  // ---- Per-nutrient traffic lights --------------------------------------

  static List<NutrientLevel> nutrientLevels(Nutriments n) {
    NutrientLevel? build(
      String label,
      double? v,
      String unit,
      double low,
      double high, {
      bool positive = false,
    }) {
      if (v == null) return null;
      LevelQuality q;
      if (positive) {
        q = v >= high
            ? LevelQuality.good
            : v >= low
            ? LevelQuality.moderate
            : LevelQuality.bad;
        // Missing fibre/protein is neutral, not "bad".
        if (q == LevelQuality.bad) q = LevelQuality.moderate;
      } else {
        q = v <= low
            ? LevelQuality.good
            : v <= high
            ? LevelQuality.moderate
            : LevelQuality.bad;
      }
      return NutrientLevel(
        label: label,
        value: v,
        unit: unit,
        quality: q,
        positive: positive,
      );
    }

    return [
      build('Calories', n.energyKcal, 'kcal', 150, 350),
      build('Sugars', n.sugars, 'g', 5, 22.5),
      build('Saturated fat', n.saturatedFat, 'g', 1.5, 5),
      build('Salt', n.salt, 'g', 0.3, 1.5),
      build('Fibre', n.fiber, 'g', 3, 6, positive: true),
      build('Protein', n.protein, 'g', 5, 10, positive: true),
    ].whereType<NutrientLevel>().toList();
  }
}
