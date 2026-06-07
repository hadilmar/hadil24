import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../widgets/food_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favProvider = Provider.of<FavoritesModel>(context, listen: false);
    final List<Product> allProducts = await DatabaseHelper().getProducts();
    setState(() {
      _favoriteProducts = allProducts
          .where((p) => favProvider.favoriteIds.contains(p.id))
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoritesModel>(context);

    // تحديث القائمة عند تغيير المفضلة
    if (!_isLoading) {
      DatabaseHelper().getProducts().then((allProducts) {
        setState(() {
          _favoriteProducts = allProducts
              .where((p) => favProvider.favoriteIds.contains(p.id))
              .toList();
        });
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_favoriteProducts.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                await favProvider.clearFavorites();
                setState(() {
                  _favoriteProducts = [];
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All favorites removed')),
                );
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    color: Colors.red.shade200,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap the heart icon on any product to add it here',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Browse Menu'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteProducts.length,
              itemBuilder: (context, index) {
                return FoodCard(product: _favoriteProducts[index]);
              },
            ),
    );
  }
}
