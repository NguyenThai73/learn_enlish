import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/authentication/firebase_auth_service.dart';
import 'package:learning_english/authentication/login.dart';
import 'package:learning_english/constant/toast.dart';
import 'form_container_widget.dart';
import 'package:email_otp/email_otp.dart';

import 'otp.screen.dart';

EmailOTP myauth = EmailOTP();

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool obscureText = true;
  bool isSigningUp = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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
                  "Sign Up",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                FormContainerWidget(
                  controller: _usernameController,
                  hintText: "Username",
                  isPasswordField: false,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Password",
                  isPasswordField: true,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormContainerWidget(
                  controller: _passwordConfirmController,
                  hintText: "Enter password again",
                  isPasswordField: true,
                ),
                const SizedBox(
                  height: 35,
                ),
                GestureDetector(
                  onTap: () {
                    _signUp();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: isSigningUp
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                              )),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Login()), (route) => false);
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
                Container(
                  child: Image.asset('assets/signup.png'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _passwordConfirmController.text;
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showToast("Not a valid");
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        isSigningUp = false;
      });

      showToast("Password do not match");
      return;
    }
    myauth.setConfig(appEmail: "plantsfresh@gmail.com", appName: "LE", userEmail: email, otpLength: 6, otpType: OTPType.digitsOnly);

   try{
     if (await myauth.sendOTP() == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("OTP sent successfully"),
      ));
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => OTPScreen(
            email: email,
            name: username,
            password: password,
          ),
        ),
      );
    }
   }catch (e) {
    print("E: $e");
   }
  }
}
