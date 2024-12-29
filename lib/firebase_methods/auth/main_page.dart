import "package:collectionapp/design_elements.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/firebase_methods/auth/auth_page.dart";
import "package:collectionapp/pages/socialMediaPages/SM_main_page.dart";
import "package:collectionapp/pages/user_profile_page.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:collectionapp/pages/auctionPages/auction_mainpage.dart";
import "package:collectionapp/pages/userCollectionPages/user_collection_screen.dart";

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.hasData) {
          final user = authSnapshot.data;
          // Kullanıcı bilgilerini Firestore'dan çekiyoruz
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user!.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    color: Colors.grey[100],
                    child: const Center(child: CircularProgressIndicator()));
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Container(
                    color: Colors.grey[100],
                    child: const Center(child: Text("User data not found.")));
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              final firstName = userData["firstName"] ?? "Unknown";
              final lastName = userData["lastName"] ?? "User";

              return Scaffold(
                backgroundColor: Colors.grey[100],
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  toolbarHeight: 50,
                  iconTheme: const IconThemeData(color: Colors.deepPurple),
                ),
                drawer: Drawer(
                  backgroundColor: Colors.grey[200],
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountsDrawerHeader(
                        accountName: Text("$firstName $lastName"),
                        accountEmail: Text(user.email ?? ""),
                        currentAccountPicture: const CircleAvatar(
                          child: Icon(Icons.account_circle,
                              size: 70, color: Colors.deepPurple),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade400,
                              Colors.deepPurple.shade700
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.account_circle,
                          color: Colors.deepPurple,
                        ),
                        title: Text(
                          "Profile",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserProfilePage()),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.deepPurple,
                        ),
                        title: Text(
                          "Log Out",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Karşılama Mesajı
                        Text(
                          "Welcome $firstName $lastName!",
                          style: ProjectTextStyles.appBarTextStyle,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Here you can manage your auctions, view collections, and connect with others.",
                          style: ProjectTextStyles.subtitleTextStyle,
                        ),
                        const SizedBox(height: 80),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCardButton(
                              context,
                              title: "Auctions",
                              subtitle: "Browse or create auctions",
                              icon: Icons.gavel,
                              color: Colors.deepPurple,
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const AuctionListScreen();
                                }));
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildCardButton(
                              context,
                              title: "Collections",
                              subtitle: "View and manage your collections",
                              icon: Icons.collections,
                              color: Colors.indigo,
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return UserCollectionsScreen(
                                      userId: user.uid);
                                }));
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildCardButton(
                              context,
                              title: "Social Media",
                              subtitle: "Connect with others",
                              icon: Icons.people,
                              color: Colors.teal,
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const GroupsListPage();
                                }));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const AuthPage();
        }
      },
    );
  }

  // Card Buton Widget"ı
  Widget _buildCardButton(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ProjectTextStyles.cardHeaderTextStyle,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
