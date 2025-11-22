import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/study/study_mode/result_quiz_page.dart';
import '../../constant/text_style.dart';
import '../firebase_study/fetch.dart';
import '../firebase_study/update.dart';
import '../word/text_to_speech.dart';
import 'answer.dart';

class QuizPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int numberOfWords;
  final int numberOfQuestions;
  final bool showAllWords;
  final Function(List<String>) onSelectAnswer;

  const QuizPage({
    Key? key,
    required this.topicId,
    required this.topicName,
    required this.numberOfQuestions,
    required this.numberOfWords,
    required this.onSelectAnswer,
    required this.showAllWords,
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  GlobalKey _menuKey = GlobalKey();
  List<DocumentSnapshot> questions = [];
  List<List<String>> options = [];
  List<List<bool>> optionSelected = [];
  List<String> correctAnswers = [];
  int numberOfCorrectAns = 0;
  List<String> selectedAnswers = [];
  String correctAns = '';
  bool showDefinition = false;
  List<DocumentSnapshot> words = [];
  bool autoSpeak = true;
  bool hasSpoken = false;

  void shuffleQuestionsAndOptions() {
    setState(() {
      List<int> indices = List<int>.generate(words.length, (index) => index);
      indices.shuffle();
      List<DocumentSnapshot> shuffledWords = List<DocumentSnapshot>.from(words);
      List<List<String>> shuffledOptions = List<List<String>>.from(options);
      List<String> shuffledCorrectAnswers = List<String>.from(correctAnswers);

      words.clear();
      options.clear();
      correctAnswers.clear();

      indices.forEach((index) {
        words.add(shuffledWords[index]);
        options.add(shuffledOptions[index]);
        correctAnswers.add(shuffledCorrectAnswers[index]);
      });
    });
  }

  void fetchQuestions(List<DocumentSnapshot> words) async {
    try {
      List<DocumentSnapshot> selectedQuestions =
      words.sublist(0, words.length);

      List<List<String>> newOptions = [];

      selectedQuestions.forEach((question) {
        String correctAnswer =
        showDefinition ? question['word'] : question['definition'];

        List<String> allOptions = [correctAnswer];

        List<DocumentSnapshot> shuffledWords = List.from(words)..shuffle();

        shuffledWords.forEach((word) {
          if (allOptions.length < 4) {
            String option = showDefinition ? word['word'] : word['definition'];
            if (option != correctAnswer && !allOptions.contains(option)) {
              allOptions.add(option);
            }
          }
        });

        allOptions.shuffle();
        newOptions.add(allOptions);
      });

      setState(() {
        questions.clear();
        options = newOptions;
        correctAnswers.clear();
        selectedAnswers.clear();
        optionSelected.clear();

        selectedQuestions.forEach((question) {
          String correctAnswer =
          showDefinition ? question['word'] : question['definition'];
          List<bool> selected =
          List.generate(options[questions.length].length, (index) => false);
          questions.add(question);
          correctAnswers.add(correctAnswer);
          selectedAnswers.add('');
          optionSelected.add(selected);
        });
      });
    } catch (error) {
      throw error;
    }
  }

  void checkAnswer(String selectedOption, int questionIndex) {
    String correctAnswer = correctAnswers[questionIndex];
    bool isCorrect = selectedOption == correctAnswer;
    String wordId = words[questionIndex].id;

    setState(() {
      correctAns = correctAnswer;
      numberOfCorrectAns++;
      selectedAnswers[questionIndex] = selectedOption;
      optionSelected[questionIndex] = List.generate(
        optionSelected[questionIndex].length,
        (index) => options[questionIndex][index] == selectedOption,
      );
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Correct!' : 'Incorrect!'),
          content: Text(isCorrect
              ? 'You chose the correct answer.'
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
    setState(() {});
    // Call the onSelectAnswer callback with the selected answers
    widget.onSelectAnswer(selectedAnswers);
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
      });
      fetchQuestions(words);
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
                  fetchQuestions(words);
                });
              } else if (choice == 'shuffle') {
                shuffleQuestionsAndOptions();
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
                for (int i = 0; i < selectedAnswers.length; i++) {
                  if (selectedAnswers[i] == correctAnswers[i]) {
                    correctCount++;
                  }
                }
                return buildQuizResult(correctCount, words.length,
                    selectedAnswers, correctAnswers, words, showDefinition);
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
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      buildQuizOptions(options[_currentIndex],
                          optionSelected[_currentIndex], correctAns, words),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildQuizOptions(List<String> options, List<bool> optionSelected,
      String correctAns, List<DocumentSnapshot> words) {
    return Column(
      children: options.asMap().entries.map((entry) {
        int index = entry.key;
        String option = entry.value;
        bool isSelected = optionSelected[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => checkAnswer(option, _currentIndex),
            child: Answer(
              topicId: widget.topicId,
              word: showDefinition ? option : words[index]['word'],
              definition: showDefinition ? words[index]['definition'] : option,
              isSelected: isSelected,
              correct: correctAns,
              showDefinition: showDefinition,
            ),
          ),
        );
      }).toList(),
    );
  }
}
