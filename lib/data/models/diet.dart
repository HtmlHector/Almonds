import 'product.dart';

/// Diets a user can follow. [tag] is the Open Food Facts ingredients-analysis
/// tag that must be present for a product to match.
enum Diet {
  vegan('Vegan', 'en:vegan', 'en:non-vegan'),
  vegetarian('Vegetarian', 'en:vegetarian', 'en:non-vegetarian'),
  palmOilFree('Palm-oil free', 'en:palm-oil-free', 'en:palm-oil');

  const Diet(this.label, this.tag, this.conflictTag);

  final String label;
  final String tag;
  final String conflictTag;
}

/// Allergens a user can avoid. [key] is the cleaned OFF allergen name.
enum Allergen {
  gluten('Gluten', 'gluten'),
  milk('Milk', 'milk'),
  eggs('Eggs', 'eggs'),
  nuts('Tree nuts', 'nuts'),
  peanuts('Peanuts', 'peanuts'),
  soy('Soy', 'soybeans'),
  fish('Fish', 'fish'),
  sesame('Sesame', 'sesame seeds'),
  crustaceans('Crustaceans', 'crustaceans'),
  molluscs('Molluscs', 'molluscs');

  const Allergen(this.label, this.key);

  final String label;
  final String key;
}

class DietPreferences {
  const DietPreferences({
    this.diets = const {},
    this.allergens = const {},
  });

  final Set<Diet> diets;
  final Set<Allergen> allergens;

  bool get isEmpty => diets.isEmpty && allergens.isEmpty;

  DietPreferences toggleDiet(Diet d) => DietPreferences(
    diets: diets.contains(d) ? ({...diets}..remove(d)) : {...diets, d},
    allergens: allergens,
  );

  DietPreferences toggleAllergen(Allergen a) => DietPreferences(
    diets: diets,
    allergens: allergens.contains(a)
        ? ({...allergens}..remove(a))
        : {...allergens, a},
  );

  factory DietPreferences.fromLists(
    List<String> diets,
    List<String> allergens,
  ) => DietPreferences(
    diets: {
      for (final d in Diet.values)
        if (diets.contains(d.name)) d,
    },
    allergens: {
      for (final a in Allergen.values)
        if (allergens.contains(a.name)) a,
    },
  );

  List<String> get dietNames => diets.map((d) => d.name).toList()..sort();
  List<String> get allergenNames =>
      allergens.map((a) => a.name).toList()..sort();
}

enum Verdict { match, conflict, unknown }

/// One line in the diet check, e.g. "Contains milk".
class DietFinding {
  const DietFinding(this.verdict, this.message);

  final Verdict verdict;
  final String message;
}

class DietCheck {
  const DietCheck(this.findings);

  final List<DietFinding> findings;

  List<DietFinding> get conflicts =>
      findings.where((f) => f.verdict == Verdict.conflict).toList();
  List<DietFinding> get unknowns =>
      findings.where((f) => f.verdict == Verdict.unknown).toList();

  bool get hasConflict => conflicts.isNotEmpty;
  bool get isEmpty => findings.isEmpty;

  /// Compares [product] with [prefs]. Pure function, easy to unit test.
  static DietCheck of(Product product, DietPreferences prefs) {
    final findings = <DietFinding>[];
    final analysis = product.ingredientsAnalysis;

    for (final diet in prefs.diets) {
      if (analysis.contains(diet.conflictTag)) {
        findings.add(
          DietFinding(Verdict.conflict, 'Not ${diet.label.toLowerCase()}'),
        );
      } else if (!analysis.contains(diet.tag)) {
        findings.add(
          DietFinding(
            Verdict.unknown,
            "Can't confirm it's ${diet.label.toLowerCase()}",
          ),
        );
      }
    }

    for (final allergen in prefs.allergens) {
      final label = allergen.label.toLowerCase();
      if (product.allergens.contains(allergen.key)) {
        findings.add(DietFinding(Verdict.conflict, 'Contains $label'));
      } else if (product.traces.contains(allergen.key)) {
        findings.add(
          DietFinding(Verdict.conflict, 'May contain traces of $label'),
        );
      }
    }
    return DietCheck(findings);
  }
}
