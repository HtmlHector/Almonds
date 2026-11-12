/// Nutrition facts per 100 g / 100 ml. Every value is optional because
/// Open Food Facts data is crowd-sourced and frequently incomplete.
class Nutriments {
  const Nutriments({
    this.energyKcal,
    this.fat,
    this.saturatedFat,
    this.carbohydrates,
    this.sugars,
    this.fiber,
    this.protein,
    this.salt,
  });

  final double? energyKcal;
  final double? fat;
  final double? saturatedFat;
  final double? carbohydrates;
  final double? sugars;
  final double? fiber;
  final double? protein;
  final double? salt;

  /// Energy in kilojoules (derived; 1 kcal = 4.184 kJ).
  double? get energyKj => energyKcal == null ? null : energyKcal! * 4.184;

  /// Sodium in milligrams (derived from salt; salt = sodium × 2.5).
  double? get sodiumMg => salt == null ? null : salt! / 2.5 * 1000;

  bool get isEmpty =>
      energyKcal == null &&
      sugars == null &&
      saturatedFat == null &&
      salt == null &&
      protein == null &&
      fiber == null;

  static double? _num(Object? v) => v is num ? v.toDouble() : null;

  factory Nutriments.fromOff(Map<String, dynamic>? json) {
    if (json == null) return const Nutriments();
    double? kcal = _num(json['energy-kcal_100g']);
    // Some entries only carry kJ.
    final kj = _num(json['energy-kj_100g']) ?? _num(json['energy_100g']);
    kcal ??= kj == null ? null : kj / 4.184;
    return Nutriments(
      energyKcal: kcal,
      fat: _num(json['fat_100g']),
      saturatedFat: _num(json['saturated-fat_100g']),
      carbohydrates: _num(json['carbohydrates_100g']),
      sugars: _num(json['sugars_100g']),
      fiber: _num(json['fiber_100g']),
      protein: _num(json['proteins_100g']),
      salt:
          _num(json['salt_100g']) ??
          (_num(json['sodium_100g']) == null
              ? null
              : _num(json['sodium_100g'])! * 2.5),
    );
  }

  factory Nutriments.fromJson(Map<String, dynamic> json) => Nutriments(
    energyKcal: _num(json['energyKcal']),
    fat: _num(json['fat']),
    saturatedFat: _num(json['saturatedFat']),
    carbohydrates: _num(json['carbohydrates']),
    sugars: _num(json['sugars']),
    fiber: _num(json['fiber']),
    protein: _num(json['protein']),
    salt: _num(json['salt']),
  );

  Map<String, dynamic> toJson() => {
    'energyKcal': energyKcal,
    'fat': fat,
    'saturatedFat': saturatedFat,
    'carbohydrates': carbohydrates,
    'sugars': sugars,
    'fiber': fiber,
    'protein': protein,
    'salt': salt,
  };
}
