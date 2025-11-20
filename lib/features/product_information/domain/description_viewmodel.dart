import 'package:flutter/cupertino.dart';

import '../presentation/widgets/nutrient_graph.dart';

class DescriptionViewmodel extends ChangeNotifier {
  // Example nutrient values
  double calories = 1;
  double sodium = 1;
  double sugar = 1;
  double protein = 1;

  void nutrimentChecker(double) {}

  // Build lists of positive and negative nutrients
  List<Widget> positiveNutrients = [];
  List<Widget> negativeNutrients = [];
}
