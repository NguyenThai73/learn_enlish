import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> updateUserName(User user, String newUsername) async {
  try {
    String uid = user.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'displayName': newUsername});
    print('Username updated successfully.');
  } catch (e) {
    print('Error updating username: $e');
  }
}

Future<void> updatePassword(String newPassword) async {
  try {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    // If the user is signed in
    if (currentUser != null) {
      // Update the password
      await currentUser.updatePassword(newPassword);

      print('Password updated successfully.');
    } else {
      print('Error: No user is currently signed in.');
    }
  } catch (e) {
    print('Error updating password: $e');
  }
}

Future<String> updateAvatar(User user, String imagePath) async {
  try {
    String uid = user.uid;
    Reference storageReference =
        FirebaseStorage.instance.ref().child('avatars/$uid/avatar.jpg');
    UploadTask uploadTask = storageReference.putFile(File(imagePath));
    await uploadTask.whenComplete(() => null);
    String newAvatarURL = await storageReference.getDownloadURL();

    // Update the avatar URL in Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'avatarURL': newAvatarURL});

    return newAvatarURL;
  } catch (e) {
    print('Error updating avatar: $e');
    rethrow; // Rethrow the error to handle it appropriately in the caller
  }
}
