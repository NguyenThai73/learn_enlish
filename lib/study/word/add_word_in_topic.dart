import 'package:flutter/material.dart';
import 'package:learning_english/study/firebase_study/add.dart';

import '../../constant/text_style.dart';
import '../word/add_word.dart';
import '../word/word_pages.dart';

class AddWordInTopicScreen extends StatefulWidget {
  final String topicId;
  final void Function(String topicId) handleWordAdded;
  final Function(int) updateNumberOfWords;

  const AddWordInTopicScreen(
      {super.key,
      required this.topicId,
      required this.handleWordAdded,
      required this.updateNumberOfWords});

  @override
  _AddWordInTopicScreenState createState() => _AddWordInTopicScreenState();
}

class _AddWordInTopicScreenState extends State<AddWordInTopicScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Add new Word', style: appBarStyle),
        actions: [
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white, size: 40),
            onPressed: () {
              _submitForm();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addWordPage();
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...wordPages,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      List<Map<String, String>> wordsData = [];

      for (Widget wordPage in wordPages) {
        if (wordPage is AddWordScreen) {
          AddWordScreenState? wordPageState =
              (wordPage.key as GlobalKey<AddWordScreenState>).currentState;

          if (wordPageState != null) {
            String? word = wordPageState.getWord();
            String? definition = wordPageState.getDefinition();
            String? status = wordPageState.getStatus();
            bool? isFavorited = wordPageState.getIsFavorited();
            int? countLearn = wordPageState.getCountLearn();

            wordsData.add({
              'word': word,
              'definition': definition,
              'status': status,
              'isFavorited': isFavorited.toString() ?? '',
              'countLearn': countLearn.toString()
            });
          }
        }
      }
      try {
        addWord(widget.topicId, wordsData);
      } catch (e) {
        print("Loi :$e");
      }
      widget.updateNumberOfWords(wordsData.length);
      widget.handleWordAdded(widget.topicId);
      wordPages.clear();
      Navigator.of(context).pop();
    }
  }

  void addWordPage() {
    setState(() {
      if (wordPages.isNotEmpty) {
        wordPages.add(const SizedBox(height: 20));
      }
      wordPages.add(AddWordScreen(key: AddWordScreen.generateUniqueKey()));
    });
  }
}
