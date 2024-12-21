import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/UserInfoModel.dart';
import 'package:collectionapp/pages/auctionPages/create_auction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Kullanıcı giriş yaptıktan sonra görünen ana sayfa
class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  UserInfoModel? userInfo;

  @override
  void initState() {
    super.initState();
    getUser(user.uid); // Kullanıcı bilgilerini başlatırken al
  }

  void getUser(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        setState(() {
          userInfo = UserInfoModel.fromJson(doc.data() as Map<String, dynamic>);
        });
      } else {
        debugPrint("User not found");
      }
    } catch (e) {
      debugPrint("Error occured: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello ${userInfo?.username}!"),
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuctionUploadScreen()));
            },
            icon: const Icon(Icons.add)),
      ),
      body: Center(
        child: userInfo == null
            ? const CircularProgressIndicator() // userInfo null ise yükleniyor göstergesi göster
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Giriş yapılan e-posta: ${user.email!}"),
                  MaterialButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    color: Colors.deepPurple,
                    child: const Text("Çıkış Yap"),
                  ),
                ],
              ),
      ),
    );
  }
}
