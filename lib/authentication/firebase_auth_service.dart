import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(BuildContext context, String email, String password, String username) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await addUserToFirestore(credential.user!, username); // Pass username to add to Firestore
      await credential.user!.updateDisplayName(username); // Update display name
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("The email address is already in use");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The email address is already in use'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print("An error occurred: ${e.code}");
      }
    }
    return null;
  }


  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        print("Invalid email or password.");
      } else {
        print("An error occurred: ${e.code}");
      }
    }
    return null;
  }

  Future<User?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Return null because there's no user associated with the reset password action
      return null;
    } catch (e) {
      print("An error occurred: $e");
      return null;
    }
  }

  Future<void> addUserToFirestore(User user, String username) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String uid = user.uid;
    CollectionReference users = firestore.collection('users');
    DocumentReference userDoc = users.doc(uid);

    String email = user.email ?? '';

    Map<String, dynamic> userData = {
      'email': email,
      'displayName': username,
    };

    await userDoc.set(userData);
  }

  void handleSignIn(User user) async {
    // Handle user sign-in (e.g., navigate to the home screen, show a success message, etc.)
    print('User signed in: ${user.displayName}');
  }

}
