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
                isLoading: widget.isLoading ?? false,
                onPressed: () async {
                  if (widget.onPressed is Future<void> Function()) {
                    await widget.onPressed();
                  } else if (widget.onPressed is VoidCallback) {
                    widget.onPressed();
                  }
                },
                buttonText: widget.buttonText ?? '',
                icon: widget.buttonIcon ?? Icons.check,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Ekran boyutuna göre değerleri hesapla
              final screenWidth = constraints.maxWidth;
              final isSmallScreen = screenWidth < 360;
              final isMediumScreen = screenWidth < 400;

              // Responsive değerler
              final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
              final iconSize = isSmallScreen ? 20.0 : 24.0;
              final iconPadding = isSmallScreen ? 8.0 : 12.0;
              final titleFontSize = isSmallScreen
                  ? 20.0
                  : isMediumScreen
                      ? 22.0
                      : 24.0;
              final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
              final spaceBetween = isSmallScreen ? 12.0 : 16.0;
              final topMargin = isSmallScreen ? 4.0 : 8.0;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                    horizontalPadding, 5, horizontalPadding, 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: topMargin),
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.headerIcon,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(width: spaceBetween),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.poppins(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: isSmallScreen ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isSmallScreen ? 2 : 4),
                          Text(
                            widget.subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: subtitleFontSize,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.3,
                            ),
                            maxLines: isSmallScreen ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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
