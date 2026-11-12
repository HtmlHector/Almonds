enum Severity {
  low('Low risk'),
  moderate('Moderate risk'),
  high('High risk');

  const Severity(this.label);
  final String label;

  /// Points removed from the 30-point additives sub-score.
  int get penalty => switch (this) {
    Severity.low => 3,
    Severity.moderate => 8,
    Severity.high => 15,
  };
}

class Additive {
  const Additive({
    required this.name,
    required this.category,
    required this.severity,
    required this.description,
    required this.match,
  });

  final String name;
  final String category;
  final Severity severity;
  final String description;

  /// Lower-case names / E-numbers that identify this additive in an
  /// ingredients list.
  final List<String> match;

  factory Additive.fromJson(Map<String, dynamic> json) => Additive(
    name: json['name'] as String,
    category: json['category'] as String,
    severity: Severity.values.byName(json['severity'] as String),
    description: json['description'] as String,
    match: (json['match'] as List).cast<String>(),
  );
}
