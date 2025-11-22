import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/constant/text_style.dart';

Widget buildFlashCardResult(
    int countLearned, int countUnlearned, int numberOfQuestions) {
  String getFeedback(int countLearned) {
    double percentage = (countLearned / numberOfQuestions) * 100;
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

  Color getFeedbackColor(int countLearned) {
    double percentage = (countLearned / numberOfQuestions) * 100;
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
          'Completed!',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Feedback: ${getFeedback(countLearned)}',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: getFeedbackColor(countLearned)),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                countUnlearned < countLearned
                    ? const Icon(
                        Icons.check_circle,
                        size: 120,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.error_outline,
                        size: 120,
                        color: Colors.red,
                      )
              ],
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Learned: ${countLearned}",
                        style: countUnlearned == countLearned
                            ? learned
                            : (countLearned > countUnlearned
                                ? learned
                                : opposite))
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Unlearned: ${countUnlearned}",
                      style: countUnlearned == countLearned
                          ? unlearned
                          : (countUnlearned > countLearned
                              ? unlearned
                              : opposite),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ],
    ),
  );
}
