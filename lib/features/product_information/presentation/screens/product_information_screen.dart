import 'dart:math';

import 'package:almonds/features/product_information/domain/description_viewmodel.dart';
import 'package:almonds/features/product_information/presentation/widgets/categorization/negative_nutrients.dart';
import 'package:almonds/features/product_information/presentation/widgets/categorization/positive_nutrients.dart';
import 'package:almonds/features/product_information/presentation/widgets/nutritional_info/nutritional_info.dart';
import 'package:almonds/features/product_information/presentation/widgets/product_score.dart';
import 'package:almonds/features/scanner/domain/entities/product.dart';
import 'package:almonds/widgets/global/app_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    super.initState();
    context.read<DescriptionViewModel>().calories =
        (widget.product.nutrients["energy-kcal_100g"] as num).toDouble();

    context.read<DescriptionViewModel>().sodium =
        (widget.product.nutrients["salt_100g"] as num).toDouble();

    context.read<DescriptionViewModel>().sugar =
        (widget.product.nutrients["sugars_100g"] as num).toDouble();

    context.read<DescriptionViewModel>().protein =
        (widget.product.nutrients["proteins_100g"] as num).toDouble();

    context.read<DescriptionViewModel>().nutrimentChecker();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DescriptionViewModel>();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ListView(
            children: [
              ProductDescription(widget.product.name, widget.product.brand),
              SizedBox(height: 40),
              Column(
                spacing: 30,
                children: [
                  if (viewModel.negativeNutrients.isNotEmpty)
                    NegativeNutrients(viewModel.negativeNutrients),
                  if (viewModel.positiveNutrients.isNotEmpty)
                    PositiveNutrients(viewModel.positiveNutrients),
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
