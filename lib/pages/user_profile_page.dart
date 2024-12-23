import 'package:collectionapp/design_elements.dart';
import 'package:collectionapp/firebase_methods/firestore_methods/user_firestore_methods.dart';
import 'package:collectionapp/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';

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
    return const DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(text: "Groups"),
              Tab(text: "Bids"),
              Tab(text: "Collections"),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                Center(child: Text("Groups content coming soon!")),
                Center(child: Text("Bids content coming soon!")),
                Center(child: Text("Collections content coming soon!")),
              ],
            ),
          ),
        ],
      ),
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
