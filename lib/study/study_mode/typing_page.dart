import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/study/study_mode/result_typing_page.dart';
import '../../constant/text_style.dart';
import '../firebase_study/fetch.dart';
import '../firebase_study/update.dart';
import '../word/text_to_speech.dart';

class TypingPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final int numberOfQuestions;
  final bool showAllWords;
  final Function(List<String>) onType;

  const TypingPage(
      {super.key,
      required this.topicId,
      required this.topicName,
      required this.numberOfWords,
      required this.numberOfQuestions,
      required this.onType,
      required this.showAllWords});

  @override
  State<TypingPage> createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  int _currentIndex = 0;
  GlobalKey _menuKey = GlobalKey();
  FocusNode _textFocus = FocusNode();
  List<String> correctAnswersInCode = [];
  List<String> correctAnswers = [];
  List<String> newCorrectAnswers = [];
  List<String> newCorrectAnswersInCode = [];
  int numberOfCorrectAns = 0;
  List<String> userAnswers = [];
  List<String> userAnswersInCode = [];
  bool showDefinition = false;
  List<DocumentSnapshot> words = [];
  String userInput = '';
  bool autoSpeak = true;
  bool hasSpoken = false;

  void updateCorrectAnswers() {
    List<String> newCorrectAnswers = [];
    List<String> newCorrectAnswersInCode = [];

    words.forEach((question) {
      String correctAnswer =
          showDefinition ? question['word'] : question['definition'];
      newCorrectAnswers.add(correctAnswer);
      newCorrectAnswersInCode.add(correctAnswer.toLowerCase());
    });

    setState(() {
      correctAnswers = newCorrectAnswers;
      correctAnswersInCode = newCorrectAnswersInCode;
    });
    print(correctAnswers);
  }

  void shuffleWords() {
    setState(() {
      List<int> indices = List<int>.generate(words.length, (index) => index);
      indices.shuffle();
      List<DocumentSnapshot> shuffledWords = List<DocumentSnapshot>.from(words);
      List<String> shuffledCorrectAnswers = List<String>.from(correctAnswers);
      List<String> shuffledCorrectAnswersInCode =
          List<String>.from(correctAnswersInCode);

      words.clear();
      indices.forEach((index) {
        words.add(shuffledWords[index]);
      });

      correctAnswers.clear();
      correctAnswersInCode.clear();
      indices.forEach((index) {
        correctAnswers.add(shuffledCorrectAnswers[index]);
        correctAnswersInCode.add(shuffledCorrectAnswersInCode[index]);
      });
    });
  }

  void fetchAnswers(List<DocumentSnapshot> words) async {
    try {
      List<DocumentSnapshot> selectedQuestions =
          words.sublist(0, words.length);

      selectedQuestions.forEach((question) {
        String correctAnswer =
            showDefinition ? question['word'] : question['definition'];
        correctAnswers.add(correctAnswer);
        correctAnswersInCode.add(correctAnswer.toLowerCase());
        newCorrectAnswers.add(correctAnswer);
        newCorrectAnswersInCode.add(correctAnswer.toLowerCase());
      });

      setState(() {
        correctAnswers = newCorrectAnswers;
        correctAnswersInCode = newCorrectAnswersInCode;
      });
    } catch (error) {
      throw error;
    }
  }

  void checkAnswer(String answer, int questionIndex) {
    String correctAnswer = correctAnswersInCode[questionIndex];
    bool isCorrect = answer.toLowerCase() == correctAnswer;
    String wordId = words[questionIndex].id;

    setState(() {
      userAnswers.add(userInput);
      userAnswersInCode.add(userInput.toLowerCase());
      numberOfCorrectAns++;
      userInput = '';
    });

    if(isCorrect) {
      if (words[_currentIndex]['countLearn'] >= 2) {
        updateWordStatus(
            widget.topicId,
            words[_currentIndex].id,
            'Mastered');
        updateCountLearn(widget.topicId,
            words[_currentIndex].id);
        print('Mastered');
      } else {
        updateWordStatus(
            widget.topicId,
            words[_currentIndex].id,
            'Learned');
        updateCountLearn(widget.topicId,
            words[_currentIndex].id);
        print('Learned');
      }
    } else {
      print('incorrect $isCorrect');
      updateWordStatus(widget.topicId, wordId, 'Unlearned');
    }

    _textFocus.unfocus();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Correct!' : 'Incorrect!'),
          content: Text(isCorrect
              ? 'You answer correctly.'
              : 'The correct answer is: $correctAnswer'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_currentIndex <= words.length - 1) {
                  setState(() {
                    _currentIndex++;
                    hasSpoken = false;
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Quiz Completed!'),
                        content: const Text('You have finished all questions.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    widget.onType(userAnswers);
  }

  @override
  void initState() {
    super.initState();
    fetchWords(widget.topicId).then((List<DocumentSnapshot> fetchedWords) {
      setState(() {
        if (widget.showAllWords) {
          words = fetchedWords;
        } else {
          words = fetchedWords
              .where((word) => word['isFavorited'] == true)
              .toList();
        }

        if (words.isNotEmpty) {
          speak(words[_currentIndex]['word']);
        }
      });
      fetchAnswers(words);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: _currentIndex >= words.length
              ? words.isEmpty
                  ? null
                  : Text(
                      'Result',
                      style: appBarStyle,
                    )
              : Text(
                  "${_currentIndex + 1}/${words.length}",
                  style: appBarStyle,
                ),
        ),
        actions: [
          const SizedBox(width: 15),
          PopupMenuButton<String>(
            key: _menuKey,
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'switchLanguage',
                child: ListTile(
                  leading: Icon(Icons.switch_camera),
                  title: Text('Switch language'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'shuffle',
                child: ListTile(
                  leading: Icon(Icons.shuffle),
                  title: Text('Shuffle words'),
                ),
              ),
            ],
            onSelected: (String choice) {
              if (choice == 'switchLanguage') {
                setState(() {
                  showDefinition = !showDefinition;
                  updateCorrectAnswers();
                });
              } else if (choice == 'shuffle') {
                shuffleWords();
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: Future.value(words),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              words = snapshot.data ?? [];
              if (words.isEmpty) {
                return Container(
                  color: Colors.lightBlueAccent,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Please provide at least',
                          style: normalText,
                        ),
                        Text(
                          '3 vocabulary words to start',
                          style: normalText,
                        ),
                        Text(
                          'studying',
                          style: normalText,
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (_currentIndex >= words.length) {
                int correctCount = 0;
                for (int i = 0; i < words.length; i++) {
                  if (userAnswersInCode[i] == correctAnswersInCode[i]) {
                    correctCount++;
                  }
                }
                return buildTypingResult(correctCount, words.length,
                    userAnswers, correctAnswers, words, showDefinition);
              }
              if (!hasSpoken && autoSpeak) {
                String wordToSpeak = words[_currentIndex]['word'];
                speak(wordToSpeak);
                hasSpoken = true;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!showDefinition)
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                              size: 30,
                            ),
                            onPressed: () {
                              String word = showDefinition
                                  ? words[_currentIndex]['definition']
                                  : words[_currentIndex]['word'];
                              speak(word);
                            },
                          ),
                        Text(
                          showDefinition
                              ? words[_currentIndex]['definition']
                              : words[_currentIndex]['word'],
                          style: const TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: UniqueKey(),
                            focusNode: _textFocus,
                            onChanged: (value) {
                              userInput = value;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Type your answer here...',
                              labelText: 'Answer',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            checkAnswer(userInput, _currentIndex);
                          },
                          child: const Icon(Icons.navigate_next, size: 50),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(10, 60),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
