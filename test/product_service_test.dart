import 'dart:convert';

import 'package:almonds/data/models/product.dart';
import 'package:almonds/data/services/additive_catalog.dart';
import 'package:almonds/data/services/open_food_facts_client.dart';
import 'package:almonds/data/services/product_cache.dart';
import 'package:almonds/data/services/product_service.dart';
import 'package:almonds/data/services/scoring_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _healthy = {
  'energy-kcal_100g': 40,
  'sugars_100g': 1,
  'saturated-fat_100g': 0.1,
  'salt_100g': 0.05,
  'fiber_100g': 4,
  'proteins_100g': 5,
};

Map<String, dynamic> offProduct(String code, String name, {Map? nutriments}) => {
  'code': code,
  'product_name': name,
  'nutriments': nutriments ?? _healthy,
  'categories_tags': ['en:foods', 'en:spreads'],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScoringEngine engine;

  setUpAll(() async {
    engine = ScoringEngine(await AdditiveCatalog.load());
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  ProductService service(http.Response Function(http.Request) handler) =>
      ProductService(
        client: OpenFoodFactsClient(
          client: MockClient((r) async => handler(r)),
        ),
        engine: engine,
      );

  group('lookup + offline cache', () {
    test('falls back to the cached copy when the network fails', () async {
      var online = true;
      final s = service((_) {
        if (!online) throw http.ClientException('offline');
        return http.Response(
          jsonEncode({'status': 1, 'product': offProduct('3017620422003', 'Nutella')}),
          200,
        );
      });

      expect((await s.lookup('3017620422003')).name, 'Nutella');
      online = false;
      expect((await s.lookup('3017620422003')).name, 'Nutella');
    });

    test('offline and never seen: the error is surfaced', () {
      final s = service((_) => throw http.ClientException('offline'));
      expect(s.lookup('3017620422003'), throwsA(isA<LookupFailedException>()));
    });

    test('not-found is not masked by a cached copy', () async {
      final cache = ProductCache();
      await cache.put(const Product(barcode: '3017620422003', name: 'Old'));
      final s = ProductService(
        client: OpenFoodFactsClient(
          client: MockClient(
            (_) async => http.Response(jsonEncode({'status': 0}), 200),
          ),
        ),
        engine: engine,
        cache: cache,
      );
      expect(s.lookup('3017620422003'), throwsA(isA<ProductNotFoundException>()));
    });
  });

  group('cache', () {
    test('keeps the newest entries up to its capacity', () async {
      final cache = ProductCache(capacity: 2);
      for (final code in ['111111', '222222', '333333']) {
        await cache.put(Product(barcode: code, name: code));
      }
      expect(await cache.get('111111'), isNull);
      expect((await cache.get('333333'))?.name, '333333');
    });

    test('survives corrupt stored data', () async {
      SharedPreferences.setMockInitialValues({'product_cache_v1': 'not json'});
      expect(await ProductCache().get('111111'), isNull);
    });
  });

  group('search', () {
    test('skips products without a name and scores the rest', () async {
      final s = service(
        (_) => http.Response(
          jsonEncode({
            'products': [
              offProduct('1111111111111', 'Oat drink'),
              {'code': '2222222222222', 'product_name': '   '},
              offProduct('3333333333333', 'Rice cakes'),
            ],
          }),
          200,
        ),
      );
      final results = await s.search('oat');
      expect(results.map((r) => r.product.name), ['Oat drink', 'Rice cakes']);
      expect(results.first.result.score, greaterThan(50));
    });

    test('queries shorter than 2 characters do no network call', () async {
      var calls = 0;
      final s = service((_) {
        calls++;
        return http.Response('{}', 200);
      });
      expect(await s.search('a'), isEmpty);
      expect(calls, 0);
    });
  });

  group('alternatives', () {
    const junk = Product(
      barcode: '9999999999999',
      name: 'Junk',
      categoryTags: ['en:foods', 'en:spreads'],
    );

    test('returns only clearly better products, best first, no self', () async {
      final s = service(
        (_) => http.Response(
          jsonEncode({
            'products': [
              offProduct('9999999999999', 'Junk'), // itself: excluded
              offProduct('1111111111111', 'Good'),
              offProduct('2222222222222', 'Sugary', nutriments: {
                'energy-kcal_100g': 520,
                'sugars_100g': 55,
                'saturated-fat_100g': 10,
                'salt_100g': 0.1,
              }),
            ],
          }),
          200,
        ),
      );
      final alts = await s.alternatives(junk, 40);
      expect(alts.map((a) => a.product.name), ['Good']);
    });

    test('is empty (never throws) when the service is down', () async {
      final s = service((_) => http.Response('<html>unavailable</html>', 200));
      expect(await s.alternatives(junk, 20), isEmpty);
    });

    test('is empty when the product has no category', () async {
      final s = service((_) => http.Response('{}', 200));
      expect(
        await s.alternatives(
          const Product(barcode: '9999999999999', name: 'X'),
          20,
        ),
        isEmpty,
      );
    });
  });
}
