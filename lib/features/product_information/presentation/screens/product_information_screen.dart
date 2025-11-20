import 'dart:math';

import 'package:almonds/features/product_information/presentation/widgets/categorization/negative_nutrients.dart';
import 'package:almonds/features/product_information/presentation/widgets/categorization/positive_nutrients.dart';
import 'package:almonds/features/product_information/presentation/widgets/nutritional_info/nutritional_info.dart';
import 'package:almonds/features/product_information/presentation/widgets/product_score.dart';
import 'package:almonds/features/scanner/domain/entities/product.dart';
import 'package:almonds/widgets/global/app_navigation.dart';
import 'package:flutter/material.dart';
import '../widgets/description/product_description.dart';
import '../widgets/nutrient_graph.dart';

class ProductInformationScreen extends StatefulWidget {
  const ProductInformationScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductInformationScreen> createState() =>
      _ProductInformationScreenState();
}

class _ProductInformationScreenState extends State<ProductInformationScreen> {
  // Example nutrient values
  late double calories = 1;
  late double sodium = 1;
  late double sugar = 1;
  late double protein = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calories = (widget.product.nutrients["energy-kcal_100g"] as num).toDouble();
    sodium = (widget.product.nutrients["salt_100g"] as num).toDouble();
    sugar = (widget.product.nutrients["sugars_100g"] as num).toDouble();
  }

  void determineNutrientStatus() {}

  @override
  Widget build(BuildContext context) {
    // Determine which nutrients are healthy (green/light green) vs unhealthy (orange/red)
    bool caloriesHealthy = NutrientGraph.isHealthy(calories);
    bool sodiumHealthy = NutrientGraph.isHealthy(sodium);
    bool sugarHealthy = NutrientGraph.isHealthy(sugar);

    // Build lists of positive and negative nutrients
    List<Widget> positiveNutrients = [];
    List<Widget> negativeNutrients = [];

    // Categorize calories
    if (caloriesHealthy) {
      positiveNutrients.add(NutrientGraph(title: "Calories", value: calories));
    } else {
      negativeNutrients.add(NutrientGraph(title: "Calories", value: calories));
    }

    // Categorize sodium
    if (sodiumHealthy) {
      positiveNutrients.add(NutrientGraph(title: "Salt", value: sodium));
    } else {
      negativeNutrients.add(NutrientGraph(title: "Salt", value: sodium));
    }

    // Categorize sodium
    if (sugarHealthy) {
      positiveNutrients.add(NutrientGraph(title: "Sugar", value: sugar));
    } else {
      negativeNutrients.add(NutrientGraph(title: "Sugar", value: sugar));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ListView(
            children: [
              ProductDescription(widget.product.name, widget.product.brand),
              SizedBox(height: 40),
              Column(
                spacing: 30,
                children: [
                  if (negativeNutrients.isNotEmpty)
                    NegativeNutrients(negativeNutrients),
                  if (positiveNutrients.isNotEmpty)
                    PositiveNutrients(positiveNutrients),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation(3),
    );
  }
}
