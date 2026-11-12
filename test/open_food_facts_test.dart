import 'dart:convert';

import 'package:almonds/data/models/product.dart';
import 'package:almonds/data/services/open_food_facts_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  OpenFoodFactsClient clientReturning(http.Response Function(http.Request) h) =>
      OpenFoodFactsClient(client: MockClient((r) async => h(r)));

  group('OpenFoodFactsClient', () {
    test('parses a found product', () async {
      final client = clientReturning(
        (_) => http.Response(
          jsonEncode({
            'status': 1,
            'product': {
              'product_name': 'Nutella',
              'brands': 'Ferrero, Nutella',
              'ingredients_text': 'Sugar, palm oil',
              'nutriscore_grade': 'e',
              'nova_group': 4,
              'labels_tags': ['en:vegetarian'],
              'nutriments': {'energy-kcal_100g': 539, 'sugars_100g': 56.3},
            },
          }),
          200,
        ),
      );
      final p = await client.fetch('3017620422003');
      expect(p.name, 'Nutella');
      expect(p.brand, 'Ferrero');
      expect(p.nutriScoreGrade, 'e');
      expect(p.novaGroup, 4);
      expect(p.nutriments.sugars, 56.3);
      expect(p.isOrganic, isFalse);
    });

    test('status 0 means not found', () {
      final client = clientReturning(
        (_) => http.Response(jsonEncode({'status': 0}), 200),
      );
      expect(
        client.fetch('3017620422003'),
        throwsA(isA<ProductNotFoundException>()),
      );
    });

    test('rejects malformed barcodes without a network call', () {
      var called = false;
      final client = clientReturning((_) {
        called = true;
        return http.Response('{}', 200);
      });
      expect(client.fetch('abc'), throwsA(isA<ProductNotFoundException>()));
      expect(called, isFalse);
    });

    test('server errors and bad JSON become LookupFailedException', () {
      expect(
        clientReturning((_) => http.Response('boom', 500)).fetch('3017620422003'),
        throwsA(isA<LookupFailedException>()),
      );
      expect(
        clientReturning((_) => http.Response('<html>', 200)).fetch('3017620422003'),
        throwsA(isA<LookupFailedException>()),
      );
    });

    test('network failure becomes LookupFailedException', () {
      final client = OpenFoodFactsClient(
        client: MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(client.fetch('3017620422003'), throwsA(isA<LookupFailedException>()));
    });
  });

  group('Product', () {
    test('survives missing fields', () {
      final p = Product.fromOff('123456', {});
      expect(p.name, 'Unnamed product');
      expect(p.nutriments.isEmpty, isTrue);
      expect(p.hasIngredients, isFalse);
    });

    test('converts sodium to salt and kJ to kcal', () {
      final p = Product.fromOff('123456', {
        'nutriments': {'sodium_100g': 0.4, 'energy-kj_100g': 418.4},
      });
      expect(p.nutriments.salt, closeTo(1.0, 1e-9));
      expect(p.nutriments.energyKcal, closeTo(100, 1e-6));
    });

    test('round-trips through JSON', () {
      final original = Product.fromOff('123456', {
        'product_name': 'X',
        'labels_tags': ['en:organic'],
        'nutriments': {'sugars_100g': 3, 'salt_100g': 1},
      });
      final copy = Product.fromJson(original.toJson());
      expect(copy.name, 'X');
      expect(copy.isOrganic, isTrue);
      expect(copy.nutriments.sugars, 3);
    });
  });
}
