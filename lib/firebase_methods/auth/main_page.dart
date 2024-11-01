import 'package:collectionapp/firebase_methods/auth/auth_page.dart';
import 'package:collectionapp/pages/auctionPages/auction_mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return AuctionListScreen(); // the page that appears if the user already logged in
          } else {
            return AuthPage(); // the page that appears if the user is not yet logged in
          }
        },
      ),
    );
  }
}
