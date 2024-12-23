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
        backgroundColor: Colors.grey[100],
        appBar: ProjectAppbar(
          titleText: widget.group.name,
        ),
        body: Column(
          children: [
            // Group Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(0, 2), color: Colors.grey, blurRadius: 1)
                  ]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.group.coverImageUrl != null
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.group.coverImageUrl!),
                          radius: 40,
                        )
                      : CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            widget.group.name[0],
                            style:
                                ProjectTextStyles.cardHeaderTextStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.group.name,
                        style: ProjectTextStyles.cardHeaderTextStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.group.description,
                        style: ProjectTextStyles.subtitleTextStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.group.members.length} $memberCount",
                        style: ProjectTextStyles.subtitleTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  if (widget.group.adminIds.contains(_currentUser!.uid))
                    Center(
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
                        style: ProjectDecorations.elevatedButtonStyle,
                        icon: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Admin Panel",
                          style: ProjectTextStyles.buttonTextStyle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 1),

            if (_isMember == null || hasJoinRequest == null)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (!_isMember!)
              hasJoinRequest!
                  ? const Expanded(child: Center(child: Text("Request sent")))
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
                child: StreamBuilder<List<Post>>(
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
                            const SizedBox(height: 16),
                            Text(
                              "No posts yet.",
                              style: ProjectTextStyles.subtitleTextStyle,
                            ),
                          ],
                        ),
                      );
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
        floatingActionButton: _isMember == null || _isMember!
            ? FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                          child: CreatePostWidget(groupId: widget.group.id));
                    },
                  );
                },
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null);
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
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                      title: Text(comment.username),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    String likeCount = post.likes.length <= 1 ? "like" : "likes";
    String commentCount = post.comments.length <= 1 ? "comment" : "comments";
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),

          // Post Content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
