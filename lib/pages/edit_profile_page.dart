import 'package:collectionapp/design_elements.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_methods/firestore_methods/user_firestore_methods.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfilePage({super.key, required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserFirestoreMethods _firestoreService = UserFirestoreMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TextEditingController emailController;
  late TextEditingController passwordController;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    emailController = TextEditingController(text: widget.userData['email']);
    passwordController = TextEditingController();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            content: Text("Failed to load user data",
                style: ProjectTextStyles.appBarTextStyle.copyWith(
                  fontSize: 16,
                )),
          ),
        );
      }
    }
  }

  Future<void> _showEmailChangeDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          "Change Email",
          style: ProjectTextStyles.appBarTextStyle,
        ),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "New Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: ProjectTextStyles.appBarTextStyle.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                String newEmail = emailController.text.trim();
                if (newEmail.isEmpty) {
                  throw Exception("Email cannot be empty");
                }

                await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
                await _firestoreService.updateUserData({"email": newEmail});

                setState(() {
                  userData?["email"] = newEmail;
                });

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    content: Text("Email updated successfully!",
                        style: ProjectTextStyles.appBarTextStyle.copyWith(
                          fontSize: 16,
                        ))));
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      content: Text("Failed to update email: ${e.toString()}",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ))),
                );
              }
            },
            style: ProjectDecorations.elevatedButtonStyle,
            child: const Text(
              "Update",
              style: ProjectTextStyles.buttonTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPasswordChangeDialog() async {
    final TextEditingController newPasswordController = TextEditingController();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          "Change Password",
          style: ProjectTextStyles.appBarTextStyle,
        ),
        content: TextField(
          controller: newPasswordController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "New Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: ProjectTextStyles.appBarTextStyle.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                String newPassword = newPasswordController.text.trim();
                if (newPassword.isEmpty) {
                  throw Exception("Password cannot be empty");
                }

                await _auth.currentUser?.updatePassword(newPassword);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      content: Text("Password updated successfully!",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ))),
                );
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      content:
                          Text("Failed to update password: ${e.toString()}",
                              style: ProjectTextStyles.appBarTextStyle.copyWith(
                                fontSize: 16,
                              ))),
                );
              }
            },
            style: ProjectDecorations.elevatedButtonStyle,
            child: const Text(
              "Update",
              style: ProjectTextStyles.buttonTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUsernameChangeDialog() async {
    final TextEditingController usernameController = TextEditingController();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          "Change Username",
          style: ProjectTextStyles.appBarTextStyle,
        ),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "New Username",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: ProjectTextStyles.appBarTextStyle.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                String newUsername = usernameController.text.trim();
                if (newUsername.isEmpty) {
                  throw Exception("Username cannot be empty");
                }

                await _firestoreService
                    .updateUserData({"username": newUsername});

                setState(() {
                  userData?["username"] = newUsername;
                });

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      content: Text("Username updated successfully!",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ))),
                );
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      content:
                          Text("Failed to update username: ${e.toString()},",
                              style: ProjectTextStyles.appBarTextStyle.copyWith(
                                fontSize: 16,
                              ))),
                );
              }
            },
            style: ProjectDecorations.elevatedButtonStyle,
            child: const Text(
              "Update",
              style: ProjectTextStyles.buttonTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          "Delete Account",
          style: ProjectTextStyles.appBarTextStyle,
        ),
        content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
          style: ProjectTextStyles.cardDescriptionTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: ProjectTextStyles.appBarTextStyle.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            style: ProjectDecorations.elevatedButtonStyle
                .copyWith(backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: () async {
              try {
                await _firestoreService.deleteAccount();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      content: Text("Account deleted successfully!",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ))),
                );
                Navigator.pop(context);
                Navigator.of(context).pop();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      content: Text("Failed to delete account: ${e.toString()}",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ))),
                );
              }
            },
            child: const Text(
              "Delete",
              style: ProjectTextStyles.buttonTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Custom App Bar ve Profil Header
                SliverAppBar(
                  expandedHeight: 300,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.deepPurple,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient Background
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.deepPurple.shade300,
                                Colors.deepPurple.shade700,
                              ],
                            ),
                          ),
                        ),
                        // Profile Content
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: userData?[
                                                  'profileImageUrl'] !=
                                              null
                                          ? NetworkImage(
                                              userData!['profileImageUrl'])
                                          : const NetworkImage(
                                              'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.deepPurple,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userData?['email'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form Alanları
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kişisel Bilgiler Card'ı
                        Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Personal Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildEditableField(
                                  label: "First Name",
                                  value: userData?['firstName'] ?? '',
                                  icon: Icons.person_outline,
                                  onSave: (value) async {
                                    await _firestoreService
                                        .updateUserData({'firstName': value});
                                    setState(
                                        () => userData?['firstName'] = value);
                                  },
                                ),
                                const Divider(height: 24),
                                _buildEditableField(
                                  label: "Last Name",
                                  value: userData?['lastName'] ?? '',
                                  icon: Icons.person_outline,
                                  onSave: (value) async {
                                    await _firestoreService
                                        .updateUserData({'lastName': value});
                                    setState(
                                        () => userData?['lastName'] = value);
                                  },
                                ),
                                const Divider(height: 24),
                                _buildEditableField(
                                  label: "Age",
                                  value: userData?['age']?.toString() ?? '',
                                  icon: Icons.cake_outlined,
                                  onSave: (value) async {
                                    await _firestoreService.updateUserData(
                                        {'age': int.parse(value)});
                                    setState(() =>
                                        userData?['age'] = int.parse(value));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Hesap Ayarları Card'ı
                        Card(
                          elevation: 2,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Account Settings",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSettingsButton(
                                  label: "Change Email",
                                  icon: Icons.mail_outline,
                                  onTap: _showEmailChangeDialog,
                                ),
                                const Divider(height: 4),
                                _buildSettingsButton(
                                  label: "Change Password",
                                  icon: Icons.lock_outline,
                                  onTap: _showPasswordChangeDialog,
                                ),
                                const Divider(height: 4),
                                _buildSettingsButton(
                                  label: "Change Username",
                                  icon: Icons.person_outline,
                                  onTap: _showUsernameChangeDialog,
                                ),
                                const Divider(height: 4),
                                _buildSettingsButton(
                                  label: "Delete Account",
                                  icon: Icons.delete_outline,
                                  color: Colors.red,
                                  onTap: _showDeleteAccountDialog,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            color: Colors.deepPurple,
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onSave(controller.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.deepPurple,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: color),
    );
  }
}
