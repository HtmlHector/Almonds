import 'package:flutter/foundation.dart';

import '../data/models/diet.dart';
import '../data/repositories/diet_repository.dart';

class DietController extends ChangeNotifier {
  DietController(this._repo);

  final DietRepository _repo;

  DietPreferences prefs = const DietPreferences();

  Future<void> load() async {
    try {
      prefs = await _repo.load();
      notifyListeners();
    } catch (_) {
      /* preferences are optional; keep defaults */
    }
  }

  void clear() {
    prefs = const DietPreferences();
    notifyListeners();
  }

  Future<void> toggleDiet(Diet d) => _update(prefs.toggleDiet(d));

  Future<void> toggleAllergen(Allergen a) => _update(prefs.toggleAllergen(a));

  Future<void> _update(DietPreferences next) async {
    final previous = prefs;
    prefs = next; // optimistic
    notifyListeners();
    try {
      await _repo.save(next);
    } catch (_) {
      prefs = previous;
      notifyListeners();
    }
  }
}
