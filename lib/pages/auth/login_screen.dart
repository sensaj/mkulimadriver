// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mkulimadriver/pages/auth/complete_registration.dart';
import 'package:mkulimadriver/pages/auth/registration_screen.dart';
import 'package:mkulimadriver/pages/auth/verification_page.dart';
import 'package:mkulimadriver/pages/homepage.dart';
import 'package:mkulimadriver/services/auth_services.dart';
import 'package:mkulimadriver/services/local_services.dart';
import 'package:mkulimadriver/services/user_services.dart';
import 'package:mkulimadriver/theme/colors.dart';
import 'package:mkulimadriver/widgets/app_elevated_button.dart';
import 'package:mkulimadriver/widgets/app_textformfield.dart';
import 'package:mkulimadriver/widgets/pop_up_dialogs.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String emailError = "";
  String password = "";
  String passwordError = "";
  RegExp pattern = RegExp(r'^\+\d{1,3}\s?\d{9,}$');
  bool isLoading = false, obscureText = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colors.background,
        body: SingleChildScrollView(
          child: SizedBox(
            height: size.height - 50,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    margin: EdgeInsets.symmetric(vertical: 150),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo.png"),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: size.width * .03),
                    alignment: Alignment.center,
                    child: Container(
                      height: 315,
                      width: size.width,
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * .03),
                      decoration: BoxDecoration(
                        color: colors.gray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Welcome",
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(height: 10),
                          AppTextFormField(
                            hintText: "Email",
                            color: colors.background,
                            errorText: emailError,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              setState(() {
                                if (value == null || value.isEmpty) {
                                  email = "";
                                  emailError = "this field can not be null";
                                } else {
                                  email = value;
                                }
                              });
                            },
                          ),
                          AppTextFormField(
                            hintText: "Password",
                            color: colors.background,
                            errorText: passwordError,
                            obscureText: obscureText,
                            suffix: InkWell(
                              child: Icon(
                                obscureText
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                                color: Color(0xFF929BAB),
                              ),
                              onTap: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                            ),
                            validator: (value) {
                              setState(() {
                                if (value == null || value.isEmpty) {
                                  password = "";
                                  passwordError = "this field can not be null";
                                } else {
                                  password = value;
                                }
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: colors.primary, shape: BoxShape.circle),
                            child: isLoading
                                ? CircularProgressIndicator()
                                : IconButton(
                                    icon: Icon(
                                      CupertinoIcons.chevron_forward,
                                      color: Colors.white,
                                    ),
                                    onPressed: validateInputs,
                                  ),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            children: [
                              Text(
                                "Not registered? ",
                                style: TextStyle(color: colors.darkBlue),
                              ),
                              InkWell(
                                child: Text(
                                  "sign up",
                                  style: TextStyle(color: colors.primary),
                                ),
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RegistrationScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  validateInputs() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      if (emailError == "" && passwordError == "") {
        _startAuthentication();
      }
    }
  }

  _startAuthentication() async {
    setState(() {
      isLoading = true;
    });

    var result = await auth.loginWithEmail(email: email, password: password);
    if (result is bool && auth.user != null) {
      try {
        final results = await userServices.getUserData(userId: auth.user!.uid);
        if (results == null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CompleteRegistration(userId: auth.user!.uid),
              ));
        } else {
          local.setInstance(key: "hasLogin", type: bool, value: true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Homepage(user: results),
            ),
          );
        }
      } catch (e) {
        dialog.errorDialog(
          context: context,
          header: "ERROR!",
          body:
              "Authentication returned errors, Please check your connection and retry",
        );
      }
    } else {
      print(result);
      dialog.errorDialog(context: context, header: "ERROR", body: result);
    }
    setState(() {
      isLoading = false;
    });
  }
}
