import 'nutriments.dart';

class Product {
  const Product({
    required this.barcode,
    required this.name,
    this.brand = '',
    this.imageUrl,
    this.quantity = '',
    this.ingredientsText = '',
    this.nutriments = const Nutriments(),
    this.nutriScoreGrade,
    this.novaGroup,
    this.labels = const [],
    this.additiveTags = const [],
    this.allergens = const [],
    this.traces = const [],
    this.categoryTags = const [],
    this.ingredientsAnalysis = const [],
  });

  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final String quantity;
  final String ingredientsText;
  final Nutriments nutriments;

  /// 'a'..'e' as published by Open Food Facts, when available.
  final String? nutriScoreGrade;

  /// 1 (unprocessed) .. 4 (ultra-processed).
  final int? novaGroup;
  final List<String> labels;

  /// Additive tags such as `en:e330`.
  final List<String> additiveTags;
  final List<String> allergens;

  /// "May contain" allergens, cleaned like [allergens].
  final List<String> traces;

  /// Category tags from general to specific, e.g. `en:chocolate-spreads`.
  final List<String> categoryTags;

  /// OFF analysis tags such as `en:vegan`, `en:non-vegetarian`, `en:palm-oil`.
  final List<String> ingredientsAnalysis;

  bool get isOrganic => labels.any((l) => l.contains('organic'));

  bool get hasIngredients => ingredientsText.trim().isNotEmpty;

  static String _clean(String tag) => tag.contains(':')
      ? tag.split(':').last.replaceAll('-', ' ')
      : tag.replaceAll('-', ' ');

  static List<String> _list(Object? v) =>
      v is List ? v.whereType<String>().toList() : const [];

  factory Product.fromOff(String barcode, Map<String, dynamic> p) {
    final grade = (p['nutriscore_grade'] as String?)?.toLowerCase();
    final nova = p['nova_group'];
    return Product(
      barcode: barcode,
      name: (p['product_name'] as String?)?.trim().isNotEmpty == true
          ? (p['product_name'] as String).trim()
          : 'Unnamed product',
      brand: ((p['brands'] as String?) ?? '').split(',').first.trim(),
      imageUrl: (p['image_front_url'] ?? p['image_url']) as String?,
      quantity: (p['quantity'] as String?)?.trim() ?? '',
      ingredientsText: (p['ingredients_text'] as String?)?.trim() ?? '',
      nutriments: Nutriments.fromOff(p['nutriments'] as Map<String, dynamic>?),
      nutriScoreGrade: const {'a', 'b', 'c', 'd', 'e'}.contains(grade)
          ? grade
          : null,
      novaGroup: nova is num ? nova.toInt() : null,
      labels: _list(p['labels_tags']),
      additiveTags: _list(p['additives_tags']),
      allergens: _list(p['allergens_tags']).map(_clean).toList(),
      traces: _list(p['traces_tags']).map(_clean).toList(),
      categoryTags: _list(p['categories_tags']),
      ingredientsAnalysis: _list(p['ingredients_analysis_tags']),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    barcode: json['barcode'] as String,
    name: json['name'] as String,
    brand: (json['brand'] as String?) ?? '',
    imageUrl: json['imageUrl'] as String?,
    quantity: (json['quantity'] as String?) ?? '',
    ingredientsText: (json['ingredientsText'] as String?) ?? '',
    nutriments: Nutriments.fromJson(
      (json['nutriments'] as Map<String, dynamic>?) ?? const {},
    ),
    nutriScoreGrade: json['nutriScoreGrade'] as String?,
    novaGroup: (json['novaGroup'] as num?)?.toInt(),
    labels: _list(json['labels']),
    additiveTags: _list(json['additiveTags']),
    allergens: _list(json['allergens']),
    traces: _list(json['traces']),
    categoryTags: _list(json['categoryTags']),
    ingredientsAnalysis: _list(json['ingredientsAnalysis']),
  );

  Map<String, dynamic> toJson() => {
    'barcode': barcode,
    'name': name,
    'brand': brand,
    'imageUrl': imageUrl,
    'quantity': quantity,
    'ingredientsText': ingredientsText,
    'nutriments': nutriments.toJson(),
    'nutriScoreGrade': nutriScoreGrade,
    'novaGroup': novaGroup,
    'labels': labels,
    'additiveTags': additiveTags,
    'allergens': allergens,
    'traces': traces,
    'categoryTags': categoryTags,
    'ingredientsAnalysis': ingredientsAnalysis,
  };
}
