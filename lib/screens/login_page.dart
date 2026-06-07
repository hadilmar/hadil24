import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/orders_provider.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSignUp = true; // true = Sign Up, false = Login
  static final BorderRadius _roundedRadius = BorderRadius.circular(30);
  static final List<BoxShadow> _softShadow = [
    BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6)),
  ];

  Future<void> _saveUserData(
    String email,
    String password,
    bool isAdmin,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_email', normalizedEmail);
    await prefs.setString('user_name', normalizedEmail.split('@').first);
    await prefs.setBool('is_admin', isAdmin);
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox(
                  width: 150,
                  height: 125,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, 8),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          color: Colors.black.withAlpha(55),
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        color: Colors.red,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // العنوان الرئيسي (مطابق للصورة)
              Text(
                _isSignUp ? 'SIGN UP' : 'LOG IN',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              // رابط التبديل (مطابق للصورة)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp ? 'Already Account | Login' : 'No Account? Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // حقل البريد الإلكتروني أو اسم المستخدم
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: _roundedRadius,
                  boxShadow: _softShadow,
                ),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email or username',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: _roundedRadius,
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: _roundedRadius,
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: _roundedRadius,
                      borderSide: BorderSide(color: Colors.red.shade500),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // حقل كلمة المرور
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: _roundedRadius,
                  boxShadow: _softShadow,
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: _roundedRadius,
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: _roundedRadius,
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: _roundedRadius,
                      borderSide: BorderSide(color: Colors.red.shade500),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // الزر الرئيسي (مطابق للصورة: أحمر، عريض، مستدير)
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter email or username'),
                      ),
                    );
                    return;
                  }

                  final email = emailController.text.trim().toLowerCase();
                  final password = passwordController.text;

                  // التحقق من بيانات المسؤول
                  bool isAdmin =
                      email == 'admin@dipndip.com' && password == 'admin123';

                  final cartModel = Provider.of<CartModel>(
                    context,
                    listen: false,
                  );
                  final favoritesModel = Provider.of<FavoritesModel>(
                    context,
                    listen: false,
                  );
                  final ordersModel = Provider.of<OrdersModel>(
                    context,
                    listen: false,
                  );

                  await _saveUserData(email, password, isAdmin);
                  if (!context.mounted) return;

                  await Future.wait([
                    cartModel.reloadForCurrentUser(),
                    favoritesModel.reloadForCurrentUser(),
                    ordersModel.reloadForCurrentUser(),
                  ]);
                  if (!context.mounted) return;

                  if (isAdmin) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('مرحبًا بك كمسؤول!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.black45,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: _roundedRadius),
                ),
                child: Text(
                  _isSignUp ? 'SIGN UP' : 'LOG IN',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
