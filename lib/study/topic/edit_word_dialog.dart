import 'package:flutter/material.dart';

class EditWordDialog extends StatelessWidget {
  final String initialWord;
  final String initialDefinition;
  final Function(String, String) onSave; // Define onSave function

  EditWordDialog({
    required this.initialWord,
    required this.initialDefinition,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController wordController =
    TextEditingController(text: initialWord);
    TextEditingController definitionController =
    TextEditingController(text: initialDefinition);

    return AlertDialog(
      title: Text('Edit Word'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: wordController,
            decoration: InputDecoration(labelText: 'Word'),
          ),
          TextField(
            controller: definitionController,
            decoration: InputDecoration(labelText: 'Definition'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            String newWord = wordController.text;
            String newDefinition = definitionController.text;
            onSave(newWord, newDefinition);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
