import "package:collectionapp/firebase_methods/firestore_methods/SM_firestore_methods.dart";
import "package:collectionapp/models/GroupModel.dart";
import "package:collectionapp/models/PostModel.dart";
import "package:collectionapp/pages/socialMediaPages/SM_group_admin.dart";
import "package:collectionapp/pages/socialMediaPages/comment_bottom_sheet.dart";
import "package:collectionapp/pages/socialMediaPages/create_post_widget.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:collectionapp/design_elements.dart";

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
        SnackBar(content: Text("Failed to send request: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: ProjectAppbar(
        titletext: widget.group.name,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Group Information
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.group.coverImageUrl != null
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.group.coverImageUrl!),
                        radius: 50,
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          widget.group.name[0],
                          style: ProjectTextStyles.cardHeaderTextStyle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.group.name,
                        style: ProjectTextStyles.cardHeaderTextStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.group.description,
                        style: ProjectTextStyles.subtitleTextStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${widget.group.members.length} $memberCount",
                        style: ProjectTextStyles.subtitleTextStyle,
                      ),
                    ],
                  ),
                ),
                if (widget.group.adminIds.contains(_currentUser!.uid))
                  TextButton(
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
                    child: const Column(
                      children: [
                        Text("Admin"),
                        Text("Panel"),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            if (_isMember == null || hasJoinRequest == null)
              const Center(child: CircularProgressIndicator())
            else if (!_isMember!)
              hasJoinRequest!
                  ? const Text("Request sent")
                  : ElevatedButton(
                      onPressed: _sendJoinRequest,
                      style: ProjectDecorations.elevatedButtonStyle,
                      child: const Text(
                        "Request to join",
                        style: ProjectTextStyles.buttonTextStyle,
                      ),
                    )
            else
              Expanded(
                child: Column(
                  children: [
                    // Posts List
                    Expanded(
                      child: StreamBuilder<List<Post>>(
                        stream:
                            _groupDetailService.getGroupPosts(widget.group.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text("No posts yet."));
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final post = snapshot.data![index];
                              return PostWidget(
                                post: post,
                                onLike: () => _groupDetailService.toggleLike(
                                    post.id, _currentUser.uid),
                                groupDetailService: _groupDetailService,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
          onPressed: () {
            // creating post
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                    child: CreatePostWidget(groupId: widget.group.id));
              },
            );
          },
          label: const Text(
            "Create Post",
            style: ProjectTextStyles.buttonTextStyle,
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          style: ProjectDecorations.elevatedButtonStyle),
    );
  }
}

class PostWidget extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final GroupDetailService groupDetailService;

  const PostWidget(
      {super.key,
      required this.post,
      required this.onLike,
      required this.groupDetailService});

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Comments Stream
          StreamBuilder<List<Comment>>(
            stream: groupDetailService.getPostComments(post.groupId, post.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No comments yet."));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final comment = snapshot.data![index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: comment.userProfilePic.isNotEmpty
                          ? NetworkImage(comment.userProfilePic)
                          : null,
                      backgroundColor: Colors.deepPurple,
                      child: comment.userProfilePic.isEmpty
                          ? Text(comment.username[0])
                          : null,
                    ),
                    title: Text(comment.content),
                    subtitle: Text(comment.content),
                    trailing: Text(
                      "${comment.createdAt.day}.${comment.createdAt.month} "
                      "${comment.createdAt.hour}:${comment.createdAt.minute.toString().padLeft(2, "0")}",
                    ),
                  );
                },
              );
            },
          ),

          // Comment Input
          CommentBottomSheet(
              post: post, groupDetailService: groupDetailService),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    String likeCount = post.likes.length <= 1 ? "like" : "likes";
    String commentCount = post.comments.length <= 1 ? "comment" : "comments";
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Information
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.userProfilePic.isNotEmpty
                  ? NetworkImage(post.userProfilePic)
                  : null,
              backgroundColor: Colors.deepPurple,
              child:
                  post.userProfilePic.isEmpty ? Text(post.username[0]) : null,
            ),
            title: Text(
              post.username,
              style: ProjectTextStyles.cardHeaderTextStyle,
            ),
            subtitle: Text(
              "${post.createdAt.day}.${post.createdAt.month}.${post.createdAt.year} "
              "${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, "0")}",
              style: ProjectTextStyles.subtitleTextStyle,
            ),
          ),

          // Post Content
          if (post.content.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                post.content,
                style: ProjectTextStyles.cardDescriptionTextStyle,
              ),
            ),

          // Post Image
          if (post.imageUrl != null)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
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

          // Like and Comment Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: post.likes.contains(currentUser!.uid)
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: onLike,
                ),
                Text("${post.likes.length} $likeCount"),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () => _showComments(context),
                ),
                Text("${post.comments.length} $commentCount"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
