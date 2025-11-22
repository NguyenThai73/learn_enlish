import 'package:flutter/material.dart';

class FlashCard extends StatefulWidget {
  const FlashCard({super.key});

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> {
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
          Icon(Icons.credit_card_rounded, color: Colors.cyan[200], size: 35,),
          const SizedBox(width: 10),
          const Text("Flash Card", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }

}
