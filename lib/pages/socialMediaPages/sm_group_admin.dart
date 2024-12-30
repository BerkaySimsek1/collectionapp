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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> _getJoinRequestsStream() {
    return _firestore
        .collection("group_join_requests")
        .where("groupId", isEqualTo: widget.groupId)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> joinRequests = [];

      for (var doc in querySnapshot.docs) {
        var requestData = doc.data();
        var userDoc = await _firestore
            .collection("users")
            .doc(requestData["userId"])
            .get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          joinRequests.add({
            "requestId": doc.id, // Doküman ID'sini de ekleyelim
            "userId": requestData["userId"],
            "firstName": userData["firstName"],
            "lastName": userData["lastName"],
            "status": requestData["status"],
            "requestedAt": requestData["requestedAt"],
          });
        }
      }

      return joinRequests;
    });
  }

  Future<void> _updateJoinRequestStatus(
      String requestId, String userId, String status) async {
    try {
      // Loading göstergesi için
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          content: Text("Processing request..."),
          duration: Duration(seconds: 1),
        ),
      );

      // Join request'i güncelle
      await _firestore
          .collection("group_join_requests")
          .doc(requestId)
          .update({"status": status});

      // Eğer kabul edildiyse, kullanıcıyı gruba ekle
      if (status == "accepted") {
        await _firestore.collection("groups").doc(widget.groupId).update({
          "members": FieldValue.arrayUnion([userId]),
        });
      }

      // Başarı mesajı
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            content: Text(
              status == "accepted"
                  ? "Request accepted successfully!"
                  : "Request declined successfully!",
              style: ProjectTextStyles.appBarTextStyle.copyWith(
                fontSize: 16,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      // Hata mesajı
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            content: Text(
              "Error updating request: $e",
              style: ProjectTextStyles.appBarTextStyle.copyWith(
                fontSize: 16,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const ProjectAppbar(
        titleText: "Admin Panel",
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getJoinRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    style: ProjectTextStyles.subtitleTextStyle,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "No join requests found.",
                    style: ProjectTextStyles.subtitleTextStyle,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              var request = snapshot.data![index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                          Expanded(
                            child: Column(
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
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: request["status"] == "accepted"
                                  ? Colors.green.withOpacity(0.1)
                                  : request["status"] == "declined"
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              request["status"].toUpperCase(),
                              style: TextStyle(
                                color: request["status"] == "accepted"
                                    ? Colors.green
                                    : request["status"] == "declined"
                                        ? Colors.red
                                        : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (request["status"] == "pending") ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: Text(
                                "Decline",
                                style: ProjectTextStyles.appBarTextStyle
                                    .copyWith(fontSize: 16),
                              ),
                              onPressed: () => _updateJoinRequestStatus(
                                request["requestId"],
                                request["userId"],
                                "declined",
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon:
                                  const Icon(Icons.check, color: Colors.white),
                              label: const Text(
                                "Accept",
                                style: ProjectTextStyles.buttonTextStyle,
                              ),
                              onPressed: () => _updateJoinRequestStatus(
                                request["requestId"],
                                request["userId"],
                                "accepted",
                              ),
                              style: ProjectDecorations.elevatedButtonStyle,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
