import 'package:collectionapp/firebase_methods/auth/auth_page.dart';
import 'package:collectionapp/pages/auctionPages/auction_mainpage.dart';
import 'package:collectionapp/pages/userCollectionPages/user_collection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance
        .currentUser; // IMPORTANT: Old variant is "final user = FirebaseAuth.instance.currentUser!;"
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16.0), // Köşe yarıçapı
                          ),
                        ),
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.deepPurple),
                        elevation: WidgetStateProperty.all<double>(
                            3), // Örnek olarak 4.0 yüksekliği
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const AuctionListScreen();
                        }));
                      },
                      child: const Text(
                        "Auctions",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      )),
                  FilledButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16.0), // Köşe yarıçapı
                        ),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.deepPurple),
                      elevation: WidgetStateProperty.all<double>(
                          3), // Örnek olarak 4.0 yüksekliği
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return UserCollectionsScreen(userId: user!.uid);
                      }));
                    },
                    child: const Text(
                      "Collections",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                  FilledButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16.0), // Köşe yarıçapı
                        ),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.deepPurple),
                      elevation: WidgetStateProperty.all<double>(
                          3), // Örnek olarak 4.0 yüksekliği
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: const SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          Text(
                            "Log out",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );

            // the page that appears if the user already logged in
          } else {
            return const AuthPage(); // the page that appears if the user is not yet logged in
          }
        },
      ),
    );
  }
}
