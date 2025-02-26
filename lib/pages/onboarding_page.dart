import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const OnboardingPage({super.key, required this.showLoginPage});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [
              _buildOnboardingPage(
                title: "Welcome to Collectio",
                subtitle:
                    "Your ultimate platform for collectors and enthusiasts",
                image: Icons.collections_bookmark,
                gradient: [
                  Colors.deepPurple.shade200,
                  Colors.deepPurple.shade400,
                ],
              ),
              _buildOnboardingPage(
                title: "Join Communities",
                subtitle:
                    "Connect with fellow collectors, share experiences and grow together",
                image: Icons.group,
                gradient: [
                  Colors.blue.shade200,
                  Colors.blue.shade400,
                ],
              ),
              _buildOnboardingPage(
                title: "Trade & Auction",
                subtitle:
                    "Buy, sell and auction your collectibles in a secure environment",
                image: Icons.gavel,
                gradient: [
                  Colors.purple.shade200,
                  Colors.purple.shade400,
                ],
              ),
            ],
          ),

          // Dot Indicators & Buttons
          Container(
            alignment: const Alignment(0, 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dot Indicators
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.5),
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 12,
                  ),
                ),
                const SizedBox(height: 32),
                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button
                      TextButton(
                        onPressed: widget.showLoginPage,
                        child: Text(
                          "Skip",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Next/Get Started Button
                      ElevatedButton(
                        onPressed: isLastPage
                            ? widget.showLoginPage
                            : () {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          isLastPage ? "Get Started" : "Next",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String subtitle,
    required IconData image,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    image,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              // Title
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Subtitle
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
