import 'package:almonds/features/compare/compare_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lower is better picks the smaller value', () {
    const row = CompareRow('Sugars', 5, 20, 'g', lowerIsBetter: true);
    expect(row.winner, -1);
  });

  test('higher is better picks the larger value', () {
    const row = CompareRow('Fibre', 2, 6, 'g', lowerIsBetter: false);
    expect(row.winner, 1);
  });

  test('near-equal values tie', () {
    const row = CompareRow('Salt', 1.0, 1.02, 'g', lowerIsBetter: true);
    expect(row.winner, 0);
  });
}
