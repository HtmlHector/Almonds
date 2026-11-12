import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/diet.dart';

class DietRepository {
  DietRepository(this._client);

  final SupabaseClient _client;

  Future<DietPreferences> load() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return const DietPreferences();
    final row = await _client
        .from('profiles')
        .select('diets,avoid_allergens')
        .eq('id', id)
        .maybeSingle();
    if (row == null) return const DietPreferences();
    return DietPreferences.fromLists(
      (row['diets'] as List?)?.cast<String>() ?? const [],
      (row['avoid_allergens'] as List?)?.cast<String>() ?? const [],
    );
  }

  Future<void> save(DietPreferences prefs) async {
    final id = _client.auth.currentUser!.id;
    await _client
        .from('profiles')
        .update({
          'diets': prefs.dietNames,
          'avoid_allergens': prefs.allergenNames,
        })
        .eq('id', id);
  }
}
