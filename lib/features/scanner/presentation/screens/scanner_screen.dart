import 'package:almonds/widgets/global/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecase/product_usecase.dart';
import '../widgets/product_preview.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  Product? _product;
  ProductUseCase useCase = ProductUseCase();

  Future<void> captureBarcode(result) async {
    String barcode = result.barcodes.first.rawValue;
    print(barcode);

    var product = await useCase.getProduct(barcode);

    // Check if widget is still mounted before calling setState
    if (!mounted) return;

    setState(() {
      _product = product;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            onDetect: captureBarcode,
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            bottom: _product != null ? 0 : -200,
            left: 0,
            right: 0,
            child: _product != null
                ? ProductPreview(
                    product: _product!,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: AppNavigation(3),
    );
  }
}
