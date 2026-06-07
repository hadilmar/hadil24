import 'dart:convert';
import 'addon.dart';

class CartItem {
  int? id;
  int productId;
  String name;
  double price;
  int quantity;
  List<Addon> selectedAddons;
  String imagePath;

  CartItem({
    this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.selectedAddons,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'selectedAddons': jsonEncode(
        selectedAddons.map((a) => a.toMap()).toList(),
      ),
      'imagePath': imagePath,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    List<Addon> addons = [];
    if (map['selectedAddons'] != null) {
      List<dynamic> decoded = jsonDecode(map['selectedAddons']);
      addons = decoded.map((e) => Addon.fromMap(e)).toList();
    }
    return CartItem(
      id: map['id'],
      productId: map['productId'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
      selectedAddons: addons,
      imagePath: map['imagePath'],
    );
  }

  double get total => price * quantity;
} 
