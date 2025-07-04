import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

import 'package:collectionapp/firebase_methods/user_firestore_methods.dart';

class ProjectIconButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onPressed;
  final int? unreadCount;

  const ProjectIconButton({
    super.key,
    this.icon,
    this.onPressed,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon ?? Icons.arrow_back,
              color: Colors.deepPurple,
            ),
          ),
          if (unreadCount != null && unreadCount! > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      onPressed: onPressed ??
          () {
            Navigator.pop(context);
          },
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

void addCustomField(
    BuildContext context,
    List<Map<String, dynamic>> customFields,
    Map<String, dynamic> customFieldValues,
    Function setState) {
  showDialog(
    context: context,
    builder: (context) {
      String fieldName = "";
      String fieldType = "TextField";
      return Dialog(
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
                        color: Colors.deepPurple.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Add Custom Field",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
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
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Field Name",
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withValues(alpha: 0.15),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: const Icon(
                              Icons.label_outline,
                              color: Colors.deepPurple,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) => fieldName = value,
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        value: fieldType,
                        decoration: InputDecoration(
                          labelText: "Field Type",
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withValues(alpha: 0.15),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: const Icon(
                              Icons.category_outlined,
                              color: Colors.deepPurple,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          {"label": "Text", "value": "TextField"},
                          {"label": "Number", "value": "NumberField"},
                          {"label": "Date", "value": "DatePicker"},
                        ].map((type) {
                          return DropdownMenuItem<String>(
                            value: type["value"],
                            child: Text(
                              type["label"]!,
                              style: GoogleFonts.poppins(),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) fieldType = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
                        onPressed: () {
                          if (fieldName.isNotEmpty) {
                            setState(() {
                              customFields
                                  .add({"name": fieldName, "type": fieldType});
                              customFieldValues[fieldName] = null;
                            });
                            Navigator.pop(context);
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
                          "Add",
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
      );
    },
  );
}

String formatNumber(int number) {
  if (number >= 0 && number < 1000) {
    return "$number";
  } else if (number >= 1000 && number < 1000000) {
    return "${(number / 1000).toStringAsFixed(1)}k";
  } else if (number >= 1000000) {
    return "${(number / 1000000).toStringAsFixed(1)}m";
  } else {
    return "$number";
  }
}

TextTheme projectTextTheme(BuildContext context) {
  return GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).copyWith(
    labelSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
  );
}

Future<bool> showWarningDialog(
  BuildContext context,
  VoidCallback onPressed, {
  String title = "Log Out",
  String message = "Are you sure you want to log out?",
  String buttonText = "Log Out",
  IconData icon = Icons.logout_rounded,
  Color color = Colors.deepPurple,
}) async {
  bool result = false;
  await showDialog(
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
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        result = false;
                        Navigator.pop(context);
                      },
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
                      onPressed: () {
                        result = true;
                        onPressed();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        buttonText,
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
  return result;
}

Widget buildBottomButton({
  bool? isLoading = false,
  required VoidCallback? onPressed,
  required String buttonText,
  required IconData icon,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Container(
      decoration: BoxDecoration(
        gradient: projectLinearGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          overlayColor: Colors.red,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: (isLoading == true) ? null : onPressed,
        icon: (isLoading == true) ? null : Icon(icon, color: Colors.white),
        label: (isLoading == true)
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    ),
  );
}

void projectSnackBar(BuildContext context, String message, String status) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: status == "red"
          ? Colors.red
          : status == "green"
              ? Colors.green
              : Colors.deepPurple,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Row(
        children: [
          Icon(
            status == "red" ? Icons.error_outlined : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showReportDialog(
    BuildContext context, String object, String reportedId,
    {String? objectId}) {
  String? reportReason;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  return showDialog(
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
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
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_outlined,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Report $object",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Why are you reporting this $object?",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                        onChanged: (value) {
                          reportReason = value;
                        },
                        decoration: InputDecoration(
                          hintText: "Describe the issue...",
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.poppins()),
                  ),
                  const SizedBox(height: 24),
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
                            // ElevatedButton onPressed içindeki çağrı:
                            await UserFirestoreMethods().reportUserOrAuction(
                              object, // Bu, "user", "auction" veya "group" olabilir
                              currentUserId,
                              reportReason,
                              reportedId:
                                  reportedId, // showReportDialog'un parametrelerinden gelen 'reportedId'
                              auctionId:
                                  objectId, // showReportDialog'un parametrelerinden gelen 'objectId' (sadece müzayede için kullanılır)
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          // ElevatedButton onPressed içindeki çağrı:
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Submit",
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

class ProjectFloatingActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final IconData icon;

  const ProjectFloatingActionButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: projectLinearGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

LinearGradient get projectLinearGradient => LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.deepPurple.shade400,
        Colors.deepPurple.shade900,
      ],
    );

// Mixin for animated header gradient
mixin HeaderGradientAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _headerGradientController;
  late Animation<double> _headerGradientAnimation;

  void initializeHeaderGradientAnimation() {
    _headerGradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _headerGradientAnimation = Tween<double>(
      begin: 0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _headerGradientController,
      curve: Curves.easeInOut,
    ));

    // Endless animation loop
    _headerGradientController.repeat();
  }

  void disposeHeaderGradientAnimation() {
    _headerGradientController.dispose();
  }

  Animation<double> get headerGradientAnimation => _headerGradientAnimation;

  Widget buildAnimatedGradientContainer({
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _headerGradientAnimation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: getAnimatedHeaderGradient(_headerGradientAnimation.value),
          ),
          child: child,
        );
      },
    );
  }
}

LinearGradient getAnimatedHeaderGradient(double animationValue) {
  final colorSets = [
    [
      const Color.fromARGB(255, 107, 69, 173),
      Colors.deepPurple.shade900,
    ],
    [
      const Color.fromARGB(255, 120, 75, 190),
      const Color.fromARGB(255, 67, 56, 202),
    ],
    [
      const Color.fromARGB(255, 94, 84, 142),
      const Color.fromARGB(255, 70, 40, 205),
    ],
    [
      const Color.fromARGB(255, 81, 45, 168),
      const Color.fromARGB(255, 74, 20, 140),
    ],
  ];

  final value = animationValue;
  final index = value.floor() % colorSets.length;
  final nextIndex = (index + 1) % colorSets.length;
  final t = value - value.floor();

  return LinearGradient(
    colors: [
      Color.lerp(colorSets[index][0], colorSets[nextIndex][0], t)!,
      Color.lerp(colorSets[index][1], colorSets[nextIndex][1], t)!,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

IconData getIconForCollectionType(String type) {
  switch (type) {
    case 'Record':
      return Icons.album_outlined;
    case 'Stamp':
      return Icons.local_post_office_outlined;
    case 'Coin':
      return Icons.monetization_on_outlined;
    case 'Book':
      return Icons.menu_book_outlined;
    case 'Painting':
      return Icons.palette_outlined;
    case 'Comic Book':
      return Icons.auto_stories_outlined;
    case 'Vintage Posters':
      return Icons.image_outlined;
    case 'Diğer':
      return Icons.category_outlined;
    default:
      return Icons.category_outlined;
  }
}

Color getColorForCollectionType(String type) {
  switch (type) {
    case 'Record':
      return Colors.purple;
    case 'Stamp':
      return Colors.blue;
    case 'Coin':
      return Colors.amber;
    case 'Book':
      return Colors.green;
    case 'Painting':
      return Colors.orange;
    case 'Comic Book':
      return Colors.red;
    case 'Vintage Posters':
      return Colors.teal;
    default:
      return Colors.deepPurple;
  }
}

Widget buildEmptyState({
  required IconData icon,
  required String title,
  String? subtitle,
}) {
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
            icon,
            size: 64,
            color: Colors.deepPurple.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        subtitle != null ? const SizedBox(height: 8) : const SizedBox.shrink(),
        Text(
          subtitle ?? "",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

Widget buildPrimaryCard({
  required IconData icon,
  required String title,
  required String value,
  EdgeInsets? margin,
  EdgeInsets? padding,
}) {
  return Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(20),
    margin: margin ?? const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      gradient: projectLinearGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.deepPurple.withValues(alpha: 0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Future<void> showPhotoDialog(
  BuildContext context,
  List<String> imageUrls, {
  int initialIndex = 0,
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = imageUrls[index];
                  return PhotoView(
                    imageProvider: imageUrl.startsWith('http')
                        ? NetworkImage(imageUrl)
                        : FileImage(File(imageUrl)) as ImageProvider,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    loadingBuilder: (context, event) => Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                (event.expectedTotalBytes ?? 1),
                      ),
                    ),
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Failed to load image",
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildSearchWidget({
  required TextEditingController controller,
  required Function(String) onChanged,
  required VoidCallback onClear,
  String hintText = "Search...",
  EdgeInsets? padding,
}) {
  return Padding(
    padding: padding ?? const EdgeInsets.all(16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.text.isNotEmpty
              ? Colors.deepPurple.withValues(alpha: 0.5)
              : Colors.grey[300]!,
          width: controller.text.isNotEmpty ? 2 : 1,
        ),
        boxShadow: controller.text.isNotEmpty
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: controller.text.isNotEmpty
                ? Colors.deepPurple
                : Colors.grey[400],
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[600],
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    ),
  );
}

Widget buildActionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  bool isSelected = false,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.deepPurple : Colors.deepPurple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.deepPurple : Colors.deepPurple,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
