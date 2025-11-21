import 'package:almonds/widgets/global/app_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
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
  bool isScannerEnabled = true;

  Future<void> captureBarcode(result) async {
    if (isScannerEnabled) {
      // Disable immediately to prevent multiple scans
      isScannerEnabled = false;

      final barcode = result.barcodes.first.rawValue;

      print(barcode);

      final product = await useCase.getProduct(barcode);

      await Haptics.vibrate(HapticsType.success);

      if (!mounted) return;

      setState(() {
        _product = product;
      });
    } else {
      print("Scanner has been disabled");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
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
    );
  }
}
