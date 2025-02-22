import 'package:collectionapp/pages/auctionPages/userAuctionPages/created_auction.dart';
import 'package:collectionapp/pages/auctionPages/userAuctionPages/joined_auctions_list.dart';
import 'package:collectionapp/pages/auctionPages/userAuctionPages/won_auctions_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Model ve ViewModel dosyalarınızı, AuctionModel vs. import edin
// import 'package:collectionapp/models/AuctionModel.dart';
// import 'package:collectionapp/models/UserInfoModel.dart';

class UserAuctionsPage extends StatefulWidget {
  const UserAuctionsPage({Key? key}) : super(key: key);

  @override
  State<UserAuctionsPage> createState() => _UserAuctionsPageState();
}

class _UserAuctionsPageState extends State<UserAuctionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Kullanıcı giriş yapmamış.")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Auctions"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Created"),
            Tab(text: "Joined"),
            Tab(text: "Won"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 3 sekme için 3 ayrı widget
          CreatedAuctionsList(userUid: user!.uid),
          JoinedAuctionsList(userUid: user!.uid),
          WonAuctionsList(userUid: user!.uid),
        ],
      ),
    );
  }
}
