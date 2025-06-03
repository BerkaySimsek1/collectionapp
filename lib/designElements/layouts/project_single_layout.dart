import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectSingleLayout extends StatefulWidget {
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
  State<ProjectSingleLayout> createState() => _ProjectSingleLayoutState();
}

class _ProjectSingleLayoutState extends State<ProjectSingleLayout>
    with TickerProviderStateMixin, HeaderGradientAnimationMixin {
  @override
  void initState() {
    super.initState();
    initializeHeaderGradientAnimation();
  }

  @override
  void dispose() {
    disposeHeaderGradientAnimation();
    super.dispose();
  }

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
        bottomNavigationBar: (widget.onPressed != null &&
                widget.buttonText != null &&
                widget.buttonIcon != null)
            ? buildBottomButton(
                isLoading: widget.isLoading,
                onPressed: () async {
                  if (widget.onPressed is Future<void> Function()) {
                    await widget.onPressed();
                  } else if (widget.onPressed is VoidCallback) {
                    widget.onPressed();
                  }
                },
                buttonText: widget.buttonText!,
                icon: widget.buttonIcon!,
              )
            : null,
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Positioned(
      top: 0,
      bottom: 40,
      left: 0,
      right: 0,
      child: buildAnimatedGradientContainer(
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
                    widget.headerIcon,
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
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7)),
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
      top: widget.headerHeight ?? 250,
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
          child: widget.body,
        ),
      ),
    );
  }
}
