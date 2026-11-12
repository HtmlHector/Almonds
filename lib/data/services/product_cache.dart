import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

/// Remembers the most recently viewed products so they still open offline.
class ProductCache {
  ProductCache({this.capacity = 40});

  final int capacity;
  static const _key = 'product_cache_v1';

  Future<List<Product>> _read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
    } catch (_) {
      return []; // a corrupt cache must never break the app
    }
  }

  Future<Product?> get(String barcode) async {
    for (final p in await _read()) {
      if (p.barcode == barcode) return p;
    }
    return null;
  }

  Future<void> put(Product product) async {
    try {
      final items = await _read();
      items.removeWhere((p) => p.barcode == product.barcode);
      items.insert(0, product);
      if (items.length > capacity) items.removeRange(capacity, items.length);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(items.map((p) => p.toJson()).toList()),
      );
    } catch (_) {
      /* caching is best-effort */
    }
  }
}
