import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learning_english/constant/text_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/color.dart';
import '../constant/style.dart';
import '../constant/toast.dart';
import 'firebase_setting_page.dart';
import 'package:image_picker/image_picker.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  User? _user;
  String? _avatarURL;

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
                child: GestureDetector(
                  onTap: () {},
                  child: Card(
                    color: Colors.transparent,
                    child: Container(
                      decoration: CustomCardDecoration.cardDecoration,
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _avatarURL != null
                                ? NetworkImage(_avatarURL!)
                                : _user?.photoURL != null
                                    ? NetworkImage(_user!.photoURL!)
                                    : const AssetImage(
                                            'assets/default_avatar.png')
                                        as ImageProvider,
                          ),
                          const SizedBox(height: 20),
                          Text(_user?.displayName ?? '', style: normalText),
                          const SizedBox(height: 10),
                          Text(_user?.email ?? '', style: normalSubText),
                        ],
                      ),
                    ),
                  ),
                ),
              ), // Profile

              const SizedBox(height: 20),
              Container(
                child: GestureDetector(
                  onTap: () {
                    changeUsername();
                  },
                  child: Card(
                    color: Colors.blue[500],
                    child: Container(
                      decoration: CustomCardDecoration.cardDecoration,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.drive_file_rename_outline,
                              color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child:
                                Text('Change username', style: normalSubText),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ), // Change username

              const SizedBox(height: 20),
              Container(
                child: GestureDetector(
                  onTap: () {
                    changeAvatar();
                  },
                  child: Card(
                    color: Colors.blue[500],
                    child: Container(
                      decoration: CustomCardDecoration.cardDecoration,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.image, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Change avatar', style: normalSubText),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ), // Change avatar

              const SizedBox(height: 20),
              Container(
                child: GestureDetector(
                  onTap: () {
                    changePassword();
                  },
                  child: Card(
                    color: Colors.blue[500],
                    child: Container(
                      decoration: CustomCardDecoration.cardDecoration,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.lock, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child:
                                Text('Change password', style: normalSubText),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ), // Change password
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          backgroundColor: button,
          onPressed: () {
            logout();
          },
          child: const Icon(
            Icons.logout,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Future<void> getUserProfile() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(user.uid).get();
      setState(() {
        _user = user;
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;
        _avatarURL =
            userData?['avatarURL']; // Retrieve avatar URL from Firestore
      });
    }
  }

  Future<String?> _showUsernameInputDialog() async {
    TextEditingController usernameController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter New Username'),
          content: TextField(
            controller: usernameController,
            onChanged: (value) {},
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(usernameController.text);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void changeUsername() async {
    String? newUsername = await _showUsernameInputDialog();

    if (newUsername != null && newUsername.isNotEmpty) {
      try {
        await FirebaseAuth.instance.currentUser!.updateDisplayName(newUsername);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({'displayName': newUsername});
        await getUserProfile();
        showToast("Username updated successfully.");
      } catch (e) {
        print("Error updating username: $e");
        showToast("Error updating username: $e");
      }
    } else {
      showToast("Error: Invalid username or canceled");
    }
  }

  void changeAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        String imagePath = pickedFile.path;

        String newAvatarURL = await updateAvatar(_user!, imagePath);
        showToast('Avatar updated successfully.');

        setState(() {
          _avatarURL = newAvatarURL;
        });
      } else {
        showToast('No image selected.');
      }
    } catch (e) {
      print('Error changing avatar: $e');
      showToast('Error changing avatar: $e');
    }
  }

  Future<Map<String, String>?> _showPasswordInputDialog() async {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Old Password',
                ),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'oldPassword': oldPasswordController.text,
                  'newPassword': newPasswordController.text,
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void changePassword() async {
    Map<String, String>? passwords = await _showPasswordInputDialog();
    if (passwords != null && passwords['newPassword'] != null && passwords['newPassword']!.isNotEmpty) {
      try {
        String? oldPassword = passwords['oldPassword'];
        if (oldPassword == null || oldPassword.isEmpty) {
          showToast("Please enter your old password to confirm.");
          return;
        }

        AuthCredential credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: oldPassword,
        );
        await _user!.reauthenticateWithCredential(credential);
        await _user!.updatePassword(passwords['newPassword']!);
        showToast("Password updated successfully.");
      } catch (e) {
        showToast("Error updating password: $e");
      }
    } else {
      showToast("Error: Invalid password or canceled");
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }


}
