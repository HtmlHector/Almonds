import '../models/product.dart';
import '../models/score_result.dart';
import 'open_food_facts_client.dart';
import 'product_cache.dart';
import 'scoring_engine.dart';

/// A product plus its computed score, used for lists of suggestions.
class ScoredProduct {
  const ScoredProduct(this.product, this.result);

  final Product product;
  final ScoreResult result;
}

/// Single entry point the UI uses to get products: network first, with a
/// local fallback when offline, plus search and healthier alternatives.
class ProductService {
  ProductService({
    required this.client,
    required this.engine,
    ProductCache? cache,
  }) : cache = cache ?? ProductCache();

  final OpenFoodFactsClient client;
  final ScoringEngine engine;
  final ProductCache cache;

  /// Looks up a barcode. If the network is down, a previously viewed copy is
  /// returned instead; "not found" is never masked by the cache.
  Future<Product> lookup(String barcode) async {
    try {
      final product = await client.fetch(barcode);
      await cache.put(product);
      return product;
    } on LookupFailedException {
      final cached = await cache.get(barcode.trim());
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<List<ScoredProduct>> search(String query) async {
    final results = await client.search(query);
    return [for (final p in results) ScoredProduct(p, engine.score(p))];
  }

  /// Better-scoring products from the same category, best first.
  /// Returns an empty list (never throws) when nothing suitable is found or
  /// the service is unavailable: suggestions are a bonus, not critical.
  Future<List<ScoredProduct>> alternatives(
    Product product,
    int currentScore, {
    int minImprovement = 10,
    int limit = 6,
  }) async {
    if (product.categoryTags.isEmpty) return const [];

    // Most specific categories come last; try a couple of them.
    final tags = product.categoryTags
        .where((t) => t.startsWith('en:'))
        .toList()
        .reversed
        .take(2)
        .toList();

    for (final tag in tags) {
      final found = <String, ScoredProduct>{};
      for (final grade in const ['a', 'b']) {
        try {
          for (final p in await client.byCategory(tag, grade)) {
            if (p.barcode == product.barcode) continue;
            found.putIfAbsent(
              p.barcode,
              () => ScoredProduct(p, engine.score(p)),
            );
          }
        } on Object {
          // Skip this grade; try the rest.
        }
      }
      final better =
          found.values
              .where((s) => s.result.score >= currentScore + minImprovement)
              .toList()
            ..sort((a, b) => b.result.score.compareTo(a.result.score));
      if (better.isNotEmpty) return better.take(limit).toList();
    }
    return const [];
  }
}
