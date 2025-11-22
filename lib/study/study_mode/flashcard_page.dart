import 'dart:async';

import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/study/study_mode/result_flashcard_page.dart';

import '../../constant/text_style.dart';
import '../firebase_study/fetch.dart';
import '../firebase_study/update.dart';
import '../word/text_to_speech.dart';
import '../word/word.dart';

class FlashCardScreen extends StatefulWidget {
  final String topicId;
  final int numberOfWords;
  final bool showAllWords;

  const FlashCardScreen(
      {super.key,
      required this.topicId,
      required this.numberOfWords,
      required this.showAllWords});

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  int _currentIndex = 0;
  late List<String> wordStatuses;
  List<DocumentSnapshot> words = [];
  int countLearned = 0;
  int countUnlearned = 0;
  bool autoSpeak = true;
  bool showDefinition = false;
  late SwiperController _swiperController;
  Timer? _timer;
  bool autoplay = true;
  final GlobalKey _menuKey = GlobalKey();

  void shuffleWords(List<DocumentSnapshot> words) {
    setState(() {
      words.shuffle();
      _currentIndex = 0;
      if (autoSpeak) {
        speak(words[_currentIndex]['word']);
      }
      this.words = words;
    });
  }

  void updateLearnedStatus(String status) {
    setState(() {
      switch (status) {
        case 'Learned':
          countLearned++;
          break;
        case 'Unlearned':
          countUnlearned++;
          break;
      }
      if (widget.showAllWords) {
        _currentIndex = (_currentIndex + 1) % words.length;
      } else {
        _currentIndex = (_currentIndex + 1) % words.length;
      }
    });
  }

  void startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_swiperController.index < (words.length - 1)) {
        _swiperController.next();
        _swiperController.index++;
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController();
    startAutoPlay();
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
    });
    wordStatuses = List.filled(widget.numberOfWords, "");
  }

  @override
  void dispose() {
    _timer?.cancel();
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: countLearned + countUnlearned == words.length
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
              PopupMenuItem<String>(
                value: 'auto',
                child: ListTile(
                  leading: const Icon(Icons.auto_mode),
                  title: const Text('Auto'),
                  trailing: Switch(
                    value: autoplay,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() {
                        autoplay = value;
                        if (autoplay) {
                          startAutoPlay();
                        } else {
                          _timer?.cancel();
                        }
                        Navigator.of(context).pop();
                        (_menuKey.currentState as dynamic).showButtonMenu();
                      });
                    },
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'shuffle',
                child: ListTile(
                  leading: Icon(Icons.shuffle),
                  title: Text('Shuffle words'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'switchLanguage',
                child: ListTile(
                  leading: Icon(Icons.switch_camera),
                  title: Text('Switch language'),
                ),
              ),
            ],
            onSelected: (String choice) {
              if (choice == 'shuffle') {
                shuffleWords(List.from(words));
              } else if (choice == 'switchLanguage') {
                setState(() {
                  showDefinition = !showDefinition;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: 380,
              child: countLearned + countUnlearned == words.length
                  ? null
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          const SizedBox(height: 20),
                          if (words
                              .isNotEmpty) // Only render if words is not empty
                            SizedBox(
                              width: 380,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        updateLearnedStatus('Unlearned');
                                        updateWordStatus(
                                            widget.topicId,
                                            words[_currentIndex].id,
                                            'Unlearned');
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.red,
                                              width: 3,
                                            ),
                                          ),
                                          child: Center(
                                              child: Text(
                                            '$countUnlearned',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                        const SizedBox(width: 5),
                                        const Text(
                                          "Unlearned",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red),
                                        )
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (words[_currentIndex]
                                                ['countLearn'] >=
                                            2) {
                                          updateLearnedStatus('Mastered');
                                          updateWordStatus(
                                              widget.topicId,
                                              words[_currentIndex].id,
                                              'Mastered');
                                          updateCountLearn(widget.topicId,
                                              words[_currentIndex].id);
                                          print('Mastered');
                                        } else {
                                          updateLearnedStatus('Learned');
                                          updateWordStatus(
                                              widget.topicId,
                                              words[_currentIndex].id,
                                              'Learned');
                                          updateCountLearn(widget.topicId,
                                              words[_currentIndex].id);
                                          print('Learned');
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        const Text("Learned",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green)),
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.green,
                                              width: 3,
                                            ),
                                          ),
                                          child: Center(
                                              child: Text(
                                            '$countLearned',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 500,
              child: FutureBuilder(
                future: Future.value(words),
                builder:
                    (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
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
                    if (countLearned + countUnlearned == words.length) {
                      return buildFlashCardResult(
                          countLearned, countUnlearned, words.length);
                    }
                    _currentIndex = _currentIndex.clamp(0, words.length - 1);
                    if (autoSpeak && !showDefinition) {
                      speak(words[_currentIndex]['word']);
                    }
                    return Swiper(
                      key: UniqueKey(),
                      controller: _swiperController,
                      index: _currentIndex,
                      onIndexChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          if (autoSpeak && !showDefinition) {
                            speak(words[index]['word']);
                          }
                        });
                      },
                      pagination: const SwiperPagination(
                        builder: DotSwiperPaginationBuilder(
                          color: Colors.white,
                          activeColor: Colors.indigo,
                          activeSize: 15,
                          size: 10,
                        ),
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: words.length,
                      itemBuilder: (context, index) {
                        String word = words[index]['word'];
                        String definition = words[index]['definition'];
                        String status = words[index]['status'];
                        bool isFavorited = words[index]['isFavorited'];

                        return WordItemApp(
                            definition: definition,
                            word: word,
                            wordId: words[index].id,
                            topicId: widget.topicId,
                            status: status,
                            isFavorited: isFavorited.toString() ?? '',
                            showDefinition: showDefinition,
                            countLearn: 0);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
