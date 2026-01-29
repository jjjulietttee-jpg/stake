import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/custom_elevated_button.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Memory Games',
      subtitle: 'Premium gaming experience awaits you',
      description: 'Dive into the world of exciting games with amazing rewards and achievements',
      icon: Icons.games,
    ),
    OnboardingPage(
      title: 'Play and Win',
      subtitle: 'Multiple exciting games',
      description: 'Puzzles, arcade games, strategy games and much more in one app',
      icon: Icons.sports_esports,
    ),
    OnboardingPage(
      title: 'Start Right Now',
      subtitle: 'Your adventure begins here',
      description: 'Create your profile and get a welcome bonus for registration',
      icon: Icons.rocket_launch,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final storageService = getIt<StorageService>();
    await storageService.setOnboardingCompleted(true);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDark,
              AppColors.secondaryDark,
              AppColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: const CustomText.body(
                      text: 'Skip',
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with glow effect
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.3),
                                  AppColors.accent.withValues(alpha: 0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Icon(
                              page.icon,
                              size: 60,
                              color: AppColors.accent,
                              shadows: [
                                Shadow(
                                  color: AppColors.accent.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Title
                          CustomText.title(
                            text: page.title,
                            textAlign: TextAlign.center,
                            hasGlow: true,
                          ),
                          const SizedBox(height: 16),
                          // Subtitle
                          CustomText.subtitle(
                            text: page.subtitle,
                            textAlign: TextAlign.center,
                            color: AppColors.accent,
                          ),
                          const SizedBox(height: 24),
                          // Description
                          CustomText.body(
                            text: page.description,
                            textAlign: TextAlign.center,
                            color: AppColors.textPrimary.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.accent
                          : AppColors.accent.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: _currentPage == index
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Next button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: CustomElevatedButton(
                  text: _currentPage == _pages.length - 1 ? 'Start' : 'Next',
                  backgroundColor: AppColors.accent,
                  textColor: AppColors.primaryDark,
                  onPressed: _nextPage,
                  icon: _currentPage == _pages.length - 1
                      ? Icons.rocket_launch
                      : Icons.arrow_forward,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}