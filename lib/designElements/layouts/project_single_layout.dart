import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectSingleLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final Widget body;
  final double? headerHeight;
  // Bottom button parameters
  final bool? isLoading;
  final dynamic onPressed; // Future<void> Function() veya VoidCallback
  final String? buttonText;
  final IconData? buttonIcon;

  const ProjectSingleLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    required this.body,
    this.headerHeight,
    this.isLoading,
    this.onPressed,
    this.buttonText,
    this.buttonIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Klavyeyi kapat
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const ProjectIconButton(),
        ),
        body: Stack(
          children: [
            _buildGradientHeader(),
            _buildBodyContent(),
          ],
        ),
        bottomNavigationBar:
            (onPressed != null && buttonText != null && buttonIcon != null)
                ? _buildBottomButton(context)
                : null,
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
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
          onPressed: (isLoading == true)
              ? null
              : () async {
                  if (onPressed is Future<void> Function()) {
                    await onPressed();
                  } else if (onPressed is VoidCallback) {
                    onPressed();
                  }
                },
          icon: (isLoading == true)
              ? null
              : Icon(buttonIcon!, color: Colors.white),
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
                  buttonText!,
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

  Widget _buildGradientHeader() {
    return Positioned(
      top: 0,
      bottom: 40,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 107, 69, 173),
              Colors.deepPurple.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 5, 24, 80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    headerIcon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white..withValues(alpha: 0.7)),
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

  Widget _buildBodyContent() {
    return Positioned(
      bottom: -60,
      top: headerHeight ?? 250,
      left: 0,
      right: 0,
      child: Transform.translate(
        offset: const Offset(0, -60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: body,
        ),
      ),
    );
  }
}
