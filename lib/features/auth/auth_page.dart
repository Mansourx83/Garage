import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:garage/core/components/custom_button.dart';
import 'package:garage/core/components/custom_snackbar.dart';
import 'package:garage/core/components/custom_text_field.dart';
import 'package:garage/features/auth/login_page.dart';
import 'package:garage/features/home/home_page.dart'; // ✅ تأكد إن عندك صفحة HomePage
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  final String defaultAvatarUrl =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrxWd_qyeMG-05UoSEmiNlEcKzWnIpoXdl_A&s";

  /// ✅ التحقق من صحة الإيميل
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// ✅ التحقق من قوة الباسورد
  bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  Future<void> createAccount() async {
  final supabase = Supabase.instance.client;
  final name = nameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    showCustomSnackBar(context, 'Please fill all fields', isError: true);
    return;
  }

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(email)) {
    showCustomSnackBar(context, 'Invalid email address', isError: true);
    return;
  }

  if (password.length < 8) {
    showCustomSnackBar(context, 'Password must be at least 8 characters', isError: true);
    return;
  }

  setState(() => isLoading = true);

  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'avatar_url': defaultAvatarUrl},
      emailRedirectTo: 'https://your-app-url.com/verify', // رابط التفعيل (ممكن أي URL)
    );

    if (response.user != null) {
      showCustomSnackBar(
        context,
        'Account created! Please check your email to verify your account.',
      );

      // ✅ بعد الإنشاء نرجعه إلى صفحة تسجيل الدخول
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  } on AuthException catch (e) {
    showCustomSnackBar(context, e.message, isError: true);
  } catch (e) {
    showCustomSnackBar(context, 'Something went wrong', isError: true);
  } finally {
    setState(() => isLoading = false);
  }
}  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/car.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// تأثير Blur على الخلفية
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          /// الفورم الزجاجي
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    width: 350,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        /// حقل الاسم
                        CustomTextField(
                          controller: nameController,
                          hint: 'Name',
                          type: TextInputType.text,
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),

                        /// حقل البريد الإلكتروني
                        CustomTextField(
                          controller: emailController,
                          hint: 'Email',
                          type: TextInputType.emailAddress,
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 16),

                        /// حقل كلمة المرور (مخفي)
                        CustomTextField(
                          controller: passwordController,
                          hint: 'Password',
                          type: TextInputType.text,
                          icon: Icons.lock,
                          obscure: true,
                        ),
                        const SizedBox(height: 24),

                        /// زر التسجيل
                        CustomButton(
                          text: isLoading ? 'Creating...' : 'Create Account',
                          fontSize: 16,
                          onTap: isLoading ? null : createAccount,
                        ),
                        const SizedBox(height: 12),

                        /// رابط تسجيل الدخول
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
