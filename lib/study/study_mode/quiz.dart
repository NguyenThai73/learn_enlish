import 'package:flutter/material.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
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
          Icon(Icons.quiz, color: Colors.cyan[200], size: 35,),
          const SizedBox(width: 10),
          const Text("Quiz", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),)
        ],
      ),

    );
  }
}
