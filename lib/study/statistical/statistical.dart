import 'package:flutter/material.dart';
import 'package:learning_english/study/statistical/statistical_page.dart';
import '../../constant/style.dart';

class StatisticalItem extends StatelessWidget {
  final String topicId;
  final String topicName;
  final String text;
  final int numberOfWords;
  final bool isPrivate;
  final String userId;
  final DateTime timeCreated;
  final DateTime lastAccess;

  const StatisticalItem({
    Key? key,
    required this.topicId,
    required this.topicName,
    required this.text,
    required this.numberOfWords,
    required this.isPrivate,
    required this.userId,
    required this.timeCreated,
    required this.lastAccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatisticalPage(
              topicId: topicId,
              topicName: topicName,
              numberOfWords: numberOfWords,
              text: text,
              isPrivate: isPrivate,
              userId: userId,
              timeCreated: timeCreated,
              lastAccess: lastAccess,
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
              topicName,
              style: const TextStyle(fontSize: 30.0, color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
                Text(
                  '$numberOfWords words',
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ],
            ),
            trailing: Visibility(
              visible: isPrivate,
              child: const Icon(Icons.lock, size: 30, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
