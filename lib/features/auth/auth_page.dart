import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:garage/core/components/custom_button.dart';
import 'package:garage/core/components/custom_snackbar.dart';
import 'package:garage/core/components/custom_text_field.dart';
import 'package:garage/features/auth/login_page.dart';
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

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    return password.length >= 10 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  Future<void> createAccount() async {
    final supabase = Supabase.instance.client;
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // التحقق من الحقول
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showCustomSnackBar(context, 'Please fill all fields', isError: true);
      return;
    }

    if (!isValidEmail(email)) {
      showCustomSnackBar(context, 'Invalid email address', isError: true);
      return;
    }

    if (!isStrongPassword(password)) {
      showCustomSnackBar(
        context,
        'Password must be at least 10 characters, include a number & uppercase letter.',
        isError: true,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🟢 إنشاء الحساب فقط - الـ Trigger هيعمل الباقي!
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'avatar_url': defaultAvatarUrl,
          'address': 'Egypt',
        },
      );

      final user = response.user;

      if (user != null) {
        // ✅ الـ Trigger عمل INSERT تلقائي في جدول users
        showCustomSnackBar(
          context,
          '✅ Account created! Please check your email to verify.',
          duration: const Duration(seconds: 5),
        );

        await Future.delayed(const Duration(seconds: 5));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        showCustomSnackBar(
          context,
          'Failed to create account. Please try again.',
          isError: true,
        );
      }
    } on AuthException catch (e) {
      debugPrint('❌ AuthException: ${e.message}');
      showCustomSnackBar(context, e.message, isError: true);
    } catch (e, stack) {
      debugPrint('❌ Error: $e');
      debugPrint(stack.toString());
      showCustomSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🖼️ الخلفية (صورة عربية)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/car.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🌫️ تأثير Blur على الخلفية
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          /// 🧊 الفورم الزجاجي (Liquid Glass)
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

                        /// 🧍‍♂️ حقل الاسم
                        CustomTextField(
                          controller: nameController,
                          hint: 'Name',
                          type: TextInputType.text,
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),

                        /// ✉️ البريد الإلكتروني
                        CustomTextField(
                          controller: emailController,
                          hint: 'Email',
                          type: TextInputType.emailAddress,
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 16),

                        /// 🔒 كلمة المرور
                        CustomTextField(
                          controller: passwordController,
                          hint: 'Password',
                          type: TextInputType.text,
                          icon: Icons.lock,
                          obscure: true,
                        ),
                        const SizedBox(height: 24),

                        /// 🚀 زر التسجيل
                        CustomButton(
                          text: isLoading ? 'Creating...' : 'Create Account',
                          fontSize: 16,
                          onTap: isLoading ? null : createAccount,
                        ),
                        const SizedBox(height: 12),

                        /// 🔁 رابط تسجيل الدخول
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
