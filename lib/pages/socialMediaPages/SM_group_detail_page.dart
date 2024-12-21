import 'package:collectionapp/firebase_methods/firestore_methods/SM_firestore_methods.dart';
import 'package:collectionapp/models/GroupModel.dart';
import 'package:collectionapp/models/PostModel.dart';
import 'package:collectionapp/pages/socialMediaPages/SM_group_admin.dart';
import 'package:collectionapp/pages/socialMediaPages/comment_bottom_sheet.dart';
import 'package:collectionapp/pages/socialMediaPages/create_post_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeStatus();
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
        SnackBar(content: Text('İstek gönderilemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: Column(
        children: [
          // Grup Bilgileri
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.group.coverImageUrl != null
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.group.coverImageUrl!),
                        minRadius: 50,
                        maxRadius: 75,
                      )
                    : CircleAvatar(
                        child: Text(widget.group.name[0]),
                      ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(widget.group.description),
                    const SizedBox(height: 8),
                    Text('${widget.group.members.length} üye'),
                  ],
                ),
                const Spacer(),
                widget.group.adminIds.contains(_currentUser!.uid)
                    ? TextButton(
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
                        child: const Text("Admin işlemleri"))
                    : const Text("")
              ],
            ),
          ),

          if (_isMember == null || hasJoinRequest == null)
            const Center(child: CircularProgressIndicator())
          else if (!_isMember!)
            hasJoinRequest!
                ? const Text("İstek Gönderildi")
                : ElevatedButton(
                    onPressed: _sendJoinRequest,
                    child: const Text('Gruba Katılma İsteği Gönder'),
                  )
          else
            Expanded(
              child: Column(
                children: [
                  // Gönderi Oluşturma Widgetı
                  CreatePostWidget(groupId: widget.group.id),

                  // Gönderiler Listesi
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
                          return const Center(child: Text('Henüz gönderi yok'));
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
    );
  }
}

class PostWidget extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final GroupDetailService groupDetailService;

  const PostWidget(
      {Key? key,
      required this.post,
      required this.onLike,
      required this.groupDetailService})
      : super(key: key);

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
                return const Center(child: Text('Henüz yorum yok'));
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
                      child: comment.userProfilePic.isEmpty
                          ? Text(comment.username[0])
                          : null,
                    ),
                    title: Text(comment.username),
                    subtitle: Text(comment.content),
                    trailing: Text(
                      '${comment.createdAt.day}.${comment.createdAt.month} '
                      '${comment.createdAt.hour}:${comment.createdAt.minute.toString().padLeft(2, '0')}',
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
    final _currentUser = FirebaseAuth.instance.currentUser;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı Bilgileri
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.userProfilePic.isNotEmpty
                  ? NetworkImage(post.userProfilePic)
                  : null,
              child:
                  post.userProfilePic.isEmpty ? Text(post.username[0]) : null,
            ),
            title: Text(post.username),
            subtitle: Text(
                '${post.createdAt.day}.${post.createdAt.month}.${post.createdAt.year} '
                '${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}'),
          ),

          // Gönderi İçeriği
          if (post.content.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(post.content),
            ),

          // Gönderi Resmi
          if (post.imageUrl != null)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

          // Beğeni ve Yorum Bölümü
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: post.likes.contains(_currentUser!.uid)
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: onLike,
                ),
                Text('${post.likes.length} beğeni'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () => _showComments(context),
                ),
                Text('${post.comments.length} yorum'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
