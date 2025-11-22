import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/constant/toast.dart';
import 'package:learning_english/study/folder/add_topic_in_folder.dart';
import 'package:learning_english/study/folder/remove_topic_in_folder.dart';

import '../../constant/color.dart';
import '../../constant/text_style.dart';
import '../firebase_study/add.dart';
import '../firebase_study/delete.dart';
import '../firebase_study/fetch.dart';
import '../firebase_study/update.dart';
import '../topic/topic.dart';
import 'edit_folder_dialog.dart';

class FolderPage extends StatelessWidget {
  final String folderId;
  final String folderName;
  final String text;

  const FolderPage(
      {super.key,
      required this.folderId,
      required this.folderName,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              folderName,
              style: appBarStyle,
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(
              Icons.folder_delete,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Remove Folder'),
                    content: const Text(
                      'Are you sure you want to remove this folder?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteFolder(context, folderId);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              editAction(context);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              _showTopicTab(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: button,
        onPressed: () {
          _addTopicToFolder(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              height: 60,
              width: 350,
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "Description: $text",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: fetchTopics(folderId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                }
                List<DocumentSnapshot> topics = snapshot.data!;
                return ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data![index];
                    String topicId = document.id;
                    String topicName = document['name'];
                    String text = document['text'];
                    int numberOfWords = document['numberOfWords'];
                    bool isPrivate = document['isPrivate'];
                    String userId = document['createdBy'];
                    DateTime timeCreated = document['timeCreated'];
                    DateTime lastAccess = document['lastAccess'];
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
            ),
          ),
        ],
      ),
    );
  }

  void editAction(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditFolderDialog(
          initialName: folderName,
          initialDescription: text,
          onSave: (String newName, String newDescription) {
            updateFolder(folderId, newName, newDescription);
          },
        );
      },
    );
  }

  void _showTopicTab(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return RemoveTopicInFolder(
          folderId: folderId,
          onSelectTopic: (topicId) {
            deleteTopicInFolder(context, topicId, folderId);
          },
        );
      },
    );
  }

  void _addTopicToFolder(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddTopicFromFolder(
          onSelectTopic: (topicId) {
            addTopicToFolder(topicId, folderId);
          },
        );
      },
    );
    showToast("Imported successfully");
    showToast("Please go back to the previous page to see result");
  }
}
