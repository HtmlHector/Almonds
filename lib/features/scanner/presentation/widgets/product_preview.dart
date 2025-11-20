import 'package:almonds/features/product_information/presentation/screens/product_information_screen.dart';
import 'package:almonds/features/scanner/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utilities/database.dart';

class ProductPreview extends StatefulWidget {
  const ProductPreview({super.key, required this.product});

  final Product product;

  @override
  State<ProductPreview> createState() => _ProductPreviewState();
}

class _ProductPreviewState extends State<ProductPreview> {
  Future<void> saveProduct() async {
    // print("Hello");
    //
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString("userId", "38137b44-3955-4ec9-b47a-7398aef87da3");
    // String? userId = prefs.getString("userId"); // ✅ consistent key
    //
    // final supabase = Database.supabase;
    //
    // // 1️⃣ Get the current array
    // Map<String, dynamic>? user;
    // try {
    //   final user = await supabase
    //       .from('users')
    //       .select('saved_products')
    //       .eq('id', userId!)
    //       .maybeSingle();
    //
    //   print("Fetched user data successfully: $user");
    // } catch (e) {
    //   print("❌ Error fetching saved_products: $e");
    //   return; // Stop further execution if fetch fails
    // }
    //
    // // 2️⃣ Prepare updated favorites list
    // List favorites = (user?['saved_products'] ?? []) as List;
    //
    // if (!favorites.contains(widget.product)) {
    //   favorites.add(widget.product.toJson());
    // }
    //
    // // 3️⃣ Update the array in Supabase
    // try {
    //   await supabase
    //       .from('users')
    //       .update({'saved_products': favorites})
    //       .eq('id', userId);
    //
    //   print("✅ Successfully updated saved_products: $favorites");
    // } catch (e) {
    //   print("❌ Error updating saved_products: $e");
    // }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductInformationScreen(product: widget.product),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        spacing: 20,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.product.brand,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Colors.black38,
                  ),
                ),
                // ProductScore(widget.product.score!),
              ],
            ),
          ),
          GestureDetector(
            onTap: saveProduct,
            child: ClipOval(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
