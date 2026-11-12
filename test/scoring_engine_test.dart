import 'package:almonds/data/models/nutriments.dart';
import 'package:almonds/data/models/product.dart';
import 'package:almonds/data/services/additive_catalog.dart';
import 'package:almonds/data/services/scoring_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdditiveCatalog catalog;
  late ScoringEngine engine;

  setUpAll(() async {
    catalog = await AdditiveCatalog.load();
    engine = ScoringEngine(catalog);
  });

  Product product({
    String ingredients = '',
    Nutriments nutriments = const Nutriments(),
    List<String> labels = const [],
    List<String> additiveTags = const [],
  }) => Product(
    barcode: '1234567890123',
    name: 'Test',
    ingredientsText: ingredients,
    nutriments: nutriments,
    labels: labels,
    additiveTags: additiveTags,
  );

  const healthy = Nutriments(
    energyKcal: 40,
    sugars: 1,
    saturatedFat: 0.1,
    salt: 0.05,
    fiber: 4,
    protein: 5,
  );

  group('additive matching', () {
    test('matches by name, E-number and alias', () {
      final byName = catalog.findIn('water, red 40, sugar');
      final byE = catalog.findIn('colour (E-102)');
      final byAlias = catalog.findIn('tartrazine');
      expect(byName.map((a) => a.name), ['Red 40']);
      expect(byE.map((a) => a.name), ['Yellow 5']);
      expect(byAlias.map((a) => a.name), ['Yellow 5']);
    });

    test('respects word boundaries', () {
      expect(catalog.findIn('blue 12'), isEmpty);
      expect(catalog.findIn('a red 400 dye'), isEmpty);
      expect(catalog.findIn('bhat'), isEmpty);
    });

    test('uses OFF additive tags', () {
      final found = catalog.findIn('', additiveTags: ['en:e171']);
      expect(found.map((a) => a.name), ['Titanium Dioxide']);
    });
  });

  group('nutrition', () {
    test('Nutella-like profile gets the worst Nutri-Score bracket', () {
      const nutella = Nutriments(
        energyKcal: 539,
        sugars: 56.3,
        saturatedFat: 10.6,
        salt: 0.107,
        fiber: 0,
        protein: 6.3,
      );
      expect(ScoringEngine.nutriScoreRaw(nutella), 26);
      expect(ScoringEngine.nutritionPoints(nutella), 15);
    });

    test('plain healthy food scores near the top', () {
      expect(ScoringEngine.nutritionPoints(healthy), greaterThan(50));
    });

    test('returns null when key nutrients are missing', () {
      expect(ScoringEngine.nutriScoreRaw(const Nutriments(sugars: 3)), isNull);
    });
  });

  group('overall score', () {
    test('clean, healthy, organic product scores excellent', () {
      final r = engine.score(
        product(
          ingredients: 'oats, water',
          nutriments: healthy,
          labels: ['en:organic'],
        ),
      );
      expect(r.score, greaterThanOrEqualTo(90));
      expect(r.flagged, isEmpty);
      expect(r.organicPoints, 10);
    });

    test('additives reduce the additive sub-score by severity', () {
      final r = engine.score(
        product(ingredients: 'water, aspartame, red 40', nutriments: healthy),
      );
      expect(r.flagged.length, 2);
      expect(r.additivePoints, 30 - 8 - 8);
    });

    test('a high-risk additive caps the score', () {
      final r = engine.score(
        product(
          ingredients: 'pork, sodium nitrite',
          nutriments: healthy,
          labels: ['en:organic'],
        ),
      );
      expect(r.score, ScoringEngine.highRiskCap);
      expect(r.cappedByAdditive, isTrue);
    });

    test('missing nutrition is rescaled, not punished, and flagged partial', () {
      final r = engine.score(product(ingredients: 'water, salt'));
      expect(r.partialData, isTrue);
      expect(r.nutritionPoints, isNull);
      expect(r.score, greaterThan(50));
    });

    test('score always stays within 0-100', () {
      final r = engine.score(
        product(
          ingredients:
              'red 40, yellow 5, yellow 6, blue 1, blue 2, aspartame, '
              'sodium nitrite, bha, bht, potassium bromate',
          nutriments: const Nutriments(
            energyKcal: 900,
            sugars: 90,
            saturatedFat: 40,
            salt: 10,
          ),
        ),
      );
      expect(r.score, inInclusiveRange(0, 100));
      expect(r.additivePoints, 0);
    });
  });
}
