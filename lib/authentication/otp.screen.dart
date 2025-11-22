import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_english/authentication/firebase_auth_service.dart';
import 'package:learning_english/constant/toast.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import 'signup.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final String name;
  final String password;

  const OTPScreen({
    super.key,
    required this.email,
    required this.name,
    required this.password,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  OtpFieldController otpController = OtpFieldController();
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text("OTP Verify", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 30, right: 30, top: 50),
            height: 40,
            child: OTPTextField(
                controller: otpController,
                length: 6,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 40,
                fieldStyle: FieldStyle.box,
                outlineBorderRadius: 4,
                style: const TextStyle(fontSize: 17),
                onChanged: (pin) {},
                onCompleted: (pin) async {
                  if (await myauth.verifyOTP(otp: pin) == true) {
                    User? user = await _auth.signUpWithEmailAndPassword(context, widget.email, widget.password, widget.name);
                    if (user != null) {
                      showToast("Sign up successful!");
                      Navigator.pushNamed(context, "/home");
                    } else {
                      showToast("Sign up failed!");
                    }
                  }else{
                     showToast("OTP not matching");
                  }
                }),
          ),
        ],
      ),
    );
  }
}
