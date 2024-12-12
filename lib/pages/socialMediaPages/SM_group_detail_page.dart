import 'package:collectionapp/firebase_methods/firestore_methods/SM_firestore_methods.dart';
import 'package:collectionapp/models/GroupModel.dart';
import 'package:collectionapp/models/PostModel.dart';
import 'package:collectionapp/pages/socialMediaPages/SM_group_admin.dart';
import 'package:collectionapp/pages/socialMediaPages/create_post_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupDetailPage extends StatefulWidget {
  final Group group;

  const GroupDetailPage({super.key, required this.group});

  @override
  // ignore: library_private_types_in_public_api
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final _groupDetailService = GroupDetailService();
  final _currentUser = FirebaseAuth.instance.currentUser;
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _checkMemberStatus();
  }

  Future<void> _checkMemberStatus() async {
    final isMember = await _groupDetailService.isUserMember(
        widget.group.id, _currentUser!.uid);
    setState(() {
      _isMember = isMember;
    });
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
              )),

          // Katılma/Gönderi Bölümü
          if (!_isMember)
            ElevatedButton(
              onPressed: () => _groupDetailService.sendJoinRequest(
                  widget.group.id, _currentUser.uid),
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

  const PostWidget({Key? key, required this.post, required this.onLike})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _currentUser = FirebaseAuth.instance.currentUser;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    // Yorum ekleme sayfasına yönlendirme
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
