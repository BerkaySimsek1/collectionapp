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
                Expanded(
                  flex: 25,
                  child: Container(
                    height: 48,
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
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
                                icon:
                                    Icon(Icons.clear, color: Colors.grey[600]),
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
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 48,
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
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 48,
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
                                    style: const TextStyle(
                                        color: Colors.deepPurple),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            child: group.coverImageUrl != null
                ? Image.network(
                    group.coverImageUrl ?? "",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.red),
                  )
                : SizedBox(
                    height: 180,
                    child: Center(
                      child: Icon(
                        Icons.group_outlined,
                        color: Colors.grey[200],
                        size: 180,
                      ),
                    ),
                  ),
          ),
          ListTile(
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
            leading: const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.group, color: Colors.white),
            ),
            title: Text(
              group.name,
              style: ProjectTextStyles.appBarTextStyle.copyWith(fontSize: 18),
            ),
            subtitle: Text(
              "${group.members.length} $memberCount",
              style: ProjectTextStyles.cardDescriptionTextStyle.copyWith(
                fontSize: 16,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.deepPurple,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
