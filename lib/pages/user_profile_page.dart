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
    return Container(
      color: Colors.grey[200],
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 60,
            right: 0.01,
            left: 0.01,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade700
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(192),
                  topRight: Radius.circular(192),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${userData?["firstName"] ?? "First"} ${userData?["lastName"] ?? "Last"}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Active Bidder",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_pin, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          "Sunnyvale, CA",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          "30.5k followers",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _showFollowDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Follow",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 1,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 4,
                      color: Colors.deepPurple,
                    )),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: const NetworkImage(
                      "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png"),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFollowDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            "Follow",
            style: ProjectTextStyles.appBarTextStyle,
          ),
          content: const Text(
            "Do you want to follow this user?",
            style: ProjectTextStyles.cardDescriptionTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: ProjectTextStyles.appBarTextStyle.copyWith(
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      content: Text(
                        "User followed successfully!",
                        style: ProjectTextStyles.appBarTextStyle.copyWith(
                          fontSize: 16,
                        ),
                      )),
                );
              },
              style: ProjectDecorations.elevatedButtonStyle,
              child: const Text(
                "Follow",
                style: ProjectTextStyles.buttonTextStyle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabSection() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 0.1),
              ),
            ]),
            child: const TabBar(
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepPurple,
              tabs: [
                Tab(text: "Groups"),
                Tab(text: "Auctions"),
                Tab(text: "Collections"),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 400,
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("groups")
          .where("members", arrayContains: userData?["uid"])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_off, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "No groups joined yet.",
                  style: ProjectTextStyles.subtitleTextStyle,
                ),
              ],
            ),
          );
        }

        final groups = snapshot.data!.docs;

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final groupData = groups[index].data() as Map<String, dynamic>;
            final group = Group.fromMap(groupData);

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: group.coverImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            group.coverImageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.deepPurple,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.group,
                                color: Colors.deepPurple,
                                size: 30,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.group,
                            color: Colors.deepPurple,
                            size: 30,
                          ),
                        ),
                ),
                title: Text(
                  group.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      group.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.supervised_user_circle,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 4),
                        Text("${group.members.length} members",
                            style: ProjectTextStyles.cardDescriptionTextStyle
                                .copyWith(
                              color: Colors.deepPurple,
                            )),
                      ],
                    ),
                  ],
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.deepPurple),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDetailPage(group: group),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAuctionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("auctions")
          .where("creator_id", isEqualTo: userData?["uid"])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gavel_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "No auctions created yet.",
                  style: ProjectTextStyles.subtitleTextStyle,
                ),
              ],
            ),
          );
        }

        final auctions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: auctions.length,
          itemBuilder: (context, index) {
            final auctionData = auctions[index].data() as Map<String, dynamic>;
            final auction = AuctionModel.fromMap(auctionData);

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: auction.imageUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            auction.imageUrls.first,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.deepPurple,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.gavel,
                                color: Colors.deepPurple,
                                size: 30,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.gavel,
                            color: Colors.deepPurple,
                            size: 30,
                          ),
                        ),
                ),
                title: Text(
                  auction.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      auction.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              "\$${auction.startingPrice.toStringAsFixed(2)}",
                              style: ProjectTextStyles.buttonTextStyle
                                  .copyWith(fontSize: 16),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          auction.isAuctionEnd
                              ? "Ended"
                              : "Ends ${auction.endTime.day}/${auction.endTime.month}/${auction.endTime.year}",
                          style: ProjectTextStyles.subtitleTextStyle,
                        ),
                      ],
                    ),
                  ],
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.deepPurple),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuctionDetail(auction: auction),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCollectionsTab() {
    IconData getIconForCollectionType(String type) {
      switch (type) {
        case 'Record':
          return Icons.music_note;
        case 'Stamp':
          return Icons.stay_primary_landscape;
        case 'Coin':
          return Icons.money;
        case 'Book':
          return Icons.book;
        case 'Painting':
          return Icons.photo;
        case 'Comic Book':
          return Icons.book_online;
        case 'Vintage Posters':
          return Icons.mediation;
        case 'Diğer':
          return Icons.more_horiz;
        default:
          return Icons.more_horiz;
      }
    }

    return StreamBuilder<QuerySnapshot>(
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
          return const Center(child: Text("No collections created yet."));
        }

        final collections = snapshot.data!.docs;

        return ListView.builder(
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final collectionDoc = collections[index];
            final collectionData = collectionDoc.data() as Map<String, dynamic>;
            final collectionType = collectionData['name'] ?? 'Diğer';
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  radius: 30,
                  child: Icon(getIconForCollectionType(collectionType),
                      color: Colors.white),
                ),
                title: Text(
                  collectionData["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectionItemsScreen(
                        userId: userData?["uid"],
                        collectionName: collectionData["name"],
                      ),
                    ),
                  );
                },
              ),
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
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title:
            const Text("My Profile", style: ProjectTextStyles.appBarTextStyle),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.deepPurple,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(userData: userData!),
                ),
              ).then((_) => _loadUserData());
            },
            icon: const Icon(
              Icons.edit_rounded,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  _buildTabSection(),
                ],
              ),
            ),
    );
  }
}
