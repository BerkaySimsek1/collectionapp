import "package:collectionapp/design_elements.dart";
import "package:collectionapp/firebase_methods/auth/auth_page.dart";
import "package:collectionapp/pages/socialMediaPages/SM_main_page.dart";
import "package:collectionapp/pages/user_profile_page.dart";
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:collectionapp/pages/auctionPages/auction_mainpage.dart";
import "package:collectionapp/pages/userCollectionPages/user_collection_screen.dart";
import "package:cloud_firestore/cloud_firestore.dart";

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
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Karşılama Mesajı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Welcome $firstName $lastName!",
                                style: ProjectTextStyles.appBarTextStyle,
                                overflow:
                                    TextOverflow.clip, // Uzun yazıları kes
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        Text(
                          "Here you can manage your auctions, view collections, and connect with others.",
                          style: ProjectTextStyles.subtitleTextStyle,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            TextButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.account_circle,
                                  size: 36, color: Colors.deepPurple),
                              label: const Text("View Profile"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const UserProfilePage()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
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
                floatingActionButton: ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  style: ProjectDecorations.elevatedButtonStyle,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Log Out",
                    style: ProjectTextStyles.buttonTextStyle,
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
