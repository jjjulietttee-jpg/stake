import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/shared/widgets/card_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../../../core/utils/link_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primaryDark.withValues(alpha: 0.9),
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: const CustomText.subtitle(
                    text: 'Settings',
                    hasGlow: true,
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.0,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.2),
                          AppColors.secondaryDark.withValues(alpha: 0.8),
                          AppColors.primaryDark,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const CustomText.subtitle(
                      text: 'About',
                      hasGlow: true,
                    ),
                    const SizedBox(height: 16),

                    _SettingsTile(
                      icon: Icons.info_outline,
                      title: 'About Stake Game',
                      subtitle: 'Learn more about the app',
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms',
                      onTap: () {
                        _showTermsDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      onTap: () {
                        final url = LinkHelper.encode(
                          getIt<RemoteConfigService>().rawEndpoint,
                        );
                        context.push('/content?url=$url');
                      },
                    ),
                    const SizedBox(height: 32),
                    const CustomText.subtitle(
                      text: 'Support',
                      hasGlow: true,
                    ),
                    const SizedBox(height: 16),

                    _SettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & FAQ',
                      subtitle: 'Get answers to common questions',
                      onTap: () {
                        _showHelpDialog(context);
                      },
                    ),
                    const SizedBox(height: 32),
                    const CustomText.subtitle(
                      text: 'Data',
                      hasGlow: true,
                    ),
                    const SizedBox(height: 16),

                    _SettingsTile(
                      icon: Icons.delete_outline,
                      title: 'Reset Progress',
                      subtitle: 'Clear all game data',
                      iconColor: AppColors.buttonRed,
                      onTap: () {
                        _showResetConfirmation(context);
                      },
                    ),
                    const SizedBox(height: 48),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.psychology,
                            size: 48,
                            color: AppColors.accent.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          CustomText.body(
                            text: 'Stake Game',
                            color: AppColors.textPrimary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 4),
                          CustomText.body(
                            text: '© 2026 Stake Game',
                            color: AppColors.textPrimary.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const CustomText.subtitle(
          text: 'About Stake Game',
          hasGlow: true,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText.body(
              text: 'Stake Game is a cognitive training application designed to help improve your memory and mental agility through engaging exercises and challenges.',
            ),
            const SizedBox(height: 16),
            CustomText.body(
              text: 'Features:',
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
            const SizedBox(height: 8),
            const CustomText.body(text: '• Memory card matching games'),
            const CustomText.body(text: '• Number puzzles'),
            const CustomText.body(text: '• Daily challenges'),
            const CustomText.body(text: '• Achievement system'),
            const CustomText.body(text: '• Progress tracking'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText.body(
              text: 'Close',
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const CustomText.subtitle(
          text: 'Terms of Service',
          hasGlow: true,
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText.body(
                text: 'By using Stake Game, you agree to the following terms:',
              ),
              SizedBox(height: 16),
              CustomText.body(
                text: '1. This app is intended for personal entertainment and cognitive training purposes only.',
              ),
              SizedBox(height: 8),
              CustomText.body(
                text: '2. All game progress is stored locally on your device.',
              ),
              SizedBox(height: 8),
              CustomText.body(
                text: '3. We reserve the right to update these terms at any time.',
              ),
              SizedBox(height: 8),
              CustomText.body(
                text: '4. The app is provided "as is" without warranties of any kind.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText.body(
              text: 'Close',
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const CustomText.subtitle(
          text: 'Help & FAQ',
          hasGlow: true,
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText.body(
                text: 'Q: How do I play Stake Game?',
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 4),
              CustomText.body(
                text: 'A: Tap cards to flip them and find matching pairs. Remember card positions to complete the game faster!',
              ),
              SizedBox(height: 16),
              CustomText.body(
                text: 'Q: How do achievements work?',
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 4),
              CustomText.body(
                text: 'A: Complete various challenges to unlock achievements and earn XP. View your progress in the Profile section.',
              ),
              SizedBox(height: 16),
              CustomText.body(
                text: 'Q: What are daily challenges?',
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 4),
              CustomText.body(
                text: 'A: Daily challenges offer unique puzzles each day. Complete them to maintain your streak and earn bonus rewards!',
              ),
              SizedBox(height: 16),
              CustomText.body(
                text: 'Q: How do I reset my progress?',
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 4),
              CustomText.body(
                text: 'A: Go to Settings > Data > Reset Progress. Note: This action cannot be undone.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText.body(
              text: 'Close',
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const CustomText.subtitle(
          text: 'Reset Progress',
          color: AppColors.buttonRed,
        ),
        content: const CustomText.body(
          text: 'Are you sure you want to reset all your progress? This action cannot be undone. All achievements, scores, and settings will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomText.body(
              text: 'Cancel',
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () async {
              await getIt<StorageService>().clearAll();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All progress has been reset'),
                    backgroundColor: AppColors.buttonRed,
                  ),
                );
                context.go('/onboarding');
              }
            },
            child: const CustomText.body(
              text: 'Reset',
              color: AppColors.buttonRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.accent).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.body(
                  text: title,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: subtitle,
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ],
            ),
          ),
          trailing ??
              Icon(
                Icons.chevron_right,
                color: AppColors.textPrimary.withValues(alpha: 0.5),
              ),
        ],
      ),
    );
  }
}
