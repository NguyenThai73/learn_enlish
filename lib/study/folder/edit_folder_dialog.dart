import 'package:flutter/material.dart';

class EditFolderDialog extends StatelessWidget {
  final String initialName;
  final String initialDescription;
  final Function(String, String) onSave; // Define onSave function

  EditFolderDialog({
    required this.initialName,
    required this.initialDescription,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController =
    TextEditingController(text: initialName);
    TextEditingController descriptionController =
    TextEditingController(text: initialDescription);

    return AlertDialog(
      title: Text('Edit Folder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            String newName = nameController.text;
            String newDescription = descriptionController.text;
            onSave(newName, newDescription);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        )
      ],
    );
  }
}
