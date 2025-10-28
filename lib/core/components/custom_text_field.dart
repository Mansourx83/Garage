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
    this.suffixText,
    this.validator,
    this.enable,
  });

  final TextEditingController controller;
  final String hint;
  final String? suffixText;
  final TextInputType type;
  final IconData? icon;
  final bool? obscure;
  final int? maxLength;
  final String? Function(String?)? validator;
  final bool? enable;

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
          child: TextFormField(
            // ✅ استبدلنا TextField بـ TextFormField
            controller: controller,
            keyboardType: type,
            obscureText: obscure ?? false,
            enabled: enable,
            maxLength: maxLength,
            validator:
                validator ??
                (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter $hint';
                  }
                  return null;
                },
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              prefixIcon: icon != null
                  ? Icon(icon, color: Colors.white, size: 20)
                  : null,
              suffixText: suffixText,
              suffixStyle: const TextStyle(color: Colors.white70),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
              counterText: "",
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
