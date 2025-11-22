import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddTopicToFolderScreen extends StatelessWidget {
  final Function(String) onSelectFolder;

  const AddTopicToFolderScreen({Key? key, required this.onSelectFolder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('folders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            String folderId = document.id;
            String folderName = document['name'];
            String text = document['text'];
            return ListTile(
              title: Text(folderName),
              subtitle: Text(text),
              onTap: () {
                onSelectFolder(folderId);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
