import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.type,
    this.icon,
    this.obscure,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType type;
  final IconData? icon;
  final bool? obscure;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
            obscureText: obscure ?? false,
            maxLength: maxLength,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon, color: Colors.white) : null,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
              counterText: "", // يخفي عداد الحروف
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
