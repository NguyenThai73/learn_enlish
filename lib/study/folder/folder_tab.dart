import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/study/firebase_study/fetch.dart';
import 'folder.dart';

class FolderTab extends StatelessWidget {
  const FolderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getFolders(),
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
            return FolderItem(
              folderName: folderName,
              text: text,
              folderId: folderId,
            );
          },
        );
      },
    );
  }
}