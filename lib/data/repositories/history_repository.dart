import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/history_entry.dart';
import '../models/product.dart';

class HistoryRepository {
  HistoryRepository(this._client);

  final SupabaseClient _client;

  Future<List<HistoryEntry>> list() async {
    final rows = await _client
        .from('scan_history')
        .select()
        .order('scanned_at', ascending: false);
    return rows.map(HistoryEntry.fromRow).toList();
  }

  /// Saves a scan. Re-scanning the same barcode refreshes it instead of
  /// duplicating (unique on user + barcode) and keeps the favourite flag.
  Future<void> record(Product product, int score) async {
    await _client.from('scan_history').upsert({
      'barcode': product.barcode,
      'name': product.name,
      'brand': product.brand,
      'image_url': product.imageUrl,
      'score': score,
      'product': product.toJson(),
      'scanned_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,barcode');
  }

  Future<void> setFavorite(String id, bool value) async {
    await _client
        .from('scan_history')
        .update({'is_favorite': value})
        .eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('scan_history').delete().eq('id', id);
  }
}
