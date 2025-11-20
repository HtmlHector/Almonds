import 'package:almonds/features/home/domain/home_viewmodel.dart';
import 'package:almonds/features/home/presentation/widgets/empty_history.dart';
import 'package:almonds/features/home/presentation/widgets/saved_product_list.dart';
import 'package:almonds/features/settings/presentation/screens/settings_screen.dart';
import 'package:almonds/widgets/global/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../scanner/domain/entities/product.dart';
import '../../../scanner/presentation/widgets/product_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<HomeViewModel>().getSavedProducts();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Home"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SettingsScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: ClipOval(
                child: Container(
                  height: 35,
                  width: 35,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
      body: viewModel.savedProducts.isEmpty
          ? EmptyHistory()
          : SavedProductList(),
      bottomNavigationBar: AppNavigation(0),
    );
  }
}
