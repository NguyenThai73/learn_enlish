import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/constant/text.dart';
import 'package:learning_english/study/firebase_study/add.dart';

import 'home/home.dart';
import 'setting/setting.dart';
import 'study/study.dart';
import 'study/topic/add_topic_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: bottomNavigationOptions.elementAt(_selectedIndex),
        actions: [
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                size: 40,
                color: Colors.white,
              ),
              onPressed: () {
                _showAddOptionsDialog(context);
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomePage(),
          StudyAppPage(),
          SettingPage(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.blue,
        backgroundColor: Colors.white,
        buttonBackgroundColor: Colors.blue,
        items: const <Widget>[
          Icon(Icons.home, size: 40, color: Colors.white),
          Icon(Icons.book, size: 40, color: Colors.white),
          Icon(Icons.settings, size: 40, color: Colors.white),
        ],
        onTap: _onItemTapped,
        index: _selectedIndex,
        height: 50,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showAddOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddTopicScreen()),
                    );
                  },
                  child: const Text('Create New Topic'),
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _showNewFolderDialog(context);
                  },
                  child: const Text('Create New Folder'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNewFolderDialog(BuildContext context) {
    String folderName = '';
    String text = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Folder Name'),
                onChanged: (value) {
                  folderName = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  text = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                addFolder(folderName, text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
