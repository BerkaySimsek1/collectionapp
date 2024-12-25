import 'package:collectionapp/design_elements.dart';
import 'package:collectionapp/firebase_methods/firestore_methods/user_firestore_methods.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:collectionapp/models/GroupModel.dart';
import 'package:collectionapp/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/pages/socialMediaPages/SM_group_detail_page.dart';
import 'package:collectionapp/pages/auctionPages/auction_detail.dart';
import 'package:collectionapp/pages/userCollectionPages/collection_items_screen.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserFirestoreMethods _firestoreService = UserFirestoreMethods();

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _firestoreService.getUserData();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load user data")),
        );
      }
    }
  }

  Widget _buildProfileHeader() {
    return Stack(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 16,
          child: Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: const NetworkImage(
                    "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png"),
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${userData?["firstName"]} ${userData?["lastName"]}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfilePage(userData: userData!),
                        ),
                      ).then((_) => _loadUserData());
                    },
                    style: ProjectDecorations.elevatedButtonStyle,
                    child: const Text(
                      "Edit Profile",
                      style: ProjectTextStyles.buttonTextStyle,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(text: "Groups"),
              Tab(text: "Auctions"),
              Tab(text: "Collections"),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                _buildGroupsTab(),
                _buildAuctionsTab(),
                _buildCollectionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("groups")
          .where("members", arrayContains: userData?["uid"])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No groups joined yet."));
        }

        final groups = snapshot.data!.docs;

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return ListTile(
              title: Text(group["name"]),
              subtitle: Text(group["description"]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailPage(
                      group: Group.fromMap(group.data()),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAuctionsTab() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("auctions")
          .where("creator_id", isEqualTo: userData?["uid"])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No auctions created yet."));
        }

        final auctions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: auctions.length,
          itemBuilder: (context, index) {
            final auction = auctions[index];
            return ListTile(
              title: Text(auction["name"]),
              subtitle: Text("Starting Price: ${auction["starting_price"]}"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuctionDetail(
                      auction: AuctionModel.fromMap(auction.data()),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCollectionsTab() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("userCollections")
          .doc(userData?["uid"])
          .collection("collectionsList")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print(userData?["userId"]);
          return const Center(child: Text("No collections created yet."));
        }

        final collections = snapshot.data!.docs;

        return ListView.builder(
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final collection = collections[index];
            return ListTile(
              title: Text(collection["name"]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectionItemsScreen(
                      userId: userData?["uid"],
                      collectionName: collection["name"],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const ProjectAppbar(
        titleText: "My Profile",
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildTabSection(),
                ],
              ),
            ),
    );
  }
}
