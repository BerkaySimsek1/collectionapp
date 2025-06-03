import "package:collectionapp/designElements/common_ui_methods.dart";
import "package:collectionapp/firebase_methods/notification_methods.dart";
import "package:collectionapp/firebase_methods/user_firestore_methods.dart";
import "package:collectionapp/models/user_info_model.dart";
import "package:collectionapp/models/notification_model.dart";
import "package:collectionapp/screens/adressScreens/address_main_screen.dart";
import "package:collectionapp/screens/auctionScreens/auctionPurchaseScreens/order_main_screen.dart";
import "package:collectionapp/screens/auctionScreens/userAuctionScreens/user_auction_main_screen.dart";
import "package:collectionapp/screens/notificationScreens/notifications_screen.dart";
import "package:collectionapp/screens/paymentScreens/payment_methods_screen.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/screens/authScreens/auth_screen.dart";
import "package:collectionapp/screens/socialMediaScreens/sm_main_screen.dart";
import "package:collectionapp/screens/profileScreens/user_profile_screen.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:collectionapp/screens/auctionScreens/auction_main_screen.dart";
import "package:collectionapp/screens/userCollectionScreens/collection_main_screen.dart";
import "package:google_fonts/google_fonts.dart";
import "package:collectionapp/screens/paymentScreens/add_funds_screen.dart";
import "package:collectionapp/screens/paymentScreens/withdraw_funds_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // İlk yüklemede de son aktiflik güncellemesi
    UserFirestoreMethods().updateLastActive();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      UserFirestoreMethods().updateLastActive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.hasData) {
          final user = authSnapshot.data;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user!.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    ),
                  ),
                );
              }
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                // This case handles when user data is not found in Firestore
                return Scaffold(
                  backgroundColor: Colors.grey[100],
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildEmptyState(
                            icon: Icons.error_outline,
                            title: "User data not found. Please log in again.",
                            subtitle: "Tap to log out."),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            FirebaseAuth.instance.signOut();
                          },
                          child: Text(
                            "Log Out",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              // Use UserInfoModel to parse the data
              final currentUserInfo = UserInfoModel.fromJson(userData);

              // Check if the user is active
              if (currentUserInfo.isActive == false) {
                return Scaffold(
                  backgroundColor: Colors.grey[100],
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "This user profile is deactivated.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Please contact support for more information.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ProjectFloatingActionButton(
                          title: "Log Out",
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          icon: Icons.exit_to_app,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // If active, proceed with the main application UI
              final firstName = currentUserInfo.firstName;
              final lastName = currentUserInfo.lastName;
              var photoUrl = currentUserInfo.profileImageUrl;

              return Scaffold(
                backgroundColor: Colors.grey[100],
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 70,
                  leading: Builder(
                    builder: (context) => ProjectIconButton(
                        icon: Icons.menu,
                        onPressed: () => Scaffold.of(context).openDrawer()),
                  ),
                  actions: [
                    StreamBuilder<List<NotificationModel>>(
                      stream: NotificationMethods().getNotifications(user.uid),
                      builder: (context, snapshot) {
                        int unreadCount = 0;
                        if (snapshot.hasData) {
                          unreadCount =
                              snapshot.data!.where((n) => !n.isRead).length;
                        }

                        return ProjectIconButton(
                          icon: Icons.notifications,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                          unreadCount: unreadCount,
                        );
                      },
                    ),
                    ProjectIconButton(
                      icon: Icons.person,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                drawer: Drawer(
                  backgroundColor: Colors.white,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          gradient: projectLinearGradient,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                backgroundImage: photoUrl.isNotEmpty
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            Text(
                              "$firstName $lastName",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.email ?? "",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildDrawerItem(
                        icon: Icons.person,
                        title: "Profile",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.gavel,
                        title: "My Auctions",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserAuctionsPage(),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.location_pin,
                        title: "My Adresses",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressMainScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.payments,
                        title: "Payment Methods",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PaymentMethodsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.shopping_basket,
                        title: "Orders",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const OrderMainScreen(), // Replace Placeholder with OrdersPage when available
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        title: "Log Out",
                        onTap: () {
                          showWarningDialog(context, () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Section
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: projectLinearGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.deepPurple.withValues(alpha: 0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back,",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  "$firstName $lastName!",
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Explore your collections and connect with others",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Balance Section
                          _buildBalanceCard(
                              context,
                              currentUserInfo.balance ??
                                  0.0), // Assuming balance is part of UserInfoModel or accessible
                          const SizedBox(height: 32),

                          // Features Section
                          Text(
                            "Features",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Feature Cards
                          _buildFeatureCard(
                            context,
                            title: "Auctions",
                            subtitle: "Browse or create auctions",
                            icon: Icons.gavel,
                            gradient: [
                              Colors.purple.shade400,
                              Colors.purple.shade700
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AuctionMainScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            context,
                            title: "Collections",
                            subtitle: "View and manage your collections",
                            icon: Icons.collections,
                            gradient: [
                              Colors.indigo.shade400,
                              Colors.indigo.shade700
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CollectionMainScreen(
                                    userId: user.uid,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            context,
                            title: "Social Media",
                            subtitle: "Connect with others",
                            icon: Icons.people,
                            gradient: [
                              Colors.teal.shade400,
                              Colors.teal.shade700
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SmMainScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const AuthScreen();
        }
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.deepPurple,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            "Balance",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          subtitle: Text(
            "\$${balance.toStringAsFixed(2)}",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.deepPurple,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.add, color: Colors.green),
                    title: Text(
                      'Add Balance',
                      style: GoogleFonts.poppins(),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFundsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.money_off, color: Colors.red),
                    title: Text(
                      'Withdraw Balance',
                      style: GoogleFonts.poppins(),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WithdrawFundsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
