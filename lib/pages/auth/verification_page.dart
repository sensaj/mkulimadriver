// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mkulimadriver/theme/colors.dart';
import 'package:mkulimadriver/widgets/countdown_timer.dart';
import 'package:pinput/pinput.dart';

class VerificationPage extends StatefulWidget {
  final String phone;
  final Map<String, dynamic>? userData;
  VerificationPage({required this.phone, this.userData});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String _verificationId = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _pin = TextEditingController();
  String? pinError;
  bool startTimer = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colors.background,
        body: SingleChildScrollView(
          child: Container(
            height: size.height - 100,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 50),
                Text(
                  "Enter 4 digit verification code sent to your phone number",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                startTimer
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Resend code in",
                            style: TextStyle(
                              fontSize: 15.0,
                              color: CupertinoColors.systemGrey5,
                            ),
                          ),
                          SizedBox(width: 3),
                          CountDownTimer(
                            secondsRemained: 60,
                            whenTimeExpires: () {
                              setState(() {
                                startTimer = false;
                              });
                            },
                            countDownTimerStyle: TextStyle(
                              fontSize: 15.0,
                              color: CupertinoColors.systemGrey5,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Text(
                            "Didn't you receive any code?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey5,
                            ),
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            child: Text(
                              "RESEND NEW CODE",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                            onTap: () {
                              verifyPhoneNumber();
                            },
                          ),
                        ],
                      ),
                SizedBox(height: 100),
                Pinput(
                  androidSmsAutofillMethod:
                      AndroidSmsAutofillMethod.smsUserConsentApi,
                  length: 4,
                  listenForMultipleSmsOnAndroid: true,
                  controller: _pin,
                  validator: (s) {
                    return pinError;
                  },
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  obscureText: true,
                  obscuringWidget: Icon(CupertinoIcons.circle_fill, size: 13),
                  defaultPinTheme: PinTheme(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.all(8),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  onCompleted: (pin) {
                    signInWithPhoneNumber(_verificationId, pin);
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.darkBlue,
                    fixedSize: Size(size.width - 100, 50),
                  ),
                  child: Text(
                    "Continue",
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  onPressed: () {
                    if (_pin.text == "1234") {
                    } else {
                      setState(() {
                        pinError = "Pin is incorrect";
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInWithPhoneNumber(
      String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final user = await _auth.signInWithCredential(credential);
      print('User signed in successfully! ${user.user!.uid}');
    } catch (e) {
      print('Sign In Error: $e');
    }
  }

  Future<void> verifyPhoneNumber() async {
    verificationCompleted(AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
      // Handle phone verification completion, if needed.
      print("---------------------------------------");
    }

    verificationFailed(FirebaseAuthException authException) {
      // Handle phone verification failure, if needed.
      print("++++++++++++++++++++++++++++++++++++$authException");
    }

    codeSent(String verificationId, [int? forceResendingToken]) async {
      setState(() {
        _verificationId = verificationId;
        startTimer = true;
      });

      // Navigate to the OTP verification screen passing the verificationId.
    }

    codeAutoRetrievalTimeout(String verificationId) {
      setState(() {
        _verificationId = verificationId;
      });
      print("======================================================");
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phone,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

//   Future signIn() async {
//   try {
//     final AuthCredential credential = PhoneAuthProvider.getCredential(
//       verificationId: _verificationId,
//       smsCode: _pin.text,
//     );
//     final AuthResult userResult = await _auth.signInWithCredential(credential);
//     final FirebaseUser currentUser = await _auth.currentUser();

//     final document = Firestore().collection("users").document(currentUser.uid);
//     final documentSnapshot = await document.get();
//     if (!documentSnapshot.exists) {
//       await document.setData({
//         "id": currentUser.uid,
//         "number": phoneNumber,
//       });
//     }
//     return true;
//   } catch (e) {
//     return false;
//   }
// }
}
