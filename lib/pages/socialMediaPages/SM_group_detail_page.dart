import "package:collectionapp/firebase_methods/firestore_methods/SM_firestore_methods.dart";
import "package:collectionapp/models/GroupModel.dart";
import "package:collectionapp/models/PostModel.dart";
import "package:collectionapp/pages/socialMediaPages/SM_group_admin.dart";
import "package:collectionapp/pages/socialMediaPages/create_post_widget.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:collectionapp/design_elements.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupDetailPage extends StatefulWidget {
  final Group group;

  const GroupDetailPage({super.key, required this.group});

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final _groupDetailService = GroupDetailService();
  final _currentUser = FirebaseAuth.instance.currentUser;

  bool? _isMember;
  bool? hasJoinRequest;
  String? memberCount;

  @override
  void initState() {
    super.initState();
    _initializeStatus();
    memberCount = widget.group.members.length <= 1 ? "member" : "members";
  }

  Future<void> _initializeStatus() async {
    final isMember = await _groupDetailService.isUserMember(
        widget.group.id, _currentUser!.uid);
    final joinRequest = await _groupDetailService.getJoinRequest(
        widget.group.id, _currentUser.uid);
    setState(() {
      _isMember = isMember;
      hasJoinRequest = joinRequest != null;
    });
  }

  void _sendJoinRequest() async {
    setState(() {
      hasJoinRequest = true;
    });

    try {
      await _groupDetailService.sendJoinRequest(
          widget.group.id, _currentUser!.uid);
    } catch (e) {
      setState(() {
        hasJoinRequest = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          content: Text("Failed to send request: $e"),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
      );
    }
  }

  void _showCreatePostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreatePostWidget(groupId: widget.group.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar ve Kapak Fotoğrafı
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Kapak Fotoğrafı
                  widget.group.coverImageUrl != null
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(widget.group.coverImageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.deepPurple.shade900,
                                Colors.deepPurple.shade200,
                              ],
                            ),
                          ),
                        ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Grup İsmi ve Bilgileri
                  Positioned(
                    left: 16,
                    bottom: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${widget.group.members.length} $memberCount",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grup Açıklaması ve Admin Panel
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.description,
                    style: ProjectTextStyles.cardDescriptionTextStyle,
                  ),
                  const SizedBox(height: 16),
                  if (widget.group.adminIds.contains(_currentUser!.uid))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SmGroupAdmin(
                                groupId: widget.group.id,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.admin_panel_settings,
                            color: Colors.white),
                        label: const Text(
                          "Admin Panel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Gönderi Akışı
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_isMember == null || hasJoinRequest == null) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!_isMember!) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: hasJoinRequest!
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.pending_outlined,
                                      color: Colors.deepPurple),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Join request pending",
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _sendJoinRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Request to join",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  );
                } else {
                  return StreamBuilder<List<Post>>(
                    stream: _groupDetailService.getGroupPosts(widget.group.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.post_add,
                                  size: 80, color: Colors.grey),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  "No posts yet.",
                                  style: ProjectTextStyles.subtitleTextStyle,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: snapshot.data!.map((post) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: PostWidget(
                              post: post,
                              onLike: () => _groupDetailService.toggleLike(
                                  post.id, _currentUser.uid),
                              groupDetailService: _groupDetailService,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                }
              },
              childCount: 1,
            ),
          ),
        ],
      ),
      floatingActionButton: (_isMember ?? false)
          ? FloatingActionButton(
              onPressed: () => _showCreatePostDialog(context),
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class PostWidget extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final GroupDetailService groupDetailService;

  const PostWidget({
    super.key,
    required this.post,
    required this.onLike,
    required this.groupDetailService,
  });

  Future<String> _getUsername(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['username'] ?? 'Anonymous';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    String likeCount = post.likes.length <= 1 ? "like" : "likes";
    String commentCount = post.comments.length <= 1 ? "comment" : "comments";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı Bilgileri
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.userProfilePic.isNotEmpty
                      ? NetworkImage(post.userProfilePic)
                      : null,
                  backgroundColor: Colors.deepPurple,
                  child: post.userProfilePic.isEmpty
                      ? Text(post.username[0],
                          style: const TextStyle(color: Colors.white))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${post.createdAt.day}.${post.createdAt.month}.${post.createdAt.year}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Gönderi İçeriği
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 16),
              ),
            ),

          // Gönderi Görseli
          if (post.imageUrl != null)
            Container(
              constraints: const BoxConstraints(
                maxHeight: 400,
              ),
              width: double.infinity,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),

          // Etkileşim Butonları
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _InteractionButton(
                  icon: Icons.favorite,
                  isActive: post.likes.contains(currentUser!.uid),
                  activeColor: Colors.red,
                  count: post.likes.length,
                  label: likeCount,
                  onTap: onLike,
                ),
                const SizedBox(width: 20),
                _InteractionButton(
                  icon: Icons.comment_outlined,
                  count: post.comments.length,
                  label: commentCount,
                  onTap: () => _showComments(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Comments header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Comments",
                    style: ProjectTextStyles.appBarTextStyle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Comments list
            Expanded(
              child: StreamBuilder<List<Comment>>(
                stream:
                    groupDetailService.getPostComments(post.groupId, post.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            "No comments yet",
                            style: ProjectTextStyles.subtitleTextStyle,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final comment = snapshot.data![index];
                      return FutureBuilder<String>(
                        future: _getUsername(comment.userId),
                        builder: (context, usernameSnapshot) {
                          if (usernameSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final username = usernameSnapshot.data ?? 'Anonymous';

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: comment
                                            .userProfilePic.isNotEmpty
                                        ? NetworkImage(comment.userProfilePic)
                                        : null,
                                    backgroundColor: Colors.deepPurple,
                                    child: comment.userProfilePic.isEmpty
                                        ? Text(username[0],
                                            style: const TextStyle(
                                                color: Colors.white))
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              username,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${comment.createdAt.day}.${comment.createdAt.month} ${comment.createdAt.hour}:${comment.createdAt.minute.toString().padLeft(2, "0")}",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(comment.content),
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
                },
              ),
            ),
            // Comment input
            CommentBottomSheet(
              post: post,
              groupDetailService: groupDetailService,
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color? activeColor;
  final int count;
  final String label;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    this.isActive = false,
    this.activeColor,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : Colors.grey[600],
            size: 22,
          ),
          const SizedBox(width: 4),
          Text(
            "$count $label",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class CommentBottomSheet extends StatefulWidget {
  final Post post;
  final GroupDetailService groupDetailService;

  const CommentBottomSheet(
      {super.key, required this.post, required this.groupDetailService});

  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _getUsername(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['username'] ?? 'Anonymous';
  }

  void _submitComment() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _commentController.text.trim().isEmpty) return;

    final username = await _getUsername(currentUser.uid);

    final comment = Comment(
      id: DateTime.now().toString(), // Consider using a unique ID generator
      userId: currentUser.uid,
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
      username: username,
      userProfilePic: currentUser.photoURL ?? "",
      groupId: widget.post.groupId, // Add this field to pass group context
    );

    try {
      await widget.groupDetailService.addCommentToPost(widget.post.id, comment);
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add comment: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Write a comment",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.deepPurple),
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }
}
