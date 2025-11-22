import 'package:flutter/material.dart';

class CustomCardDecoration {
  static final BoxDecoration cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(color: Colors.blue[500]!),
    gradient: LinearGradient(
      colors: [
        Colors.blue.shade300,
        Colors.blue.shade500,
        Colors.blue.shade700,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

class CustomSearchBar {
  static final BoxDecoration searchBarDecoration = BoxDecoration(
      gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
      ),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.blueGrey)
  );
}
