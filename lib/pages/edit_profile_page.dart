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
          const SnackBar(content: Text("Failed to load user data")),
        );
      }
    }
  }

  Future<void> _showEmailChangeDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

                await _auth.currentUser?.updateEmail(newEmail);
                await _firestoreService.updateUserData({"email": newEmail});

                setState(() {
                  userData?["email"] = newEmail;
                });

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email updated successfully!")),
                );
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Failed to update email: ${e.toString()}")),
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
                  const SnackBar(
                      content: Text("Password updated successfully!")),
                );
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("Failed to update password: ${e.toString()}")),
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
                  const SnackBar(
                      content: Text("Account deleted successfully!")),
                );
                Navigator.pop(context);
                Navigator.of(context).pop();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("Failed to delete account: ${e.toString()}")),
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
            radius: 50,
            backgroundImage: userData?['profileImageUrl'] != null
                ? NetworkImage(userData!['profileImageUrl'])
                : const NetworkImage(
                    'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(blurRadius: 0.1, spreadRadius: 0.5)],
            color: Colors.deepPurple,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
                "${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}",
                style: ProjectTextStyles.buttonTextStyle),
          ),
        ),
        const SizedBox(height: 8),
        Text(userData?['email'] ?? '',
            style: ProjectTextStyles.cardDescriptionTextStyle),
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required Function(String) onSave,
  }) {
    final TextEditingController controller = TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.deepPurple),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await onSave(controller.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.deepPurple,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const ProjectAppbar(
        titleText: "User Profile",
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        _buildEditableField(
                          label: "First Name",
                          value: userData?['firstName'] ?? '',
                          onSave: (value) async {
                            await _firestoreService
                                .updateUserData({'firstName': value});
                            setState(() => userData?['firstName'] = value);
                          },
                        ),
                        _buildEditableField(
                          label: "Last Name",
                          value: userData?['lastName'] ?? '',
                          onSave: (value) async {
                            await _firestoreService
                                .updateUserData({'lastName': value});
                            setState(() => userData?['lastName'] = value);
                          },
                        ),
                        _buildEditableField(
                          label: "Age",
                          value: userData?['age']?.toString() ?? '',
                          onSave: (value) async {
                            await _firestoreService
                                .updateUserData({'age': int.parse(value)});
                            setState(() => userData?['age'] = int.parse(value));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActionButton(
                          label: "Change Email",
                          icon: Icons.mail,
                          onTap: () {
                            _showEmailChangeDialog();
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildActionButton(
                          label: "Change Password",
                          icon: Icons.lock,
                          onTap: () {
                            _showPasswordChangeDialog();
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildActionButton(
                          label: "Delete Account",
                          icon: Icons.delete,
                          color: Colors.red,
                          onTap: () {
                            _showDeleteAccountDialog();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
