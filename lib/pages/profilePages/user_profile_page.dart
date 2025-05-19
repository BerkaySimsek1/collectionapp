import 'package:collectionapp/common_ui_methods.dart';
import 'package:collectionapp/firebase_methods/user_firestore_methods.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:collectionapp/models/GroupModel.dart';
import 'package:collectionapp/pages/profilePages/edit_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/pages/socialMediaPages/SM_group_detail_page.dart';
import 'package:collectionapp/pages/auctionPages/auction_detail.dart';
import 'package:collectionapp/pages/userCollectionPages/collection_items_screen.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfilePage extends StatefulWidget {
  final String? userId;
  const UserProfilePage({super.key, this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserFirestoreMethods _firestoreService = UserFirestoreMethods();

  Map<String, dynamic>? userData;
  bool isLoading = true;

  bool get isCurrentUser {
// Eğer userId null ise veya userId, şu anki kullanıcının ID'siyle eşleşiyorsa current user
    return widget.userId == null ||
        widget.userId == FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      Map<String, dynamic>? data; // nullable tanımlandı
      if (isCurrentUser) {
        data = await _firestoreService.getUserData();
      } else {
        data = await _firestoreService.getUserDataById(widget.userId!);
      }
      if (data == null) {
        throw Exception("User data not found");
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          userData = data;
          isLoading = false;
        });
      });
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isLoading = false;
        });
      });
      if (mounted) {
        projectSnackBar(context, "Failed to load user data", "red");
      }
    }
  }

  Future<void> _showFollowingDialog() async {
// userData içerisindeki "followers" alanı, takipçilerin uid'lerini içermeli.
    List<dynamic> following = userData?["following"] ?? [];
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Following",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              )),
          content: SizedBox(
            width: double.maxFinite,
            child: following.isEmpty
                ? Center(
                    child:
                        Text("No following yet", style: GoogleFonts.poppins()),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: following.length,
                    itemBuilder: (context, index) {
                      final followerId = following[index];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(followerId)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              leading: const CircleAvatar(
                                child: CircularProgressIndicator(),
                              ),
                              title: Text("Loading...",
                                  style: GoogleFonts.poppins()),
                            );
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return ListTile(
                              title: Text("Unknown user",
                                  style: GoogleFonts.poppins()),
                            );
                          }
                          final followerData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  (followerData["profileImageUrl"] != null &&
                                          followerData["profileImageUrl"]
                                              .isNotEmpty)
                                      ? NetworkImage(
                                          followerData["profileImageUrl"])
                                      : null,
                              child: (followerData["profileImageUrl"] == null ||
                                      followerData["profileImageUrl"].isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                    )
                                  : null,
                            ),
                            title: Text(
                              "${followerData["firstName"] ?? ""} ${followerData["lastName"] ?? ""}",
                              style: GoogleFonts.poppins(),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFollowersDialog() async {
// userData içerisindeki "followers" alanı, takipçilerin uid'lerini içermeli.
    List<dynamic> followers = userData?["followers"] ?? [];
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Followers",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              )),
          content: SizedBox(
            width: double.maxFinite,
            child: followers.isEmpty
                ? Center(
                    child:
                        Text("No followers yet", style: GoogleFonts.poppins()),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: followers.length,
                    itemBuilder: (context, index) {
                      final followerId = followers[index];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(followerId)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              leading: const CircleAvatar(
                                child: CircularProgressIndicator(),
                              ),
                              title: Text("Loading...",
                                  style: GoogleFonts.poppins()),
                            );
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return ListTile(
                              title: Text("Unknown user",
                                  style: GoogleFonts.poppins()),
                            );
                          }
                          final followerData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  (followerData["profileImageUrl"] != null &&
                                          followerData["profileImageUrl"]
                                              .isNotEmpty)
                                      ? NetworkImage(
                                          followerData["profileImageUrl"])
                                      : null,
                              child: (followerData["profileImageUrl"] == null ||
                                      followerData["profileImageUrl"].isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                    )
                                  : null,
                            ),
                            title: Text(
                              "${followerData["firstName"] ?? ""} ${followerData["lastName"] ?? ""}",
                              style: GoogleFonts.poppins(),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFollowDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Follow User",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Do you want to follow this user?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final currentUserId =
                              FirebaseAuth.instance.currentUser!.uid;
                          final targetUserId = userData?["uid"];
                          if (targetUserId == null) return;

                          try {
                            // Takip edilen kullanıcının 'followers' alanına ekle
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(targetUserId)
                                .update({
                              "followers":
                                  FieldValue.arrayUnion([currentUserId])
                            });
                            // Takip eden kullanıcının 'following' alanına ekle
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(currentUserId)
                                .update({
                              "following": FieldValue.arrayUnion([targetUserId])
                            });
                            // Güncel verileri tekrar yükleyerek UI'yı güncelle
                            await _loadUserData();

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            projectSnackBar(
                                context, "Followed successfully!", "green");
                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            projectSnackBar(
                                context, "Failed to follow user", "red");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Follow",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showUnfollowDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_off_outlined,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Unfollow User",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Do you want to unfollow this user?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final currentUserId =
                              FirebaseAuth.instance.currentUser!.uid;
                          final targetUserId = userData?["uid"];
                          if (targetUserId == null) return;

                          try {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(targetUserId)
                                .update({
                              "followers":
                                  FieldValue.arrayRemove([currentUserId])
                            });
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(currentUserId)
                                .update({
                              "following":
                                  FieldValue.arrayRemove([targetUserId])
                            });
                            await _loadUserData();

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            projectSnackBar(
                                context, "Unfollowed successfully!", "red");
                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            projectSnackBar(
                                context, "Failed to unfollow user", "red");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Unfollow",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TabBar(
          indicatorPadding: const EdgeInsets.symmetric(horizontal: -12),
          dividerHeight: 0,
          indicator: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(25),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            SizedBox(
              height: 40,
              child: Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_outlined),
                      SizedBox(width: 8),
                      Text(
                        "Groups",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gavel_outlined),
                      SizedBox(width: 8),
                      Text(
                        "Auctions",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.collections_outlined),
                      SizedBox(width: 8),
                      Text(
                        "Collections",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    bool isFollowing = (((userData?["followers"] as List?) ?? [])
        .contains(FirebaseAuth.instance.currentUser!.uid));
    final String? profileImageUrl = userData?["profileImageUrl"];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade400,
            Colors.deepPurple.shade800,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Dekoratif Daireler
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),

          // Profil İçeriği
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profil Fotoğrafı
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        backgroundImage: (profileImageUrl != null &&
                                profileImageUrl.isNotEmpty)
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child:
                            (profileImageUrl == null || profileImageUrl.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    size: 55,
                                    color: Colors.deepPurple,
                                  )
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // İsim
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    "${userData?["firstName"] ?? "First"} ${userData?["lastName"] ?? "Last"}",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),

                // Konum ve Durum
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Sunnyvale, CA",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Active Bidder",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Followers ve Following
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _showFollowersDialog(),
                        child: Column(
                          children: [
                            Text(
                              // takipçi sayısı burada gösteriliyor
                              formatNumber(
                                (userData?["followers"] as List?)?.length ?? 0,
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              // takipçi sayısı çoğulsa "Followers" tekilse "Follower" yazdırılıyor
                              ((userData?["followers"] as List?)?.length ??
                                          0) <=
                                      1
                                  ? "Follower"
                                  : "Followers",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      GestureDetector(
                        onTap: () => _showFollowingDialog(),
                        child: Column(
                          children: [
                            Text(
                              (userData?["following"] as List?)
                                      ?.length
                                      .toString() ??
                                  "0",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Following",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ), // Followers ve Following container'ından sonra
                const SizedBox(height: 16),
                if (!isCurrentUser) // Sadece başka kullanıcıların profilinde göster
                  SizedBox(
                    width: 200, // Sabit genişlik
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        isFollowing
                            ? _showUnfollowDialog()
                            : _showFollowDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        elevation: 5,
                        shadowColor: Colors.black.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      icon: Icon(
                        isFollowing
                            ? Icons.person_off_outlined
                            : Icons.person_add_outlined,
                      ),
                      label: Text(
                        isFollowing ? "Unfollow" : "Follow",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
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
          return Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple.shade300,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.group_off_outlined,
                    size: 64,
                    color: Colors.deepPurple.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No groups joined yet",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Join groups to connect with others",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        final groups = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final groupData = groups[index].data() as Map<String, dynamic>;
            final group = Group.fromMap(groupData);
            final String memberCount = group.members.length == 1
                ? "${group.members.length} member"
                : "${group.members.length} members";
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupDetailPage(group: group),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Grup Görseli
                        Hero(
                          tag: 'group_${group.id}',
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: group.coverImageUrl != null
                                  ? Image.network(
                                      group.coverImageUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: Colors.deepPurple
                                            .withValues(alpha: 0.15),
                                        child: const Icon(
                                          Icons.group_outlined,
                                          color: Colors.deepPurple,
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.deepPurple
                                          .withValues(alpha: 0.15),
                                      child: const Icon(
                                        Icons.group_outlined,
                                        color: Colors.deepPurple,
                                        size: 40,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Grup Bilgileri
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                group.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.deepPurple.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.people_outline,
                                      size: 16,
                                      color: Colors.deepPurple,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      memberCount,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Sağ Ok İkonu
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.deepPurple,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
          return Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple.shade300,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.gavel_outlined,
                    size: 64,
                    color: Colors.deepPurple.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No auctions yet",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create your first auction",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        final auctions = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: auctions.length,
          itemBuilder: (context, index) {
            final auctionData = auctions[index].data() as Map<String, dynamic>;
            final auction = AuctionModel.fromMap(auctionData);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuctionDetail(auction: auction),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Auction Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: auction.imageUrls.isNotEmpty
                            ? Image.network(
                                auction.imageUrls.first,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                              ),
                      ),
                      // Auction Info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    auction.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: auction.isAuctionEnd
                                        ? Colors.red[50]
                                        : Colors.green[50],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    auction.isAuctionEnd ? "Ended" : "Active",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: auction.isAuctionEnd
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              auction.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.shade400,
                                        Colors.deepPurple.shade700,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    "\$${auction.startingPrice.toStringAsFixed(2)}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      auction.isAuctionEnd
                                          ? "Ended"
                                          : "Ends ${auction.endTime.day}/${auction.endTime.month}/${auction.endTime.year}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCollectionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("userCollections")
          .doc(userData?["uid"])
          .collection("collectionsList")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple.shade300,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.collections_outlined,
                    size: 64,
                    color: Colors.deepPurple.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No collections yet",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Start building your collection",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        final collections = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final collectionDoc = collections[index];
            final collectionData = collectionDoc.data() as Map<String, dynamic>;
            final collectionType = collectionData['name'] ?? 'Diğer';
            final color = getColorForCollectionType(collectionType);

            return GestureDetector(
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        getIconForCollectionType(collectionType),
                        color: color,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      collectionData["name"],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.style_outlined,
                            size: 14,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "View Items",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        extendBodyBehindAppBar: true,
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      flexibleSpace: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          final double scrollPercent =
                              constraints.maxHeight > kToolbarHeight
                                  ? 1 -
                                      (constraints.maxHeight - kToolbarHeight) /
                                          (360 - kToolbarHeight)
                                  : 1.0;
                          final double opacity =
                              ((scrollPercent - 0.3) / 0.45).clamp(0.0, 1.0);

                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.deepPurple.shade400,
                                  Colors.deepPurple.shade800,
                                ],
                              ),
                            ),
                            child: FlexibleSpaceBar(
                              centerTitle: true,
                              titlePadding: const EdgeInsets.only(bottom: 16),
                              title: Opacity(
                                opacity: opacity,
                                child: Text(
                                  "${userData?["firstName"] ?? "First"} ${userData?["lastName"] ?? "Last"}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              background: _buildProfileHeader(),
                            ),
                          );
                        },
                      ),
                      elevation: 0,
                      floating: false,
                      pinned: true,
                      expandedHeight: !isCurrentUser ? 400 : 360,
                      leading: const ProjectIconButton(),
                      actions: [
                        if (!isCurrentUser) // Kullanıcı kendi profili değilse şikayet butonu göster
                          Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.flag_outlined,
                                color: Colors.red,
                              ),
                              onPressed: () => showReportDialog(
                                context,
                                "user",
                                userData!["uid"],
                              ),
                              tooltip: "Report User",
                            ),
                          )
                        else // Kendi profili ise edit butonu göster
                          Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: Colors.deepPurple,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfilePage(userData: userData!),
                                  ),
                                ).then((_) => _loadUserData());
                              },
                            ),
                          ),
                      ],
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: SliverAppBarDelegate(
                        minHeight: 80,
                        maxHeight: 80,
                        child: Container(
                          color: Colors.white,
                          child: _buildTabSection(),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _buildGroupsTab(),
                    _buildAuctionsTab(),
                    _buildCollectionsTab(),
                  ],
                ),
              ),
      ),
    );
  }
}
