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
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 48,
                  width: 275,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.black26,
                          width: 0.2,
                        ),
                      ),
                      prefixIconColor: Colors.deepPurple,
                      hintText: "Search groups",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
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
                    ),
                  ),
                ),
                Container(
                  height: 48,
                  width: 48, // Arama kutusunun yüksekliğiyle eşleştirildi
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ]),
                  child: Center(
                    child: IconButton(
                      onPressed: _showFilterDialog,
                      icon: const Icon(Icons.filter_list,
                          color: Colors.deepPurple),
                    ),
                  ),
                ),
                Container(
                  height: 48,
                  width: 60, // Arama kutusunun yüksekliğiyle eşleştirildi
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ]),
                  child: Center(
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      borderRadius: BorderRadius.circular(8),
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.deepPurple),
                      underline: Container(
                        height: 0,
                        color: Colors.white,
                      ),
                      items: ["A-Z", "Z-A"]
                          .map((sortOption) => DropdownMenuItem(
                                value: sortOption,
                                child: Text(
                                  sortOption,
                                  style:
                                      const TextStyle(color: Colors.deepPurple),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // groups list
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupPage()),
          );
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Create Group",
          style: ProjectTextStyles.buttonTextStyle,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Filter by Category",
            style: ProjectTextStyles.appBarTextStyle,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(
                    "All",
                    style: ProjectTextStyles.appBarTextStyle.copyWith(
                      fontSize: 16,
                    ),
                  ),
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
                    title: Text(
                      category,
                      style: ProjectTextStyles.appBarTextStyle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    value: category,
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ProjectDecorations.elevatedButtonStyle,
              child: const Text(
                "Close",
                style: ProjectTextStyles.buttonTextStyle,
              ),
            ),
          ],
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
      color: Colors.white,
      elevation: 4,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
    );
  }
}
