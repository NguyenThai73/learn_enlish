import 'package:flutter/material.dart';

class Type extends StatefulWidget {
  const Type({super.key});

  @override
  State<Type> createState() => _TypeState();
}

class _TypeState extends State<Type> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.indigo,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(Icons.type_specimen, color: Colors.cyan[200], size: 35,),
          const SizedBox(width: 10),
          const Text("Type", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }

}
