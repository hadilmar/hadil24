class Product {
  int? id;
  String name;
  String weight;
  double price;
  String imagePath;
  bool isPopular;
  String ingredients;
  String category; // حقل جديد

  Product({
    this.id,
    required this.name,
    required this.weight,
    required this.price,
    required this.imagePath,
    required this.isPopular,
    required this.ingredients,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'price': price,
      'imagePath': imagePath,
      'isPopular': isPopular ? 1 : 0,
      'ingredients': ingredients,
      'category': category,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      weight: map['weight'],
      price: map['price'],
      imagePath: map['imagePath'],
      isPopular: map['isPopular'] == 1,
      ingredients: map['ingredients'],
      category: map['category'] ?? 'sweet', // قيمة افتراضية للمنتجات القديمة
    );
  }
}
