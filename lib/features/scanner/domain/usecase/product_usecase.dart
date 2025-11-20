import 'package:almonds/features/scanner/data/repositories/product_repository.dart';
import 'package:almonds/features/scanner/domain/entities/product.dart';

class ProductUseCase {
  Future<Product> getProduct(String barcode) async {
    Product product = await ProductRepository.create(barcode);
    return product;
  }
}
