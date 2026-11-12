import 'package:almonds/data/models/diet.dart';
import 'package:almonds/data/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

Product product({
  List<String> analysis = const [],
  List<String> allergens = const [],
  List<String> traces = const [],
}) => Product(
  barcode: '1234567890123',
  name: 'Test',
  ingredientsAnalysis: analysis,
  allergens: allergens,
  traces: traces,
);

void main() {
  group('DietCheck', () {
    test('no preferences means no findings', () {
      final c = DietCheck.of(product(), const DietPreferences());
      expect(c.isEmpty, isTrue);
      expect(c.hasConflict, isFalse);
    });

    test('vegan product matches a vegan diet', () {
      final c = DietCheck.of(
        product(analysis: ['en:vegan', 'en:vegetarian']),
        const DietPreferences(diets: {Diet.vegan}),
      );
      expect(c.isEmpty, isTrue);
    });

    test('non-vegan product conflicts with a vegan diet', () {
      final c = DietCheck.of(
        product(analysis: ['en:non-vegan']),
        const DietPreferences(diets: {Diet.vegan}),
      );
      expect(c.hasConflict, isTrue);
      expect(c.conflicts.single.message, 'Not vegan');
    });

    test('missing analysis is unknown, never a silent match', () {
      final c = DietCheck.of(
        product(),
        const DietPreferences(diets: {Diet.vegetarian}),
      );
      expect(c.hasConflict, isFalse);
      expect(c.unknowns, hasLength(1));
    });

    test('palm oil conflicts with palm-oil-free', () {
      final c = DietCheck.of(
        product(analysis: ['en:palm-oil']),
        const DietPreferences(diets: {Diet.palmOilFree}),
      );
      expect(c.hasConflict, isTrue);
    });

    test('allergens and traces both conflict', () {
      final c = DietCheck.of(
        product(allergens: ['milk'], traces: ['nuts']),
        const DietPreferences(allergens: {Allergen.milk, Allergen.nuts, Allergen.eggs}),
      );
      expect(c.conflicts.map((f) => f.message), containsAll([
        'Contains milk',
        'May contain traces of tree nuts',
      ]));
      expect(c.conflicts, hasLength(2)); // eggs not present
    });
  });

  group('DietPreferences', () {
    test('toggle adds and removes', () {
      var p = const DietPreferences();
      p = p.toggleDiet(Diet.vegan).toggleAllergen(Allergen.soy);
      expect(p.diets, {Diet.vegan});
      expect(p.allergens, {Allergen.soy});
      p = p.toggleDiet(Diet.vegan);
      expect(p.diets, isEmpty);
    });

    test('round-trips through stored names and ignores unknown values', () {
      final p = DietPreferences.fromLists(
        ['vegan', 'not-a-diet'],
        ['gluten', 'bogus'],
      );
      expect(p.diets, {Diet.vegan});
      expect(p.allergens, {Allergen.gluten});
      expect(p.dietNames, ['vegan']);
      expect(p.allergenNames, ['gluten']);
    });
  });
}
