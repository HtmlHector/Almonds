import 'package:almonds/core/theme/score_rating.dart';
import 'package:almonds/core/widgets/score_ring.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rating bands', () {
    expect(ScoreRating.fromScore(100), ScoreRating.excellent);
    expect(ScoreRating.fromScore(75), ScoreRating.excellent);
    expect(ScoreRating.fromScore(74), ScoreRating.good);
    expect(ScoreRating.fromScore(50), ScoreRating.good);
    expect(ScoreRating.fromScore(49), ScoreRating.mediocre);
    expect(ScoreRating.fromScore(25), ScoreRating.mediocre);
    expect(ScoreRating.fromScore(24), ScoreRating.poor);
    expect(ScoreRating.fromScore(0), ScoreRating.poor);
  });

  testWidgets('ScoreRing shows the score and rating label', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: Center(child: ScoreRing(score: 82, size: 120, showLabel: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('82'), findsOneWidget);
    expect(find.text('Excellent'), findsOneWidget);
  });
}
