import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/additive.dart';

/// Loads the curated additive list and finds matches inside ingredient text.
class AdditiveCatalog {
  AdditiveCatalog(this.additives)
    : _patterns = [
        for (final a in additives)
          RegExp(
            '(?<![a-z0-9])(?:${a.match.map(RegExp.escape).join('|')})(?![a-z0-9])',
          ),
      ];

  final List<Additive> additives;
  final List<RegExp> _patterns;

  static Future<AdditiveCatalog> load([AssetBundle? bundle]) async {
    final raw = await (bundle ?? rootBundle).loadString(
      'assets/data/additives.json',
    );
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return AdditiveCatalog(list.map(Additive.fromJson).toList());
  }

  /// Lower-cases, strips accents/hyphens so "E-102" and "e102" both match.
  static String normalize(String input) {
    const accents = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ï': 'i',
      'ó': 'o',
      'ö': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
      'ç': 'c',
    };
    var s = input.toLowerCase();
    accents.forEach((k, v) => s = s.replaceAll(k, v));
    return s
        .replaceAllMapped(
          RegExp(r'\be[\s-]?(\d{3,4}[a-z]?)'),
          (m) => 'e${m[1]}',
        )
        .replaceAll('-', ' ');
  }

  /// Returns every catalogued additive that appears in [ingredients]
  /// or in the OFF [additiveTags] (e.g. `en:e330`).
  List<Additive> findIn(
    String ingredients, {
    List<String> additiveTags = const [],
  }) {
    final haystack = normalize(
      '$ingredients ${additiveTags.map((t) => t.split(':').last).join(' ')}',
    );
    final found = <Additive>[];
    for (var i = 0; i < additives.length; i++) {
      if (_patterns[i].hasMatch(haystack)) found.add(additives[i]);
    }
    return found;
  }
}
