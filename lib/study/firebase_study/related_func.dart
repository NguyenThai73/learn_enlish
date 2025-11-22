import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/constant/toast.dart';

Future<void> setPrivateTopic(
    BuildContext context, String topicId, bool isPrivate) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .get();
      String? ownerId = topicSnapshot['createdBy'];

      if (ownerId == user.uid) {
        await FirebaseFirestore.instance
            .collection('topics')
            .doc(topicId)
            .update({'isPrivate': isPrivate});
        isPrivate
            ? showToast('This topic is set to private')
            : showToast('This topic is set to public');
      } else {
        showToast('You do not have permission to modify this topic');
      }
    } else {
      showToast('Please sign in to modify the topic');
    }
  } catch (e) {
    print('Error updating topic: $e');
  }
}

List<DocumentSnapshot> sortTopicsByTime(
    List<DocumentSnapshot> topics, String sortBy) {
  topics.sort((a, b) {
    DateTime timeA = (a[sortBy] as Timestamp).toDate();
    DateTime timeB = (b[sortBy] as Timestamp).toDate();
    return timeB
        .compareTo(timeA);
  });
  return topics;
}

Future<void> checkAndAddAccess(String topicId) async {
  try {
    String userUid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot accessSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('access')
        .doc(userUid)
        .get();

    if (!accessSnapshot.exists) {
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('access')
          .doc(userUid)
          .set({});

      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .update({'accessPeople': FieldValue.increment(1)});

      print('Access added successfully');
    } else {
      print('User already has access');
    }
  } catch (e) {
    print('Error checking and adding access: $e');
  }
}

Future<void> duplicateTopic(String topicId, String userId) async {
  try {
    DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .get();
    Map<String, dynamic> topicData =
    topicSnapshot.data() as Map<String, dynamic>;
    DateTime currentTime = DateTime.now();

    await FirebaseFirestore.instance.collection('topics').add({
      ...topicData,
      'isPrivate': true,
      'createdBy': userId,
      'timeCreated': currentTime,
      'lastAccess': currentTime,
      'accessPeople': 0,
    });

    print('Topic duplicated successfully');
  } catch (e) {
    print('Error duplicating topic: $e');
  }
}

