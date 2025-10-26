import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:garage/core/components/custom_button.dart';
import 'package:garage/core/components/custom_text_field.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// خلفية
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

                        /// حقل كلمة المرور
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
                          text: 'Create Account',
                          fontSize: 16,
                          onTap: () {},
                        ),

                        const SizedBox(height: 12),

                        /// رابط تسجيل الدخول
                        GestureDetector(
                          onTap: () {},
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
