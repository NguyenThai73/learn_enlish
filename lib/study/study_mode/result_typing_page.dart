import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Widget buildTypingResult(int correctCount, int numberOfQuestions,
    List<String> userAnswers, List<String> correctAnswers,
    List<DocumentSnapshot> words, bool showDefinition) {
  String getFeedback(int correctCount) {
    double percentage =
        (correctCount / numberOfQuestions) * 100;
    String feedback = '';
    if (percentage > 80) {
      feedback = 'Excellent';
    } else if (percentage < 50) {
      feedback = 'Practice more';
    } else {
      feedback = 'Good job';
    }
    return feedback;
  }

  Color getFeedbackColor(int correctCount) {
    double percentage =
        (correctCount / numberOfQuestions) * 100;
    if (percentage > 80) {
      return Colors.green.shade600;
    } else if (percentage < 50) {
      return Colors.red;
    } else {
      return Colors.lightGreen.shade400;
    }
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Quiz Completed!',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Total Score: $correctCount / $numberOfQuestions',
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          'Feedback: ${getFeedback(correctCount)}',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: getFeedbackColor(correctCount)),
        ),
        const SizedBox(height: 20),
        const Text(
          'Questions answered correctly:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Column(
          children: userAnswers.asMap().entries.map((entry) {
            int index = entry.key;
            String answer = entry.value;
            bool isCorrect = answer.toLowerCase() ==
                correctAnswers[index].toLowerCase();
            return ListTile(
              title: Text(
                showDefinition
                    ? 'Question: ${words[index]['definition']}'
                    : 'Question: ${words[index]['word']}',
                style: TextStyle(
                    color: isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
              subtitle: Text(
                'Your Answer: $answer\nCorrect Answer: ${correctAnswers[index]}',
                style: TextStyle(
                    color: isCorrect ? Colors.green : Colors.red,
                    fontSize: 20),
              ),
            );
          }).toList(),
        )
      ],
    ),
  );
}
