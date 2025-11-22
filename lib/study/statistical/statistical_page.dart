import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/study/statistical/statistical_word.dart';
import '../../constant/text_style.dart';
import '../firebase_study/fetch.dart';
import '../firebase_study/update.dart';

class StatisticalPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final String text;
  final bool isPrivate;
  final String userId;
  final DateTime timeCreated;
  final DateTime lastAccess;

  const StatisticalPage({
    Key? key,
    required this.topicId,
    required this.numberOfWords,
    required this.topicName,
    required this.text,
    required this.isPrivate,
    required this.userId, required this.timeCreated, required this.lastAccess,
  }) : super(key: key);

  @override
  State<StatisticalPage> createState() => _StatisticalPageState();
}

class _StatisticalPageState extends State<StatisticalPage> {
  int learnedCount = 0;
  int unlearnedCount = 0;
  int masteredCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.topicName, style: appBarStyle),
            Text(
              'Number of Words: ${widget.numberOfWords}',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              child: FutureBuilder(
                future: fetchWords(widget.topicId),
                builder:
                    (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<DocumentSnapshot> words = snapshot.data!;
                    learnedCount = 0;
                    unlearnedCount = 0;
                    masteredCount = 0;
                    for (var wordSnapshot in words) {
                      String status = wordSnapshot['status'];
                      if (status == 'Learned') {
                        learnedCount++;
                      } else if (status == 'Unlearned') {
                        unlearnedCount++;
                      } else {
                        masteredCount++;
                      }
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Unlearned: $unlearnedCount',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[900]),
                          ),
                          Text(
                            'Learned: $learnedCount',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900]),
                          ),
                          Text(
                            'Mastered: $masteredCount',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900]),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(
              height: 700,
              child: FutureBuilder(
                future: fetchWords(widget.topicId),
                builder:
                    (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<DocumentSnapshot> words = snapshot.data!;
                    learnedCount = 0;
                    unlearnedCount = 0;
                    masteredCount = 0;
                    for (var wordSnapshot in words) {
                      String status = wordSnapshot['status'];
                      if (status == 'Learned') {
                        learnedCount++;
                      } else if (status == 'Unlearned') {
                        unlearnedCount++;
                      } else {
                        masteredCount++;
                      }
                    }
                    return ListView.builder(
                      itemCount: words.length,
                      itemBuilder: (context, index) {
                        String word = words[index]['word'];
                        String definition = words[index]['definition'];
                        String status = words[index]['status'];
                        return StatisticalWord(
                          word: word,
                          definition: definition,
                          status: status,
                          wordId: words[index].id,
                          topicId: widget.topicId,
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
