class Addon {
  String name;
  double price;
  Addon({required this.name, required this.price});

  Map<String, dynamic> toMap() => {'name': name, 'price': price};

  factory Addon.fromMap(Map<String, dynamic> map) {
    return Addon(name: map['name'], price: map['price']);
  }
}
