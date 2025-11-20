import 'package:almonds/core/models/score_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductScore extends StatefulWidget {
  ProductScore(this.score, {super.key, this.isLarge = false});

  int score;
  bool isLarge;

  @override
  State<ProductScore> createState() => _ProductScoreState();
}

class _ProductScoreState extends State<ProductScore> {
  String scoreType = "undefined";
  ScoreColor scoreColor = ScoreColor();
  Map<String, dynamic> selectedColor = {};

  void getScoreLabel(int score) {
    if (score >= 91) {
      scoreType = "Excellent";
      selectedColor.addAll(scoreColor.excellent);
      return;
    }

    if (score >= 76) {
      scoreType = "Good";
      selectedColor.addAll(scoreColor.good);
      return;
    }

    if (score >= 51) {
      scoreType = "Fair";
      selectedColor.addAll(scoreColor.fair);
      return;
    }

    if (score >= 26) {
      scoreType = "Poor";
      selectedColor.addAll(scoreColor.poor);
      return;
    }

    if (score < 26) {
      scoreType = "Very Poor";
      selectedColor = {
        'background': Colors.red[50],
        'text': Colors.red[700],
      };
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    getScoreLabel(widget.score);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selectedColor['background'],
            border: Border.all(width: 1.5, color: selectedColor['background']),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "${widget.score}/100",
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: selectedColor['text'],
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 6),
        Text(
          "$scoreType",
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selectedColor['text'],
          ),
        ),
      ],
    );
  }
}
