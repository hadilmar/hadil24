import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class AddEditProductPage extends StatefulWidget {
  final Product? product;

  const AddEditProductPage({super.key, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _priceController;
  late TextEditingController _imagePathController;
  late TextEditingController _ingredientsController;
  String _category = 'sweet';
  bool _isPopular = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _weightController = TextEditingController(
      text: widget.product?.weight ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _imagePathController = TextEditingController(
      text: widget.product?.imagePath ?? 'assets/images/',
    );
    _ingredientsController = TextEditingController(
      text: widget.product?.ingredients ?? '',
    );
    _category = widget.product?.category ?? 'sweet';
    _isPopular = widget.product?.isPopular ?? false;
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool('is_admin') ?? false;

    if (!isAdmin && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('الوصول مرفوض'),
          content: const Text('فقط المسؤول يمكنه إضافة المنتجات أو تعديلها.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('رجوع'),
            ),
          ],
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _imagePathController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        weight: _weightController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imagePath: _imagePathController.text.trim(),
        isPopular: _isPopular,
        ingredients: _ingredientsController.text.trim(),
        category: _category,
      );
      if (widget.product == null) {
        await DatabaseHelper().insertProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تمت إضافة المنتج')));
        }
      } else {
        await DatabaseHelper().updateProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم تحديث المنتج')));
        }
      }
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product == null ? 'إضافة منتج' : 'تعديل منتج',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'الرجاء إدخال الاسم' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'الوزن (مثال: 250 g)',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'الرجاء إدخال الوزن' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'السعر (LYD)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'الرجاء إدخال السعر';
                  return double.tryParse(v.trim()) == null
                      ? 'الرجاء إدخال سعر صحيح'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imagePathController,
                decoration: const InputDecoration(
                  labelText: 'مسار الصورة (assets/images/...)',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'الرجاء إدخال مسار الصورة' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'المكونات'),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'الرجاء إدخال المكونات' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'التصنيف'),
                items: const [
                  DropdownMenuItem(value: 'sweet', child: Text('حلويات')),
                  DropdownMenuItem(value: 'breakfast', child: Text('إفطار')),
                  DropdownMenuItem(
                    value: 'hot drink',
                    child: Text('hot&cold drink'),
                  ),
                ],
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('منتج مشهور (Popular)'),
                value: _isPopular,
                onChanged: (val) => setState(() => _isPopular = val),
                activeThumbColor: Colors.red,
              ),
              const SizedBox(height: 30),
              if (!_isAdmin)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'فقط المسؤول يمكنه إضافة المنتجات أو تعديلها',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(widget.product == null ? 'إضافة' : 'تحديث'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
