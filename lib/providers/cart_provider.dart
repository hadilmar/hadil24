import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../database/database_helper.dart';

class CartModel extends ChangeNotifier {
  List<CartItem> _items = [];
  final DatabaseHelper _db = DatabaseHelper();

  List<CartItem> get items => _items;
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.total);
  int get itemCount => _items.length;

  CartModel() {
    loadCart();
  }

  Future<void> loadCart() async {
    _items = await _db.getCartItems();
    notifyListeners();
  }

  Future<void> reloadForCurrentUser() => loadCart();

  Future<void> addItem(CartItem item) async {
    await _db.insertCartItem(item);
    await loadCart();
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    if (newQuantity <= 0) {
      await _db.deleteCartItem(_items[index].id!);
    } else {
      final updatedItem = _items[index];
      updatedItem.quantity = newQuantity;
      await _db.updateCartItem(updatedItem);
    }
    await loadCart();
  }

  Future<void> removeItem(int index) async {
    await _db.deleteCartItem(_items[index].id!);
    await loadCart();
  }

  Future<void> clearCart() async {
    await _db.clearCart();
    await loadCart();
  }
}
