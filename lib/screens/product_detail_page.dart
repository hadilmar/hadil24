import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/addon.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  Map<String, bool> _selectedAddons = {};

  List<Addon> getAvailableAddons() {
    if (widget.product.name.contains("ميلك كيك")) return [Addon(name: "صوص شوكولاتة", price: 5)];
    if (widget.product.name.contains("مايتي كريب")) return [Addon(name: "صوص كراميل", price: 7), Addon(name: "آيس كريم", price: 10)];
    if (widget.product.name.contains("كرواسان")) return [Addon(name: "جبن إضافي", price: 3)];
    if (widget.product.name.contains("بانكيك")) return [Addon(name: "صوص شوكولاتة", price: 5), Addon(name: "بندق مجروش", price: 4)];
    return [];
  }

  List<Addon> getSelectedAddons() {
    List<Addon> selected = [];
    _selectedAddons.forEach((name, isSelected) {
      if (isSelected) {
        final addon = getAvailableAddons().firstWhere((a) => a.name == name);
        selected.add(addon);
      }
    });
    return selected;
  }

  double get totalPrice {
    double addonsTotal = getSelectedAddons().fold(0, (sum, a) => sum + a.price);
    return (widget.product.price + addonsTotal) * _quantity;
  }

  @override
  void initState() {
    super.initState();
    for (var addon in getAvailableAddons()) {
      _selectedAddons[addon.name] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesModel>(context);
    final isFav = favoritesProvider.isFavorite(widget.product.id!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.product.name, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.grey,
              size: 28,
            ),
            onPressed: () {
              favoritesProvider.toggleFavorite(widget.product.id!);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: AssetImage(widget.product.imagePath), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('${widget.product.price.toStringAsFixed(0)} LYD', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.product.weight, style: TextStyle(color: Colors.grey.shade600)),const SizedBox(height: 20),
            const Text('Ingredients:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.product.ingredients, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            const SizedBox(height: 20),
            if (getAvailableAddons().isNotEmpty) ...[
              const Text('Add-ons:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...getAvailableAddons().map((addon) {
                return CheckboxListTile(
                  title: Text('${addon.name}  +${addon.price} LYD'),
                  value: _selectedAddons[addon.name],
                  onChanged: (val) => setState(() => _selectedAddons[addon.name] = val ?? false),
                  activeColor: Colors.red,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Quantity:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => setState(() { if (_quantity > 1) _quantity--; }),
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${totalPrice.toStringAsFixed(2)} LYD', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final cart = Provider.of<CartModel>(context, listen: false);
                  CartItem newItem = CartItem(
                    productId: widget.product.id!,
                    name: widget.product.name,
                    price: widget.product.price,
                    quantity: _quantity,
                    selectedAddons: getSelectedAddons(),
                    imagePath: widget.product.imagePath,
                  );
                  await cart.addItem(newItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_quantity} x ${widget.product.name} added to cart')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}