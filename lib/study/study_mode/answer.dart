import 'package:flutter/material.dart';

class Answer extends StatefulWidget {
  final String topicId;
  final String word;
  final String definition;
  final bool isSelected;
  final String correct;
  final bool showDefinition;

  Answer({
    Key? key,
    required this.topicId,
    required this.word,
    required this.definition,
    required this.isSelected,
    required this.correct,
    required this.showDefinition,
  }) : super(key: key);

  @override
  State<Answer> createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  bool _needsRebuild = false;

  @override
  void didUpdateWidget(Answer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if showDefinition changed (value comparison)
    if (oldWidget.showDefinition != widget.showDefinition) {
      _needsRebuild = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.shade400;
    if (widget.isSelected && widget.definition == widget.correct || widget.isSelected && widget.word == widget.correct) {
      borderColor = Colors.green.shade800;
    } else if (widget.isSelected && widget.definition != widget.correct || widget.isSelected && widget.word != widget.correct) {
      borderColor = Colors.red;
    }

    return FractionallySizedBox(
      widthFactor: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 0, 191, 255),
          border: Border.all(color: borderColor, width: 4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            widget.showDefinition ? widget.word : widget.definition,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
