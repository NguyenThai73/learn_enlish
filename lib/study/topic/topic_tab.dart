import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/constant/text_style.dart';

import '../firebase_study/related_func.dart';
import 'topic.dart';

class TopicTab extends StatefulWidget {
  const TopicTab({super.key});

  @override
  State<TopicTab> createState() => _TopicTabState();
}

class _TopicTabState extends State<TopicTab> {
  String _sortBy = 'timeCreated';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sort by:', style: normalTextBlack),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.blue,
                        value: _sortBy,
                        onChanged: (String? newValue) {
                          setState(() {
                            _sortBy = newValue!;
                          });
                        },
                        items: <String>['timeCreated', 'lastAccess']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                value == 'timeCreated'
                                    ? 'Creation time'
                                    : 'Last access',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        )),
        Expanded(
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (userSnapshot.hasError) {
                return Text('Error: ${userSnapshot.error}');
              }
              if (userSnapshot.data == null) {
                return const Center(
                  child: Text('No user signed in.'),
                );
              }
              String currentUserId = userSnapshot.data!.uid;
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('topics')
                    .where('createdBy', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  List<DocumentSnapshot> sortedTopics =
                      sortTopicsByTime(snapshot.data!.docs, _sortBy);

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No topics created by the user.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: sortedTopics.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot document = sortedTopics[index];
                      String topicId = document.id;
                      String topicName = document['name'];
                      String text = document['text'];
                      int numberOfWords = document['numberOfWords'];
                      bool isPrivate = document['isPrivate'];
                      String userId = document['createdBy'];
                      DateTime timeCreated =
                          (document['timeCreated'] as Timestamp).toDate();
                      DateTime lastAccess =
                          (document['lastAccess'] as Timestamp).toDate();
                      int accessPeople = document['accessPeople'];

                      return TopicComponent(
                        topicId: topicId,
                        topicName: topicName,
                        text: text,
                        numberOfWords: numberOfWords,
                        isPrivate: isPrivate,
                        userId: userId,
                        timeCreated: timeCreated,
                        lastAccess: lastAccess,
                        accessPeople: accessPeople,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
