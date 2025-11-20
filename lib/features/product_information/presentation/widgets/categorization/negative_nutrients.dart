import 'package:flutter/material.dart';

class NegativeNutrients extends StatelessWidget {
  const NegativeNutrients(this.negativeNutrients, {super.key});

  final List<Widget> negativeNutrients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Negatives",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          spacing: 20,
          children: negativeNutrients,
        ),
      ],
    );
  }
}
