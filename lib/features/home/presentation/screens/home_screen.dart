import 'package:almonds/widgets/global/app_navigation.dart';
import 'package:flutter/material.dart';

import '../../../scanner/domain/entities/product.dart';
import '../../../scanner/presentation/widgets/product_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Home"),
      ),
      body: Column(
        children: [
          Text("No Saved Products"),
        ],
      ),

      bottomNavigationBar: AppNavigation(0),
    );
  }
}
