import 'dart:convert';
import 'package:almonds/features/scanner/domain/entities/product.dart';
import 'package:http/http.dart' as http;

import '../../../../constants/sources/harmful_contents.dart';
import '../../../../core/api/keys.dart';
import '../../../../core/api/urls.dart';

class ProductRepository {
  // Now accepts a string of ingredients
  static List<String> getIngredients(String ingredients) {
    return ingredients
        .split(',')
        .map((e) => e.trim().replaceAll('-', ' ').toLowerCase())
        .toList();
  }

  static int calculateHealthScore(
    List<String> ingredientList,
    List<HarmfulContent> harmfulList,
  ) {
    int score = 100;

    for (var ingredient in ingredientList) {
      for (var harmful in harmfulList) {
        if (ingredient.contains(harmful.name)) {
          score -= 5; // Deduct 5 points for each harmful ingredient
          break; // Avoid double-counting
        }
      }
    }

    return score.clamp(0, 100); // Ensure score doesn't go below 0
  }

  static Future<String> getProductImage(String name, String brand) async {
    String input = "${name} ${brand}";
    String output = input.split(' ').join('+');

    Uri searchApiUri = Uri.parse(
      "${searchApiUrl}q=${output}&api_key=${searchApiKey}",
    );

    print(searchApiUri);

    // var searchApiResponse = await http.get(searchApiUri);
    // var searchApiData = jsonDecode(searchApiResponse.body);
    //
    // var imageUrl = searchApiData["images"][0]["original"]["link"];

    return "";
  }

  static Future<Product> getProductInfo(String barcode) async {
    Uri offUri = Uri.parse("$offApiUrl/$barcode");
    var offResponse = await http.get(offUri);
    var offData = jsonDecode(offResponse.body);

    var product = Product(
      barcode: barcode,
      name: offData['product']['product_name'] ?? '',
      brand: offData['product']['brands'] ?? '',
      ingredients: offData['product']['ingredients_text'] ?? '',
      nutrients: offData['product']['nutriments'],
    );

    return product;
  }

  static void getProductNutrients() {}

  static Future<Product> create(String barcode) async {
    // Gets product metadata (Name, Brand, Ingredients)
    Product product = await getProductInfo(barcode);

    // Formats product ingredients dynamically
    List<String> formattedIngredients = getIngredients(product.ingredients);

    // Calculates score based on harmful ingredients
    int score = calculateHealthScore(formattedIngredients, harmfulIngredients);
    product.setScore(score);

    return product;
  }
}
