import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/common_ui_methods.dart";
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:collectionapp/widgets/common/project_layout.dart';

class SmGroupAdmin extends StatefulWidget {
  final String groupId;
  const SmGroupAdmin({super.key, required this.groupId});

  @override
  _SmGroupAdminState createState() => _SmGroupAdminState();
}

class _SmGroupAdminState extends State<SmGroupAdmin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase metodları aynı kalıyor
  Future<void> sendJoinRequest(String groupId, String userId) async {
    await _firestore
        .collection("joinRequests")
        .doc(groupId)
        .collection("requests")
        .doc(userId)
        .set({
      "userId": userId,
      "status": "pending",
      "requestedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<bool> getJoinRequest(String groupId, String userId) async {
    final requestDoc = await _firestore
        .collection("joinRequests")
        .doc(groupId)
        .collection("requests")
        .doc(userId)
        .get();
    return requestDoc.exists;
  }

  Stream<List<Map<String, dynamic>>> _getJoinRequestsStream() {
    return _firestore
        .collection("joinRequests")
        .doc(widget.groupId)
        .collection("requests")
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> joinRequests = [];
      for (var doc in querySnapshot.docs) {
        var requestData = doc.data();
        final userId = requestData["userId"];
        if (userId == null) continue;

        var userDoc = await _firestore.collection("users").doc(userId).get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          joinRequests.add({
            "requestId": doc.id,
            "userId": userId,
            "firstName": userData["firstName"] ?? "",
            "lastName": userData["lastName"] ?? "",
            "profileImageUrl": userData["profileImageUrl"],
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
      if (mounted) {
        projectSnackBar(context, "Processing request...", "blue");
      }

      await _firestore
          .collection("joinRequests")
          .doc(widget.groupId)
          .collection("requests")
          .doc(requestId)
          .update({"status": status});

      if (status == "accepted") {
        await _firestore.collection("groups").doc(widget.groupId).update({
          "members": FieldValue.arrayUnion([userId]),
        });
      }

      if (mounted) {
        projectSnackBar(
          context,
          status == "accepted"
              ? "Request accepted successfully!"
              : "Request declined successfully!",
          status == "accepted" ? "green" : "red",
        );
      }
    } catch (e) {
      if (mounted) {
        projectSnackBar(context, "Error updating request: $e", "red");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProjectLayout(
      title: "Admin Panel",
      subtitle: "Manage join requests",
      headerIcon: Icons.admin_panel_settings,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getJoinRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.deepPurple.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading requests...",
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading requests",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.group_off_outlined,
                      size: 64,
                      color: Colors.deepPurple.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Join Requests",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "There are no pending requests at the moment",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var request = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.deepPurple.shade100,
                            backgroundImage:
                                (request["profileImageUrl"] != null &&
                                        request["profileImageUrl"]
                                            .toString()
                                            .isNotEmpty)
                                    ? NetworkImage(request["profileImageUrl"])
                                    : null,
                            child: (request["profileImageUrl"] == null ||
                                    request["profileImageUrl"]
                                        .toString()
                                        .isEmpty)
                                ? Text(
                                    (request["firstName"] != null &&
                                            request["firstName"]
                                                .toString()
                                                .isNotEmpty)
                                        ? request["firstName"][0].toUpperCase()
                                        : "?",
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${request["firstName"]} ${request["lastName"]}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(request["status"])
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    request["status"].toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(request["status"]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (request["status"] == "pending")
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _updateJoinRequestStatus(
                                    request["requestId"],
                                    request["userId"],
                                    "declined",
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.close,
                                            color: Colors.red[400]),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Decline",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _updateJoinRequestStatus(
                                    request["requestId"],
                                    request["userId"],
                                    "accepted",
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check,
                                            color: Colors.green[400]),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Accept",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
