import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../utils/user_session.dart';

class OrdersModel extends ChangeNotifier {
  List<Order> _orders = [];
  String _storageKey = 'orders:${UserSession.guestUserKey}';

  List<Order> get orders => _orders;

  OrdersModel() {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = await UserSession.currentUserKey();
    _storageKey = 'orders:$userKey';
    final List<String>? ordersJson = prefs.getStringList(_storageKey);
    if (ordersJson != null) {
      _orders = ordersJson.map((json) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(
          jsonDecode(json),
        );
        return Order.fromMap(map);
      }).toList();
    } else {
      _orders = [];
    }
    notifyListeners();
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ordersJson = _orders
        .map((order) => jsonEncode(order.toMap()))
        .toList();
    await prefs.setStringList(_storageKey, ordersJson);
  }

  Future<void> reloadForCurrentUser() => _loadOrders();

  Future<void> addOrder(List<CartItem> items, double totalPrice) async {
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: items,
      totalPrice: totalPrice,
    );
    _orders.insert(0, newOrder); // أحدث طلب في الأعلى
    notifyListeners();
    await _saveOrders();
  }

  Future<void> clearOrders() async {
    _orders.clear();
    notifyListeners();
    await _saveOrders();
  }
}
