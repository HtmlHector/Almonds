class Product {
  final String barcode;
  final String name;
  final String brand;
  final String ingredients;
  String? image;
  int? score;
  final Map<String, dynamic> nutrients;

  Product({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.ingredients,
    required this.nutrients,
    this.image,
  });

  void setImage(String imageUrl) {
    image = imageUrl;
  }

  void setScore(int _score) {
    score = _score;
  }
}
