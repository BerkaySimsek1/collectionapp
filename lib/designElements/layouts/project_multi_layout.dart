import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectMultiLayout extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final TabController? tabController;

  const ProjectMultiLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    required this.tabs,
    required this.tabViews,
    this.tabController,
  });

  @override
  State<ProjectMultiLayout> createState() => _ProjectMultiLayoutState();
}

class _ProjectMultiLayoutState extends State<ProjectMultiLayout>
    with TickerProviderStateMixin, HeaderGradientAnimationMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController ??
        TabController(length: widget.tabs.length, vsync: this);

    // Header gradient animasyonunu başlat
    initializeHeaderGradientAnimation();
  }

  @override
  void dispose() {
    if (widget.tabController == null) {
      _tabController.dispose();
    }
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
        backgroundColor: Colors.grey[100],
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const ProjectIconButton(),
        ),
        body: Column(
          children: [
            // Header Section
            buildAnimatedGradientContainer(
              child: SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Ekran boyutuna göre değerleri hesapla
                    final screenWidth = constraints.maxWidth;
                    final isSmallScreen = screenWidth < 360;
                    final isMediumScreen = screenWidth < 400;

                    // Responsive değerler
                    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
                    final verticalPadding = isSmallScreen ? 36.0 : 48.0;
                    final iconSize = isSmallScreen ? 20.0 : 24.0;
                    final iconPadding = isSmallScreen ? 8.0 : 12.0;
                    final titleFontSize = isSmallScreen
                        ? 20.0
                        : isMediumScreen
                            ? 22.0
                            : 24.0;
                    final subtitleFontSize = isSmallScreen ? 14.0 : 16.0;
                    final spaceBetween = isSmallScreen ? 12.0 : 16.0;

                    return Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 12,
                          horizontalPadding, verticalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
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
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
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
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Tab Bar Section
            Transform.translate(
              offset: const Offset(0, -30),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final isSmallScreen = screenWidth < 360;
                  final horizontalMargin = isSmallScreen ? 16.0 : 24.0;
                  final tabFontSize = isSmallScreen ? 12.0 : 14.0;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      dividerHeight: 0,
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(4),
                      indicator: BoxDecoration(
                        gradient: projectLinearGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: GoogleFonts.poppins(
                        fontSize: tabFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontSize: tabFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: widget.tabs,
                    ),
                  );
                },
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.tabViews,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
