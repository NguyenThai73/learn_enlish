import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<QuerySnapshot> getTopics() {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('topics')
      .where('isPrivate', isEqualTo: false)
      .where('createdBy', isEqualTo: userUid)
      .snapshots();
}

Stream<QuerySnapshot> getFolders() {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('folders')
      .where('createdBy', isEqualTo: userUid)
      .snapshots();
}

Stream<QuerySnapshot> getTopicsInFolder(String folderId) {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('folders')
      .doc(folderId)
      .collection('topics')
      .where('isPrivate', isEqualTo: false)
      .where('createdBy', isEqualTo: userUid)
      .snapshots();
}

Future<List<DocumentSnapshot>> fetchWords(String topicId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('words')
        .get();

    return querySnapshot.docs;
  } catch (e) {
    print('Error fetching words: $e');
    rethrow;
  }
}

Future<List<DocumentSnapshot>> fetchTopics(String folderId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('folders')
        .doc(folderId)
        .collection('topics')
        .get();
    return querySnapshot.docs;
  } catch (e) {
    print('Error fetching topics: $e');
    rethrow;
  }
}

Future<List<DocumentSnapshot>> fetchAccess(String topicId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('access')
        .get();
    return querySnapshot.docs;
  } catch (e) {
    print('Error fetching access topic: $e');
    rethrow;
  }
}
