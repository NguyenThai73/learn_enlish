import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTopicFromFolder extends StatelessWidget {
  final Function(String) onSelectTopic;

  const AddTopicFromFolder({Key? key, required this.onSelectTopic});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('topics').snapshots(),
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
            String topicId = document.id;
            String topicName = document['name'];
            String text = document['text'];
            return ListTile(
              title: Text(topicName),
              subtitle: Text(text),
              onTap: () {
                onSelectTopic(topicId);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
