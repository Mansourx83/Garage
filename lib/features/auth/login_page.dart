import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garage/core/components/custom_button.dart';
import 'package:garage/core/components/custom_snackbar.dart';
import 'package:garage/core/components/custom_text_field.dart';
import 'package:garage/features/auth/auth_page.dart';
import 'package:garage/features/home/home_page.dart'; // صفحة الهوم (هتحتاج تعملها)
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginUser() async {
    final supabase = Supabase.instance.client;
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showCustomSnackBar(context, 'Please fill all fields', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      // ✅ التحقق من حالة التفعيل
      if (user != null && user.emailConfirmedAt == null) {
        showCustomSnackBar(
          context,
          'Your email is not confirmed. We sent you a new verification email.',
          isError: true,
        );

        setState(() => isLoading = false);
        return;
      }

      if (response.session != null) {
        showCustomSnackBar(context, 'Login successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        showCustomSnackBar(
          context,
          'Email or password is incorrect.',
          isError: true,
        );
      } else {
        showCustomSnackBar(context, e.message, isError: true);
      }
    } catch (e) {
      showCustomSnackBar(context, 'Something went wrong', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
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
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        /// حقل البريد الإلكتروني
                        CustomTextField(
                          controller: emailController,
                          hint: 'Email',
                          type: TextInputType.emailAddress,
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 16),

                        /// حقل كلمة المرور
                        CustomTextField(
                          controller: passwordController,
                          hint: 'Password',
                          type: TextInputType.text,
                          icon: Icons.lock,
                          obscure: true,
                        ),
                        const SizedBox(height: 24),

                        /// زر تسجيل الدخول
                        CustomButton(
                          text: isLoading ? 'Logging in...' : 'Login',
                          fontSize: 16,
                          onTap: isLoading ? null : loginUser,
                        ),

                        const SizedBox(height: 8),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Don't have an account? Sign Up",
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
