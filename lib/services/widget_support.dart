import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle HeadlineTextField() {
    return const TextStyle(
        color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins');
  }

  static TextStyle SimpleTextField() {
    return const TextStyle(
        color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Poppins');
  }

  static TextStyle SemiBoldTextField() {
    return const TextStyle(
        color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  }

  static TextStyle WhiteTextField() {
    return const TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins');
  }

  // New: Decoration for TextFields
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFFFF8A00)),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black38),
      filled: true,
      fillColor: const Color(0xFFF4F4F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF8A00)),
      ),
    );
  }
}