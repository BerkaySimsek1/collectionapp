import 'package:collectionapp/screens/auctionScreens/auctionPurchaseScreens/purchased_screen.dart';
import 'package:collectionapp/screens/auctionScreens/auctionPurchaseScreens/sold_screen.dart';
import 'package:collectionapp/designElements/layouts/project_multi_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderMainScreen extends StatelessWidget {
  const OrderMainScreen({super.key});

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
      title: "My Orders",
      subtitle: "View your purchased and sold items",
      headerIcon: Icons.shopping_bag_outlined,
      tabs: const [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined),
              SizedBox(width: 4),
              Text("Purchased"),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sell_outlined),
              SizedBox(width: 4),
              Text("Sold"),
            ],
          ),
        ),
      ],
      tabViews: [
        PurchasedScreen(userUid: user.uid),
        SoldPage(userUid: user.uid),
      ],
    );
  }
}
