import 'package:collectionapp/pages/auctionPages/userAuctionPages/created_auctions_list.dart';
import 'package:collectionapp/pages/auctionPages/userAuctionPages/joined_auctions_list.dart';
import 'package:collectionapp/pages/auctionPages/userAuctionPages/won_auctions_list.dart';
import 'package:collectionapp/widgets/common/project_multi_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class UserAuctionsPage extends StatelessWidget {
  const UserAuctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
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
                  Icons.person_off_outlined,
                  size: 64,
                  color: Colors.deepPurple.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "User not logged in",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ProjectMultiLayout(
      title: "My Auctions",
      subtitle: "Manage your auction activities",
      headerIcon: Icons.gavel_outlined,
      tabs: const [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.create_outlined),
              SizedBox(width: 4),
              Text("Created"),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gavel_outlined),
              SizedBox(width: 8),
              Text("Joined"),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined),
              SizedBox(width: 8),
              Text("Won"),
            ],
          ),
        ),
      ],
      tabViews: [
        CreatedAuctionsList(userUid: user.uid),
        JoinedAuctionsList(userUid: user.uid),
        WonAuctionsList(userUid: user.uid),
      ],
    );
  }
}
