import 'package:collectionapp/common_ui_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final Widget body;
  final Widget? bottomNavigationBar;
  final double headerHeight;

  const ProjectLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    required this.body,
    this.bottomNavigationBar,
    this.headerHeight = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const ProjectBackButton(),
      ),
      body: Stack(
        children: [
          _buildGradientHeader(),
          _buildBodyContent(),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
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
              Colors.deepPurple.shade400,
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
      top: headerHeight,
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
