import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../utils/user_session.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dipndip.db');
    return await openDatabase(
      path,
      version: 7,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            weight TEXT,
            price REAL NOT NULL,
            imagePath TEXT,
            isPopular INTEGER,
            ingredients TEXT,
            category TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE cart(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId INTEGER NOT NULL,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            quantity INTEGER NOT NULL,
            selectedAddons TEXT,
            imagePath TEXT,
            userEmail TEXT NOT NULL DEFAULT 'guest',
            FOREIGN KEY (productId) REFERENCES products(id)
          )
        ''');
        await _insertInitialProducts(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE products ADD COLUMN category TEXT');
        }
        // إدراج المنتجات الجديدة إذا كانت قاعدة البيانات قديمة (من version 2 إلى 3)
        if (oldVersion < 3) {
          await _insertNewProductsOnUpgrade(db);
        }
        // إصلاح جميع صور المنتجات القديمة في version 4
        if (oldVersion < 4) {
          await db.execute('''
            UPDATE products SET imagePath = 'assets/images/sushi.webp'
            WHERE imagePath IS NULL OR imagePath = '' OR imagePath NOT LIKE 'assets/images/sushi.webp'
          ''');
        }
        if (oldVersion < 7) {
          await db.execute(
            "ALTER TABLE cart ADD COLUMN userEmail TEXT NOT NULL DEFAULT 'guest'",
          );
        }
      },
    );
  }

  // دالة جديدة لإدراج المنتجات الجديدة فقط إذا لم تكن موجودة
  Future<void> _insertNewProductsOnUpgrade(Database db) async {
    // قائمة المنتجات الجديدة (نفس التي في onCreate ولكن بدون القديمة لتجنب التكرار)
    List<Product> newProducts = [
      // مشروبات
      Product(
        name: "كابتشينو",
        weight: "250 ml",
        price: 12,
        imagePath: "assets/images/sushi.jpg",
        isPopular: true,
        ingredients: "اسبريسو، حليب مبخر، رغوة الحليب، كاكاو",
        category: "hot drink",
      ),
      Product(
        name: "موهيتو فراولة",
        weight: "350 ml",
        price: 15,
        imagePath: "assets/images/sushi.jpg",
        isPopular: false,
        ingredients: "فراولة، نعناع، ليمون، صودا، ثلج",
        category: "hot drink",
      ),
      Product(
        name: "فرابي فراولة",
        weight: "400 ml",
        price: 18,
        imagePath: "assets/images/sushi.jpg",
        isPopular: true,
        ingredients: "فراولة، حليب، كريمة، ثلج، سكر",
        category: "hot drink",
      ),
      // إفطار جديد
      Product(
        name: "كريب مالح تونا",
        weight: "250 g",
        price: 22,
        imagePath: "assets/images/sushi.jpg",
        isPopular: true,
        ingredients:
            "تونا، جبنة، فلفل حلو، بصل اخضر، مايونيز، سيراتشا، مقدمة مع صلصة الهريسة",
        category: "breakfast",
      ),
      Product(
        name: "وافل البطاطا بالديك الرومي و الجبنة",
        weight: "300 g",
        price: 26,
        imagePath: "assets/images/sushi.jpg",
        isPopular: true,
        ingredients:
            "ديك رومي، جبنة الايمنتال، بيض عيون، طماطم، جرجير، صلصة المايونيز و الخردل",
        category: "breakfast",
      ),
    ];

    for (var product in newProducts) {
      // التحقق مما إذا كان المنتج موجود بالفعل حسب الاسم
      final existing = await db.query(
        'products',
        where: 'name = ?',
        whereArgs: [product.name],
      );
      if (existing.isEmpty) {
        await db.insert('products', product.toMap());
      }
    }
  }

  Future<void> _insertInitialProducts(Database db) async {
    List<Product> products = [
      // المنتجات الأساسية (القديمة والجديدة معًا)
      Product(
        name: "ميلك كيك",
        weight: "مقدم مع التريسليتشي",
        price: 29,
        imagePath: "assets/images/1.jpg",
        isPopular: true,
        ingredients: "ميلك كيك، تريسليتشي، كريمة، شوكولاتة",
        category: "sweet",
      ),
      Product(
        name: "مايتي كريب",
        weight: "مزينة بسريال الأرز",
        price: 49,
        imagePath: "assets/images/2.jpg",
        isPopular: true,
        ingredients: "كريب، سريال الأرز، شوكولاتة، مكسرات",
        category: "sweet",
      ),
      Product(
        name: "كرواسان البيض",
        weight: "170 g",
        price: 16,
        imagePath: "assets/images/3.jpg",
        isPopular: false,
        ingredients: "كرواسان، بيض، جبن، زبدة",
        category: "breakfast",
      ),
      Product(
        name: "بانكيك كرانشي شوكليت",
        weight: "250 g",
        price: 39,
        imagePath: "assets/images/4.jpg",
        isPopular: true,
        ingredients: "بانكيك، شوكولاتة كرانشي، كريمة، فراولة",
        category: "sweet",
      ),
      // المنتجات الجديدة
      Product(
        name: "كابتشينو",
        weight: "250 ml",
        price: 12,
        imagePath: "assets/images/5.jpg",
        isPopular: true,
        ingredients: "اسبريسو، حليب مبخر، رغوة الحليب، كاكاو",
        category: "hot drink",
      ),
      Product(
        name: "موهيتو فراولة",
        weight: "350 ml",
        price: 15,
        imagePath: "assets/images/6.jpg",
        isPopular: false,
        ingredients: "فراولة، نعناع، ليمون، صودا، ثلج",
        category: "hot drink",
      ),
      Product(
        name: "فرابي فراولة",
        weight: "400 ml",
        price: 18,
        imagePath: "assets/images/7.jpg",
        isPopular: true,
        ingredients: "فراولة، حليب، كريمة، ثلج، سكر",
        category: "hot drink",
      ),
      Product(
        name: "كريب مالح تونا",
        weight: "250 g",
        price: 22,
        imagePath: "assets/images/8.jpg",
        isPopular: true,
        ingredients:
            "تونا، جبنة، فلفل حلو، بصل اخضر، مايونيز، سيراتشا، مقدمة مع صلصة الهريسة",
        category: "breakfast",
      ),
      Product(
        name: "وافل البطاطا بالديك الرومي و الجبنة",
        weight: "150 g",
        price: 26,
        imagePath: "assets/images/9.jpg",
        isPopular: true,
        ingredients:
            "ديك رومي، جبنة الايمنتال، بيض عيون، طماطم، جرجير، صلصة المايونيز و الخردل",
        category: "breakfast",
      ),
    ];
    for (var p in products) {
      await db.insert(
        'products',
        p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // باقي الدوال (getProducts, getProductById, عمليات السلة) كما هي دون تغيير
  Future<List<Product>> getProducts({String? category}) async {
    final db = await database;
    if (category != null && category != 'All') {
      final maps = await db.query(
        'products',
        where: 'category = ?',
        whereArgs: [category],
      );
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    } else {
      final maps = await db.query('products');
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    }
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Product.fromMap(maps.first);
    return null;
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final userKey = await UserSession.currentUserKey();
    final maps = await db.query(
      'cart',
      where: 'userEmail = ?',
      whereArgs: [userKey],
    );
    return List.generate(maps.length, (i) => CartItem.fromMap(maps[i]));
  }

  Future<int> insertCartItem(CartItem item) async {
    final db = await database;
    final userKey = await UserSession.currentUserKey();
    final values = item.toMap()..['userEmail'] = userKey;
    return await db.insert('cart', values);
  }

  Future<int> updateCartItem(CartItem item) async {
    final db = await database;
    final userKey = await UserSession.currentUserKey();
    return await db.update(
      'cart',
      item.toMap()..['userEmail'] = userKey,
      where: 'id = ? AND userEmail = ?',
      whereArgs: [item.id, userKey],
    );
  }

  Future<int> deleteCartItem(int id) async {
    final db = await database;
    final userKey = await UserSession.currentUserKey();
    return await db.delete(
      'cart',
      where: 'id = ? AND userEmail = ?',
      whereArgs: [id, userKey],
    );
  }

  Future<int> clearCart() async {
    final db = await database;
    final userKey = await UserSession.currentUserKey();
    return await db.delete(
      'cart',
      where: 'userEmail = ?',
      whereArgs: [userKey],
    );
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
