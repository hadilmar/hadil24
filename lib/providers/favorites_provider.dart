import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/user_session.dart';

class FavoritesModel extends ChangeNotifier {
  Set<int> _favoriteIds = {};
  String _storageKey = 'favorites:${UserSession.guestUserKey}';

  Set<int> get favoriteIds => _favoriteIds;

  FavoritesModel() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = await UserSession.currentUserKey();
    _storageKey = 'favorites:$userKey';
    final saved = prefs.getStringList(_storageKey);
    _favoriteIds =
        saved?.map((id) => int.tryParse(id)).whereType<int>().toSet() ?? {};
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = _favoriteIds.map((id) => id.toString()).toList();
    await prefs.setStringList(_storageKey, list);
  }

  Future<void> reloadForCurrentUser() => _loadFavorites();

  bool isFavorite(int productId) {
    return _favoriteIds.contains(productId);
  }

  Future<void> toggleFavorite(int productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> clearFavorites() async {
    _favoriteIds.clear();
    notifyListeners();
    await _saveFavorites();
  }
}
