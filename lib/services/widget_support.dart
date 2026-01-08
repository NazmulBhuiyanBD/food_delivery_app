import 'package:flutter/material.dart';

class AppWidget{
  static TextStyle HeadlineTextField()
  {
    return TextStyle(
      color: Colors.black,
      fontSize: 25,
      fontWeight: FontWeight.bold
    );
  }
  static TextStyle SimpleTextField()
  {
    return TextStyle(
      color: Colors.black87,
      fontSize: 18,
    );
  }
  static TextStyle WhiteTextField()
  {
    return TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold
    );
  }
  static TextStyle boldTextField()
  {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold
    );
  }
  static TextStyle priceTextField()
  {
    return TextStyle(
      fontSize:22,
      fontWeight: FontWeight.bold,
      color: Colors.black87
    );
  }
}