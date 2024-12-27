import "package:flutter/material.dart";
import "package:collectionapp/firebase_methods/firestore_methods/SM_firestore_methods.dart";
import "package:collectionapp/models/GroupModel.dart";
import "package:collectionapp/pages/socialMediaPages/SM_creategroup_page.dart";
import "package:collectionapp/pages/socialMediaPages/SM_group_detail_page.dart";
import 'package:collectionapp/design_elements.dart';
import 'package:collectionapp/models/predefined_collections.dart';

class GroupsListPage extends StatefulWidget {
  const GroupsListPage({super.key});

  @override
  _GroupsListPageState createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  final _groupService = GroupService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";
  String _selectedSort = "A-Z";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const ProjectAppbar(
        titleText: "Groups",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search groups",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    // Arama ikonunu ekliyoruz
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                    // Sadece text doluysa "X" (clear) ikonunu göster
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    // İsteğe bağlı ek padding
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    // Kenarlık ayarları
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                )),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () {
                    _showFilterDialog();
                  },
                ),
                DropdownButton<String>(
                  value: _selectedSort,
                  items: ["A-Z", "Z-A"]
                      .map((sortOption) => DropdownMenuItem(
                            value: sortOption,
                            child: Text(sortOption),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value!;
                    });
                  },
                ),
              ],
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.group_off,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "No groups found.",
                          style: ProjectTextStyles.subtitleTextStyle,
                        ),
                      ],
                    ),
                  );
                }

                final filteredGroups = snapshot.data!
                    .where((group) =>
                        (_selectedFilter == "All" ||
                            group.category == _selectedFilter) &&
                        (group.name.toLowerCase().contains(_searchQuery) ||
                            group.description
                                .toLowerCase()
                                .contains(_searchQuery)))
                    .toList();

                if (_selectedSort == "Z-A") {
                  filteredGroups.sort((a, b) => b.name.compareTo(a.name));
                } else {
                  filteredGroups.sort((a, b) => a.name.compareTo(b.name));
                }

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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filter by Category"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text("All"),
                  value: "All",
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                ...predefinedCollections.keys.map((category) {
                  return RadioListTile<String>(
                    title: Text(category),
                    value: category,
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
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
