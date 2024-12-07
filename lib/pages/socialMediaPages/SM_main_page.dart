import 'package:collectionapp/firebase_methods/firestore_methods/SM_firestore_methods.dart';
import 'package:collectionapp/models/GroupModel.dart';
import 'package:collectionapp/pages/socialMediaPages/SM_creategroup_page.dart';
import 'package:collectionapp/pages/socialMediaPages/SM_grup_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupsListPage extends StatefulWidget {
  @override
  _GroupsListPageState createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  final _groupService = GroupService();
  final _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Grupları ara...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateGroupPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Group>>(
        stream: _groupService.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Henüz hiç grup yok'),
            );
          }

          // Arama filtrelemesi
          final filteredGroups = snapshot.data!
              .where((group) =>
                  group.name.toLowerCase().contains(_searchQuery) ||
                  group.description.toLowerCase().contains(_searchQuery))
              .toList();

          return ListView.builder(
            itemCount: filteredGroups.length,
            itemBuilder: (context, index) {
              final group = filteredGroups[index];
              return GroupListItem(group: group);
            },
          );
        },
      ),
    );
  }
}

class GroupListItem extends StatelessWidget {
  final Group group;

  const GroupListItem({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: group.coverImageUrl != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(group.coverImageUrl!),
              )
            : CircleAvatar(
                child: Text(group.name[0]),
              ),
        title: Text(group.name),
        subtitle: Text(
          '${group.members.length} üye',
          style: TextStyle(fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right),
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
  }
}
