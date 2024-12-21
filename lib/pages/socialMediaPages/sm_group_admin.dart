import "package:cloud_firestore/cloud_firestore.dart";
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
      // Update status in join_requests collection
      await FirebaseFirestore.instance
          .collection("group_join_requests")
          .doc(widget.groupId)
          .update({"status": status});

      if (status == "accepted") {
        // Add user to group"s members
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
      appBar: AppBar(
        title: const Text("Grup Yönetici"),
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
              itemBuilder: (context, index) {
                var request = snapshot.data![index];
                return ListTile(
                  title: Text(
                      "Name: ${request["firstName"]} ${request["lastName"]}"),
                  subtitle: Text("Status: ${request["status"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _updateJoinRequestStatus(
                            request["userId"], "accepted"),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _updateJoinRequestStatus(
                            request["userId"], "declined"),
                      ),
                    ],
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
