import 'package:flutter/material.dart';

import '../product_score.dart';

class ProductDescription extends StatelessWidget {
  const ProductDescription(this.name, this.brand, {super.key});

  final String name;
  final String brand;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          child: Text(
            brand,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w200,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        ProductScore(90),
      ],
    );
  }
}
