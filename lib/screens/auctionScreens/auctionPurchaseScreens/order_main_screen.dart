import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:collectionapp/screens/auctionScreens/auctionPurchaseScreens/purchased_screen.dart';
import 'package:collectionapp/screens/auctionScreens/auctionPurchaseScreens/sold_screen.dart';
import 'package:collectionapp/designElements/layouts/project_multi_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderMainScreen extends StatelessWidget {
  const OrderMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: buildEmptyState(
            icon: Icons.person_off_outlined,
            title: "User not logged in",
            subtitle:
                "You need to be logged in to view your orders. Please log in to continue.",
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
