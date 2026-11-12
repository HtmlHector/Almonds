import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/env.dart';
import '../models/product.dart';

class ProductNotFoundException implements Exception {
  const ProductNotFoundException(this.barcode);
  final String barcode;

  @override
  String toString() => 'No product found for barcode $barcode';
}

class LookupFailedException implements Exception {
  const LookupFailedException([
    this.message = 'Could not reach the product database.',
  ]);
  final String message;

  @override
  String toString() => message;
}

class OpenFoodFactsClient {
  OpenFoodFactsClient({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _fields =
      'code,product_name,brands,image_front_url,image_url,'
      'quantity,ingredients_text,nutriments,nutriscore_grade,nova_group,'
      'labels_tags,additives_tags,allergens_tags,traces_tags,categories_tags,'
      'ingredients_analysis_tags';

  static const _headers = {'User-Agent': 'Almonds/1.0 (portfolio project)'};

  /// GETs [uri] and returns the decoded JSON object, mapping every failure
  /// mode to a [LookupFailedException] with a user-presentable message.
  Future<Map<String, dynamic>> _getJson(
    Uri uri, {
    String? notFoundBarcode,
  }) async {
    http.Response response;
    try {
      response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const LookupFailedException('The request timed out. Try again.');
    } on Object {
      throw const LookupFailedException(
        'No connection. Check your internet and try again.',
      );
    }

    if (response.statusCode == 404 && notFoundBarcode != null) {
      throw ProductNotFoundException(notFoundBarcode);
    }
    if (response.statusCode != 200) throw const LookupFailedException();

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      // OFF serves an HTML "temporarily unavailable" page under load.
      throw const LookupFailedException();
    }
  }

  Future<Product> fetch(String barcode) async {
    final code = barcode.trim();
    if (!RegExp(r'^\d{6,14}$').hasMatch(code)) {
      throw ProductNotFoundException(code);
    }

    final body = await _getJson(
      Uri.parse('${Env.offBaseUrl}/$code.json?fields=$_fields'),
      notFoundBarcode: code,
    );

    final product = body['product'];
    if (body['status'] != 1 || product is! Map<String, dynamic>) {
      throw ProductNotFoundException(code);
    }
    return Product.fromOff(code, product);
  }

  Uri _searchUri(Map<String, String> params) => Uri.https(
    'world.openfoodfacts.org',
    '/cgi/search.pl',
    {
      'action': 'process',
      'json': '1',
      'fields': _fields,
      ...params,
    },
  );

  List<Product> _parseSearch(Map<String, dynamic> body) {
    final list = body['products'];
    if (list is! List) return const [];
    final out = <Product>[];
    for (final p in list.whereType<Map<String, dynamic>>()) {
      final code = p['code'];
      final name = p['product_name'];
      if (code is! String || name is! String || name.trim().isEmpty) continue;
      out.add(Product.fromOff(code, p));
    }
    return out;
  }

  /// Full-text product search, most-scanned first.
  Future<List<Product>> search(String query, {int pageSize = 20}) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    final body = await _getJson(
      _searchUri({
        'search_terms': q,
        'search_simple': '1',
        'sort_by': 'unique_scans_n',
        'page_size': '$pageSize',
      }),
    );
    return _parseSearch(body);
  }

  /// Popular products in [categoryTag] (e.g. `en:chocolate-spreads`) with the
  /// given Nutri-Score [grade] ('a'..'e').
  Future<List<Product>> byCategory(
    String categoryTag,
    String grade, {
    int pageSize = 12,
  }) async {
    final body = await _getJson(
      _searchUri({
        'sort_by': 'unique_scans_n',
        'page_size': '$pageSize',
        'tagtype_0': 'categories',
        'tag_contains_0': 'contains',
        'tag_0': categoryTag,
        'tagtype_1': 'nutrition_grades',
        'tag_contains_1': 'contains',
        'tag_1': grade,
      }),
    );
    return _parseSearch(body);
  }
}
