import 'package:flutter/foundation.dart';

import '../data/models/history_entry.dart';
import '../data/models/product.dart';
import '../data/repositories/history_repository.dart';

class HistoryController extends ChangeNotifier {
  HistoryController(this._repo);

  final HistoryRepository _repo;

  List<HistoryEntry> entries = [];
  bool loading = false;
  String? error;

  List<HistoryEntry> get favorites =>
      entries.where((e) => e.isFavorite).toList();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      entries = await _repo.list();
    } catch (_) {
      error = 'Could not load your history.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clear() {
    entries = [];
    error = null;
    notifyListeners();
  }

  /// Records a scan; failures are swallowed so viewing a product never
  /// breaks because history couldn't be saved.
  Future<void> record(Product product, int score) async {
    try {
      await _repo.record(product, score);
      entries = await _repo.list();
      notifyListeners();
    } catch (e) {
      debugPrint('History save failed: $e');
    }
  }

  HistoryEntry? byBarcode(String barcode) {
    for (final e in entries) {
      if (e.product.barcode == barcode) return e;
    }
    return null;
  }

  Future<void> toggleFavorite(HistoryEntry entry) async {
    final next = !entry.isFavorite;
    _replace(entry.copyWith(isFavorite: next));
    try {
      await _repo.setFavorite(entry.id, next);
    } catch (_) {
      _replace(entry); // roll back
    }
  }

  Future<void> remove(HistoryEntry entry) async {
    final index = entries.indexOf(entry);
    entries = [...entries]..remove(entry);
    notifyListeners();
    try {
      await _repo.delete(entry.id);
    } catch (_) {
      entries = [...entries]..insert(index.clamp(0, entries.length), entry);
      notifyListeners();
    }
  }

  void _replace(HistoryEntry entry) {
    entries = [for (final e in entries) e.id == entry.id ? entry : e];
    notifyListeners();
  }
}
