// profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/orders_provider.dart';
import 'login_page.dart';
import 'favorites_page.dart';
import 'orders_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Guest';
  String userEmail = 'Not logged in';
  bool isLoggedIn = false;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      isAdmin = prefs.getBool('is_admin') ?? false;
      if (isLoggedIn) {
        userName = prefs.getString('user_name') ?? 'User';
        userEmail = prefs.getString('user_email') ?? 'No email';
      } else {
        userName = 'Guest';
        userEmail = 'Not logged in';
      }
    });
  }

  Future<void> _logout() async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final favoritesModel = Provider.of<FavoritesModel>(context, listen: false);
    final ordersModel = Provider.of<OrdersModel>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.setBool('is_admin', false);
    if (!mounted) return;

    await Future.wait([
      cartModel.reloadForCurrentUser(),
      favoritesModel.reloadForCurrentUser(),
      ordersModel.reloadForCurrentUser(),
    ]);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoggedIn
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: isLoggedIn
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  if (isLoggedIn) const SizedBox(height: 40),
                  // صورة البروفايل: إذا كان أدمن نعرض hadil.jpg، وإلا أيقونة عامة
                  isAdmin && isLoggedIn
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundImage: AssetImage(
                              'assets/images/hadil.jpg',
                            ),
                            backgroundColor: Colors.red.shade100,
                          ),
                        )
                      : CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.red.shade100,
                          child: Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.red.shade700,
                          ),
                        ),
                  const SizedBox(height: 20),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),
                  if (isLoggedIn) ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.shopping_bag,
                          color: Colors.red,
                        ),
                        title: const Text('My Orders'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrdersPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: const Text('My Favorites'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FavoritesPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'You are not logged in',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  Align(
                    alignment: const Alignment(0, -0.28),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.red.shade100,
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 0.18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'You are not logged in',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Go to Login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
