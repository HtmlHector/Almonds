import 'package:almonds/features/home/domain/home_viewmodel.dart';
import 'package:almonds/features/home/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavedProductList extends StatefulWidget {
  const SavedProductList({super.key});

  @override
  State<SavedProductList> createState() => _SavedProductListState();
}

class _SavedProductListState extends State<SavedProductList> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<HomeViewModel>();
    return ListView(
      children: [
        ...viewModel.savedProducts.map((savedProduct) {
          print(savedProduct);
          return ProductCard(savedProduct);
        }),
      ],
    );
  }
}
