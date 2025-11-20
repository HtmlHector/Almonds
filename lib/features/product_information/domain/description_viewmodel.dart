import 'package:flutter/cupertino.dart';

import '../presentation/widgets/nutrient_graph.dart';

class DescriptionViewModel extends ChangeNotifier {
  // Example nutrient values
  double calories = 1;
  double sodium = 1;
  double sugar = 1;
  double protein = 1;

  bool? caloriesHealthy;
  bool? sodiumHealthy;
  bool? sugarHealthy;

  void nutrimentChecker() {
    caloriesHealthy = NutrientGraph.isHealthy(calories);
    sodiumHealthy = NutrientGraph.isHealthy(sodium);
    sugarHealthy = NutrientGraph.isHealthy(sugar);
    notifyListeners();

    // Categorize calories
    if (caloriesHealthy!) {
      positiveNutrients.add(NutrientGraph(title: "Calories", value: calories));
    } else {
      negativeNutrients.add(NutrientGraph(title: "Calories", value: calories));
    }

    // Categorize sodium
    if (sodiumHealthy!) {
      positiveNutrients.add(NutrientGraph(title: "Salt", value: sodium));
    } else {
      negativeNutrients.add(NutrientGraph(title: "Salt", value: sodium));
    }

    // Categorize sodium
    if (sugarHealthy!) {
      positiveNutrients.add(NutrientGraph(title: "Sugar", value: sugar));
    } else {
      negativeNutrients.add(NutrientGraph(title: "Sugar", value: sugar));
    }

    print(positiveNutrients);
  }

  // Build lists of positive and negative nutrients
  List<Widget> positiveNutrients = [];
  List<Widget> negativeNutrients = [];
}
