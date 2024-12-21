import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/UserInfoModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future signUp() async {
    if (passwordConfirmed()) {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      UserInfoModel newUser = UserInfoModel(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        uid: userCredential.user!.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
      );

      await addUserDetails(newUser);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Wrong information"),
          );
        },
      );
    }
  }

  Future addUserDetails(UserInfoModel user) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid) // `userid` yerine belgenin ID'sini kullanıyoruz
        .set(user.toJson());
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Text(
                "Hello there!",
                style: GoogleFonts.bebasNeue(fontSize: 54),
              ),
              const SizedBox(height: 10),
              const Text(
                "Register below with your details!",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              buildTextField("E-mail", _emailController),
              const SizedBox(height: 10),
              buildTextField("Username", _usernameController),
              const SizedBox(height: 10),
              buildTextField("First Name", _firstNameController),
              const SizedBox(height: 10),
              buildTextField("Last Name", _lastNameController),
              const SizedBox(height: 10),
              buildTextField("Age", _ageController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              buildPasswordField("Password", _passwordController),
              const SizedBox(height: 10),
              buildPasswordField(
                  "Confirm Password", _confirmPasswordController),
              const SizedBox(height: 20),
              buildSignUpButton(),
              const SizedBox(height: 25),
              buildLoginOption(),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildTextField(String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding buildPasswordField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector buildSignUpButton() {
    return GestureDetector(
      onTap: signUp,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(15)),
          child: const Center(
            child: Text(
              "Sign Up",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  Row buildLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already a member?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: widget.showLoginPage,
          child: const Text(
            " Log In",
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
