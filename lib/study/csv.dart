import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/constant/toast.dart';
import 'package:learning_english/study/firebase_study/add.dart';
import 'firebase_study/fetch.dart';

void pickAndProcessCsvFile(
    String topicId,
    void Function(String) handleWordAdded,
    Function(int) updateNumberOfWords) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    FilePickerStatus.done;

    if (result == null) {
      return;
    }

    String? filePath = result.files.single.path;
    if (filePath == null) {
      print('File path is null');
      return;
    }

    File file = File(filePath);
    String fileContent = await file.readAsString();

    List<List<dynamic>> csvData = CsvToListConverter().convert(fileContent);

    List<Map<String, String>> words = [];
    for (int i = 1; i < csvData.length; i++) {
      String word = csvData[i][0].toString();
      String definition = csvData[i][1].toString();
      words.add({'word': word, 'definition': definition});
    }

    addWord(topicId, words);
    handleWordAdded(topicId);
    updateNumberOfWords(words.length);
    showToast("Imported successfully");
    showToast("Please go back to previous page to see the change");
  } catch (e) {
    print('Error picking/processing CSV file: $e');
  }
}

List<Map<String, dynamic>> convertDocumentSnapshotsToMapList(
    List<DocumentSnapshot<Object?>> documentSnapshots) {
  return documentSnapshots.map((snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return {
      'word': data['word'],
      'definition': data['definition'],
      'status': data['status'],
      'isFavorited': data['isFavorited'],
    };
  }).toList();
}

Future<void> exportTopicToCSV(List<Map<String, dynamic>> words,
    String topicName, BuildContext context) async {
  List<List<dynamic>> csvData = [
    ['word', 'definition', 'status', 'isFavorited']
  ];

  // Convert the list of words into a List<List<dynamic>> format for CSV conversion
  csvData.addAll(words.map((word) {
    return [
      word['word'],
      word['definition'],
      word['status'],
      word['isFavorited'],
    ];
  }).toList());

  String csvString = const ListToCsvConverter().convert(csvData);

  Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
  String downloadsPath = downloadsDirectory.path;
  String filePath = '$downloadsPath/$topicName.csv';

  await File(filePath).writeAsString(csvString);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('File exported successfully to: $filePath'),
    ),
  );
}
