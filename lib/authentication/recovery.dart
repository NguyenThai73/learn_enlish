import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/authentication/firebase_auth_service.dart';
import 'form_container_widget.dart';
import 'login.dart';

class RecoveyPage extends StatefulWidget {
  const RecoveyPage({super.key});

  @override
  State<RecoveyPage> createState() => _RecoveyPageState();
}

class _RecoveyPageState extends State<RecoveyPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool obscureText = true;
  bool isRecovery = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  "Recovery",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Enter the email you signed up with. We'll send you a link to log in and reset your password. "
                      "If you signed up with your parent’s email, we’ll send them a link.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
                const SizedBox(
                  height: 30,
                ),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
              
                const SizedBox(
                  height: 35,
                ),
                GestureDetector(
                  onTap:  (){
                    _resetPassword();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: isRecovery ? const CircularProgressIndicator(color: Colors.white,):const Text(
                          "Send",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                                (route) => false,
                          );
                        },
                        child: const Text("Back to login page", style: TextStyle(fontSize: 15, color: Colors.lightBlue, fontWeight: FontWeight.bold),)
                    ),
                  ],
                ),
                // Container(
                //   child: Image.asset('assets/forgot-password.png'),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword() async {
    setState(() {
      isRecovery = true;
    });

    String email = _emailController.text;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print("Recovery successful!");
    } catch (e) {
      print("Recovery failed!");
    }

    setState(() {
      isRecovery = false;
    });
  }

}
