import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/design_elements.dart";
import "package:flutter/material.dart";

class SmGroupAdmin extends StatefulWidget {
  final String groupId;
  const SmGroupAdmin({super.key, required this.groupId});

  @override
  _SmGroupAdminState createState() => _SmGroupAdminState();
}

class _SmGroupAdminState extends State<SmGroupAdmin> {
  Future<List<Map<String, dynamic>>> _getJoinRequests() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("group_join_requests")
          .where("groupId", isEqualTo: widget.groupId)
          .get();

      List<Map<String, dynamic>> joinRequests = [];

      for (var doc in querySnapshot.docs) {
        var requestData = doc.data() as Map<String, dynamic>;
        var userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(requestData["userId"])
            .get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          joinRequests.add({
            "userId": requestData["userId"],
            "firstName": userData["firstName"],
            "lastName": userData["lastName"],
            "status": requestData["status"],
            "requestedAt": requestData["requestedAt"],
          });
        }
      }

      return joinRequests;
    } catch (e) {
      debugPrint("Error retrieving join requests: $e");
      return [];
    }
  }

  Future<void> _updateJoinRequestStatus(String userId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection("group_join_requests")
          .doc(widget.groupId)
          .update({"status": status});

      if (status == "accepted") {
        await FirebaseFirestore.instance
            .collection("groups")
            .doc(widget.groupId)
            .update({
          "members": FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      debugPrint("Error updating join request status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const ProjectAppbar(
        titleText: "Admin Panel",
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getJoinRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                var request = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: Text(
                                request["firstName"][0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${request["firstName"]} ${request["lastName"]}",
                                  style: ProjectTextStyles.cardHeaderTextStyle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Status: ${request["status"]}",
                                  style: ProjectTextStyles.subtitleTextStyle,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Chip(
                              label: Text(
                                request["status"].toUpperCase(),
                                style:
                                    ProjectTextStyles.cardDescriptionTextStyle,
                              ),
                              backgroundColor: request["status"] == "accepted"
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: Text("Decline",
                                  style: ProjectTextStyles.appBarTextStyle
                                      .copyWith(fontSize: 16)),
                              onPressed: () => _updateJoinRequestStatus(
                                  request["userId"], "declined"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon:
                                  const Icon(Icons.check, color: Colors.white),
                              label: const Text("Accept",
                                  style: ProjectTextStyles.buttonTextStyle),
                              onPressed: () => _updateJoinRequestStatus(
                                  request["userId"], "accepted"),
                              style: ProjectDecorations.elevatedButtonStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No join requests found."));
          }
        },
      ),
    );
  }
}
