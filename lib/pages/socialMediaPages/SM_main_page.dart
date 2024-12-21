import "package:flutter/material.dart";
import "package:collectionapp/firebase_methods/firestore_methods/SM_firestore_methods.dart";
import "package:collectionapp/models/GroupModel.dart";
import "package:collectionapp/pages/socialMediaPages/SM_creategroup_page.dart";
import "package:collectionapp/pages/socialMediaPages/SM_group_detail_page.dart";
import 'package:collectionapp/design_elements.dart';

class GroupsListPage extends StatefulWidget {
  const GroupsListPage({super.key});

  @override
  _GroupsListPageState createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  final _groupService = GroupService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: const ProjectAppbar(
        titletext: "Groups",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search groups",
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = "";
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
          ),
          Expanded(
            child: StreamBuilder<List<Group>>(
              stream: _groupService.getGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No groups found.",
                      style: ProjectTextStyles.subtitleTextStyle,
                    ),
                  );
                }

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
          ),
        ],
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupPage()),
          );
        },
        style: ProjectDecorations.elevatedButtonStyle,
        label: const Text(
          "Create Group",
          style: ProjectTextStyles.buttonTextStyle,
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class GroupListItem extends StatelessWidget {
  final Group group;

  const GroupListItem({super.key, required this.group});
  String get memberCount => group.members.length == 1 ? "member" : "members";
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailPage(group: group),
              ),
            );
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: group.coverImageUrl != null
                ? ClipOval(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Stack(
                        children: [
                          Image.network(
                            group.coverImageUrl!,
                            width: 50,
                            height: 50,
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
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  )
                : Text(
                    group.name[0],
                    style: ProjectTextStyles.cardHeaderTextStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
          title: Text(
            group.name,
            style: ProjectTextStyles.cardHeaderTextStyle,
          ),
          subtitle: Text(
            "${group.members.length} $memberCount",
            style: ProjectTextStyles.subtitleTextStyle,
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.deepPurple),
        ));
  }
}
