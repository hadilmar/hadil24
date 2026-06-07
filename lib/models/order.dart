import 'dart:convert';
import 'cart_item.dart';

class Order {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final double totalPrice;

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': jsonEncode(items.map((item) => item.toMap()).toList()),
      'totalPrice': totalPrice,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    List<dynamic> decoded = jsonDecode(map['items']);
    List<CartItem> items = decoded.map((e) => CartItem.fromMap(e)).toList();
    return Order(
      id: map['id'],
      date: DateTime.parse(map['date']),
      items: items,
      totalPrice: map['totalPrice'],
    );
  }
}
