import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,

        style: const TextStyle(
          color: Colors.black,           // 🔥 teks yang diketik warna abu
        ),

        decoration: InputDecoration(
          labelText: label,

          prefixIcon: Icon(icon, color: Colors.blue),
          suffixIcon: suffixIcon,

          // 🔥 BACKGROUND LIGHT BLUE
          filled: true,
          fillColor: Colors.blue.shade50,

          // ===== OUTLINE DEFAULT =====
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          // ===== SAAT FOKUS (BIRU) =====
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),

          // ===== SAAT ENABLED =====
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.5,
            ),
          ),

          // ===== SAAT ERROR =====
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),

          // 🔥 warna label abu
          labelStyle: const TextStyle(color: Colors.blue),

          // 🔥 warna hint abu
          hintStyle: const TextStyle(color: Colors.blue),
        ),
      ),
    );
  }
}
