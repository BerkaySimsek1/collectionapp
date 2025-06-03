import "package:collectionapp/designElements/common_ui_methods.dart";
import "package:collectionapp/env_config.dart";
import "package:collectionapp/firebase_options.dart";
import "package:collectionapp/screens/home_screen.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Klavyeyi kapat
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Collection App",
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          textTheme: projectTextTheme(context),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
