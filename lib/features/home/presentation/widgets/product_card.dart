import 'package:almonds/features/scanner/domain/entities/product.dart';
import 'package:flutter/material.dart';

import '../../../product_information/presentation/widgets/product_score.dart';

class ProductCard extends StatelessWidget {
  const ProductCard(this.product, {super.key});

  final dynamic product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // shadow color
            blurRadius: 8, // softens the shadow
            offset: Offset(0, 4), // moves the shadow down
          ),
        ],
      ),
      child: Column(
        spacing: 14,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product["name"],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          Text(
            product["brand"],
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Colors.black38,
            ),
          ),
          ProductScore(80),
        ],
      ),
    );
  }
}
