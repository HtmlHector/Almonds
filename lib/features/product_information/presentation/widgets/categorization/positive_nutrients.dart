import 'package:flutter/material.dart';

class PositiveNutrients extends StatelessWidget {
  const PositiveNutrients(this.positiveNutrients, {super.key});

  final List<Widget> positiveNutrients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Positives",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          spacing: 20,
          children: positiveNutrients,
        ),
      ],
    );
  }
}
