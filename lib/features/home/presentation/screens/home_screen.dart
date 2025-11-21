import 'package:almonds/features/home/domain/home_viewmodel.dart';
import 'package:almonds/features/home/presentation/widgets/empty_history.dart';
import 'package:almonds/features/home/presentation/widgets/saved_product_list.dart';
import 'package:almonds/features/settings/presentation/screens/settings_screen.dart';
import 'package:almonds/widgets/global/app_navigation.dart';
import 'package:flutter/cupertino.dart';
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
    super.initState();
    context.read<HomeViewModel>().getSavedProducts();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
        leading: const Text(
          'Home',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.black,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          child: Container(
            height: 35,
            width: 35,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.systemOrange,
            ),
          ),
        ),
      ),
      child: viewModel.savedProducts.isEmpty
          ? EmptyHistory()
          : SavedProductList(),
    );
  }
}
