import 'package:collectionapp/design_elements.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    // resetting the password
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: const Text(
                "If an account with this e-mail exists, a password reset link has been sent. Check your inbox."),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      // if the e-mail is badly formatted
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: const ProjectAppbar(titleText: "Forgot Password"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Enter your e-mail",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          // e-mail textfield
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: "E-mail",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(style: BorderStyle.none, width: 0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: MaterialButton(
              onPressed: passwordReset,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(15)),
                child: const Center(
                  child: Text(
                    "Reset Your Password",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
