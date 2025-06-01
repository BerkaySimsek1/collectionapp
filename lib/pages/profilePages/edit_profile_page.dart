import 'dart:io';
import 'package:collectionapp/common_ui_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../firebase_methods/user_firestore_methods.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfilePage({super.key, required this.userData});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final UserFirestoreMethods _firestoreService = UserFirestoreMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TextEditingController emailController;
  late TextEditingController passwordController;

  File? _pickedImage;
  bool _isUpdatingPhoto = false;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    emailController = TextEditingController(text: widget.userData['email']);
    passwordController = TextEditingController();
  }

  Future<void> _pickProfileImage() async {
    try {
      // Eğer image_picker paketini eklemediyseniz, pubspec.yaml'e eklemeyi unutmayın
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
        // Ardından seçilen fotoğrafı Firebase'e yükle
        await _uploadProfileImage(_pickedImage!);
      }
    } catch (e) {
      if (mounted) {
        projectSnackBar(context, "Failed to pick image: $e", "red");
      }
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    setState(() => _isUpdatingPhoto = true);

    try {
      // Kullanıcı UID'sini al (auth ile veya userData içinden)
      final uid = _auth.currentUser?.uid ?? userData?['uid'];
      if (uid == null) throw Exception("User not found");

      // Storage referansı oluştur (profilePics klasörünün içine uid.jpg)
      final storageRef =
          FirebaseStorage.instance.ref().child('profilePics/$uid.jpg');

      // Dosyayı yükle
      await storageRef.putFile(imageFile);

      // Yüklenen dosyanın URL'ini al
      final downloadUrl = await storageRef.getDownloadURL();

      // Firestore'da profileImageUrl güncelle
      await _firestoreService.updateUserData({"profileImageUrl": downloadUrl});

      // Ekrandaki userData bilgisini güncelle
      setState(() {
        userData?["profileImageUrl"] = downloadUrl;
      });

      if (mounted) {
        projectSnackBar(
            context, "Profile photo updated successfully!", "green");
      }
    } catch (e) {
      if (mounted) {
        projectSnackBar(context, "Failed to upload photo: $e", "red");
      }
    } finally {
      setState(() => _isUpdatingPhoto = false);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _firestoreService.getUserData();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        projectSnackBar(context, "Failed to load user data", "red");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        extendBodyBehindAppBar: true,
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.deepPurple),
                    const SizedBox(height: 16),
                    Text(
                      "Loading profile...",
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  return false;
                },
                child: NestedScrollView(
                  physics: const ClampingScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        flexibleSpace: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            final scrollPercent = constraints.maxHeight >
                                    kToolbarHeight
                                ? 1 -
                                    (constraints.maxHeight - kToolbarHeight) /
                                        (360 - kToolbarHeight)
                                : 1.0;
                            final opacity =
                                ((scrollPercent - 0.1) / 0.6).clamp(0.0, 1.0);

                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.deepPurple.shade400,
                                    Colors.deepPurple.shade800,
                                  ],
                                ),
                              ),
                              child: FlexibleSpaceBar(
                                centerTitle: true,
                                titlePadding: const EdgeInsets.only(bottom: 16),
                                title: Opacity(
                                  opacity: opacity,
                                  child: Text(
                                    "Edit Profile",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                background: _buildProfileHeader(),
                              ),
                            );
                          },
                        ),
                        elevation: 0,
                        floating: false,
                        pinned: true,
                        expandedHeight: 360,
                        leading: const ProjectIconButton(),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: SliverAppBarDelegate(
                          minHeight: 80,
                          maxHeight: 80,
                          child: Container(
                            color: Colors.white,
                            child: _buildTabSection(),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    physics: const ClampingScrollPhysics(),
                    children: [
                      _buildPersonalInfoTab(),
                      _buildAccountSettingsTab(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _showUsernameChangeDialog() async {
    final TextEditingController usernameController = TextEditingController();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Change Username",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter your new username",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                        ),
                      ),
                      child: TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: "New Username",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.grey[400],
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                String newUsername =
                                    usernameController.text.trim();
                                if (newUsername.isEmpty) {
                                  throw Exception("Username cannot be empty");
                                }

                                await _firestoreService
                                    .updateUserData({"username": newUsername});

                                setState(() {
                                  userData?["username"] = newUsername;
                                });

                                if (!mounted) return;
                                Navigator.pop(context);
                                projectSnackBar(context,
                                    "Username updated successfully!", "green");
                              } catch (e) {
                                projectSnackBar(
                                    context,
                                    "Failed to update username: ${e.toString()}",
                                    "red");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Update",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TabBar(
          indicatorPadding: const EdgeInsets.symmetric(horizontal: -12),
          dividerHeight: 0,
          indicator: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(25),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            SizedBox(
              height: 45,
              child: Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text("Personal Info"),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 45,
              child: Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text("Settings"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Personal Information",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEditableField(
            label: "First Name",
            value: userData?['firstName'] ?? '',
            icon: Icons.badge_outlined,
            onSave: (value) async {
              await _firestoreService.updateUserData({'firstName': value});
              setState(() => userData?['firstName'] = value);
              if (mounted) {
                projectSnackBar(
                    context, "First name updated successfully!", "green");
              }
            },
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            label: "Last Name",
            value: userData?['lastName'] ?? '',
            icon: Icons.badge_outlined,
            onSave: (value) async {
              await _firestoreService.updateUserData({'lastName': value});
              setState(() => userData?['lastName'] = value);
              if (mounted) {
                projectSnackBar(
                    context, "Last name updated successfully!", "green");
              }
            },
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            label: "Age",
            value: userData?['age']?.toString() ?? '',
            icon: Icons.cake_outlined,
            onSave: (value) async {
              await _firestoreService.updateUserData({'age': int.parse(value)});
              setState(() => userData?['age'] = int.parse(value));
              if (mounted) {
                projectSnackBar(context, "Age updated successfully!", "green");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Account Settings",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
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
            child: Column(
              children: [
                _buildSettingsButton(
                  label: "Change Email",
                  icon: Icons.mail_outline,
                  description: "Update your email address",
                  onTap: _showEmailChangeDialog,
                ),
                const Divider(height: 1),
                _buildSettingsButton(
                  label: "Change Username",
                  icon: Icons.person_outline,
                  description: "Update your username",
                  onTap: _showUsernameChangeDialog,
                ),
                const Divider(height: 1),
                _buildSettingsButton(
                  label: "Change Password",
                  icon: Icons.lock_outline,
                  description: "Update your password",
                  onTap: _showPasswordChangeDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
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
            child: _buildSettingsButton(
              label: "Delete Account",
              icon: Icons.delete_outline,
              description: "Permanently delete your account",
              onTap: _showDeleteAccountDialog,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEmailChangeDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mail_outline,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Change Email",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter your new email address",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                        ),
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "New Email",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Icon(
                            Icons.mail_outline,
                            color: Colors.grey[400],
                          ),
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                String newEmail = emailController.text.trim();
                                if (newEmail.isEmpty) {
                                  throw Exception("Email cannot be empty");
                                }

                                await _auth.currentUser
                                    ?.verifyBeforeUpdateEmail(newEmail);
                                await _firestoreService
                                    .updateUserData({"email": newEmail});

                                setState(() {
                                  userData?["email"] = newEmail;
                                });
                                Navigator.pop(context);
                                projectSnackBar(context,
                                    "Email updated successfully!", "green");
                              } catch (e) {
                                projectSnackBar(
                                    context,
                                    "Failed to update email: ${e.toString()}",
                                    "red");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Update",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPasswordChangeDialog() async {
    final TextEditingController newPasswordController = TextEditingController();
    bool isPasswordVisible = false;
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Change Password",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter your new password",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                          ),
                        ),
                        child: TextField(
                          controller: newPasswordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: "New Password",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[400],
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[400],
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Password must be at least 6 characters",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  String newPassword =
                                      newPasswordController.text.trim();
                                  if (newPassword.isEmpty) {
                                    throw Exception("Password cannot be empty");
                                  }
                                  if (newPassword.length < 6) {
                                    throw Exception(
                                        "Password must be at least 6 characters");
                                  }

                                  await _auth.currentUser
                                      ?.updatePassword(newPassword);
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  projectSnackBar(
                                      context,
                                      "Password updated successfully!",
                                      "green");
                                } catch (e) {
                                  projectSnackBar(
                                      context,
                                      "Failed to update password: ${e.toString()}",
                                      "red");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Update",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                "Delete Account",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "This action cannot be undone. All your data will be permanently deleted.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await _firestoreService.deleteAccount();
                            if (!mounted) return;
                            Navigator.pop(context);
                            Navigator.of(context).pop();
                            projectSnackBar(context,
                                "Account deleted successfully!", "green");
                          } catch (e) {
                            projectSnackBar(
                                context,
                                "Failed to delete account: ${e.toString()}",
                                "red");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Delete",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade400,
            Colors.deepPurple.shade800,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Dekoratif Daireler
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),

          // Profil İçeriği
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Profil Fotoğrafı
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              (userData?['profileImageUrl'] != null &&
                                      userData?['profileImageUrl'].isNotEmpty)
                                  ? NetworkImage(userData?['profileImageUrl'])
                                  : null,
                          child: (userData?['profileImageUrl'] == null ||
                                  userData?['profileImageUrl'].isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Colors.deepPurple,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _isUpdatingPhoto ? null : _pickProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                              child: _isUpdatingPhoto
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // İsim
                Text(
                  "${userData?['firstName'] ?? 'First'} ${userData?['lastName'] ?? 'Last'}",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Email
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.mail_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        userData?['email'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Konum ve Durum
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Sunnyvale, CA",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Active Bidder",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required IconData icon,
    required Function(String) onSave,
  }) {
    final TextEditingController controller = TextEditingController(text: value);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                labelStyle: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
              style: GoogleFonts.poppins(),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              onTap: () {
                if (controller.text.trim().isNotEmpty) {
                  onSave(controller.text.trim());
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton({
    required String label,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.deepPurple,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
