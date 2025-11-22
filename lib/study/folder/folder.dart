import 'package:flutter/material.dart';

import '../../constant/style.dart';
import 'folder_page.dart';

class FolderItem extends StatelessWidget {
  final String folderId;
  final String folderName;
  final String text;

  const FolderItem({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderPage(
              folderId: folderId,
              folderName: folderName,
              text: text,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blue[600],
        elevation: 10,
        child: Container(
          decoration: CustomCardDecoration.cardDecoration,
          child: ListTile(
            leading: const Icon(Icons.topic, size: 60, color: Colors.white),
            title: Text(
              folderName,
              style: const TextStyle(fontSize: 30.0, color: Colors.white),
            ),
            subtitle: Text(
              text,
              style: const TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
