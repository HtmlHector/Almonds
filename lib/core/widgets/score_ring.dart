import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../theme/ios.dart';
import '../theme/score_rating.dart';

/// Circular gauge that animates up to the score, coloured by rating.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    this.size = 56,
    this.stroke = 6,
    this.showLabel = false,
  });

  final int score;
  final double size;
  final double stroke;

  /// Show the rating word under the number (use with larger sizes).
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final rating = ScoreRating.fromScore(score);
    final track = context.strongFillColor;
    return Semantics(
      label: 'Score $score out of 100, ${rating.label}',
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: score / 100),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => CustomPaint(
            painter: _RingPainter(value, rating.color, track, stroke),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: size * (showLabel ? 0.34 : 0.36),
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  if (showLabel)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        rating.label,
                        style: TextStyle(
                          fontSize: size * 0.11,
                          fontWeight: FontWeight.w600,
                          color: rating.color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.color, this.track, this.stroke);

  final double progress;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final arc = (Offset.zero & size).deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, 0, math.pi * 2, false, base..color = track);
    canvas.drawArc(
      arc,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      base..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
