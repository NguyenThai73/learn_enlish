import 'package:flutter/material.dart';
import 'package:learning_english/study/word/text_to_speech.dart';

import '../../constant/text_style.dart';
import '../firebase_study/delete.dart';
import '../firebase_study/update.dart';

class WordWithIconApp extends StatefulWidget {
  final String word;
  final String definition;
  final String status;
  final String isFavorited;
  final int countLearn;
  final String wordId;
  final String topicId;
  final void Function(String wordId) handleWordDeleted;

  const WordWithIconApp(
      {super.key,
      required this.word,
      required this.definition,
      required this.status,
      required this.wordId,
      required this.topicId,
      required this.isFavorited,
      required this.handleWordDeleted,
      required this.countLearn});

  @override
  State<WordWithIconApp> createState() => _WordWithIconAppState();
}

class _WordWithIconAppState extends State<WordWithIconApp> {
  late bool isFavorited;

  @override
  void initState() {
    super.initState();
    isFavorited = widget.isFavorited == 'true';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.indigo[900],
      elevation: 5,
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.word,
                    style: wordStyle,
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    widget.definition,
                    style: wordStyle,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    speak(widget.word);
                  },
                  child: const Icon(
                    Icons.volume_down_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    showDeleteConfirmationDialog(
                        context, widget.topicId, widget.wordId);
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isFavorited = !isFavorited;
                      updateWordIsFavorited(
                          widget.topicId, widget.wordId, isFavorited);
                    });
                  },
                  child: Icon(
                    isFavorited
                        ? Icons.star
                        : Icons.star_border_purple500_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog(
      BuildContext context, String topicId, String wordId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove word'),
          content: const Text('Are you sure you want to remove this word?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteWord(context, topicId, wordId);
                widget.handleWordDeleted(wordId);
                Navigator.of(context).pop();
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
