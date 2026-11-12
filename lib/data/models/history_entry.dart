import 'product.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.product,
    required this.score,
    required this.isFavorite,
    required this.scannedAt,
  });

  final String id;
  final Product product;
  final int score;
  final bool isFavorite;
  final DateTime scannedAt;

  HistoryEntry copyWith({bool? isFavorite}) => HistoryEntry(
    id: id,
    product: product,
    score: score,
    isFavorite: isFavorite ?? this.isFavorite,
    scannedAt: scannedAt,
  );

  factory HistoryEntry.fromRow(Map<String, dynamic> row) => HistoryEntry(
    id: row['id'] as String,
    product: Product.fromJson(row['product'] as Map<String, dynamic>),
    score: row['score'] as int,
    isFavorite: row['is_favorite'] as bool,
    scannedAt: DateTime.parse(row['scanned_at'] as String).toLocal(),
  );
}
