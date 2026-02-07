import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/custom_elevated_button.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/shared/widgets/card_widget.dart';
import '../../../../core/shared/widgets/custom_popup.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _userName;
  bool _showNamePopup = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final storageService = getIt<StorageService>();
    final savedName = await storageService.getPlayerName();
    
    if (mounted) {
      setState(() {
        _userName = savedName;
        _showNamePopup = savedName == null || savedName.isEmpty;
      });
      
      if (_showNamePopup) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _showNamePopup) {
            _showUserNameDialog();
          }
        });
      }
    }
  }

  void _showUserNameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomPopup(
        title: 'Welcome!',
        subtitle: 'What should we call you?',
        hintText: 'Enter your name',
        confirmButtonText: 'Save',
        onConfirm: (name) async {
          if (name.isNotEmpty) {
            final storageService = getIt<StorageService>();
            await storageService.setPlayerName(name);
            
            if (mounted) {
              setState(() {
                _userName = name;
                _showNamePopup = false;
              });
            }
          }
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primaryDark.withValues(alpha: 0.9),
              flexibleSpace: FlexibleSpaceBar(
                title: CustomText.subtitle(
                  text: _userName != null ? 'Hello, $_userName!' : 'Stake Game',
                  hasGlow: true,
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: [
                        AppColors.accent.withValues(alpha: 0.2),
                        AppColors.secondaryDark.withValues(alpha: 0.8),
                        AppColors.primaryDark,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.games,
                      size: 80,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(
                    Icons.settings,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/profile'),
                  icon: const Icon(
                    Icons.person,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const CustomText.title(
                    text: 'Stake Game',
                    textAlign: TextAlign.center,
                    hasGlow: true,
                  ),
                  const SizedBox(height: 12),
                  CustomText.body(
                    text: 'Train your memory with built-in memory training exercises',
                    textAlign: TextAlign.center,
                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 32),
                  CustomElevatedButton(
                    text: 'START TRAINING',
                    backgroundColor: AppColors.buttonRed,
                    height: 80,
                    icon: Icons.play_arrow,
                    onPressed: () => context.push('/game'),
                  ),
                  const SizedBox(height: 32),
                  const CustomText.subtitle(
                    text: 'Quick Access',
                    hasGlow: false,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CardWidget(
                          hasGlow: true,
                          onTap: () => context.push('/profile'),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person,
                                size: 48,
                                color: AppColors.accent,
                                shadows: [
                                  Shadow(
                                    color: AppColors.accent.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const CustomText.body(
                                text: 'Profile',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CardWidget(
                          hasGlow: true,
                          onTap: () => context.push('/achievements'),
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 48,
                                color: AppColors.accent,
                                shadows: [
                                  Shadow(
                                    color: AppColors.accent.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const CustomText.body(
                                text: 'Achievements',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CardWidget(
                          hasGlow: true,
                          onTap: () => context.push('/settings'),
                          child: Column(
                            children: [
                              Icon(
                                Icons.settings,
                                size: 48,
                                color: AppColors.accent,
                                shadows: [
                                  Shadow(
                                    color: AppColors.accent.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const CustomText.body(
                                text: 'Settings',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CardWidget(
                          hasGlow: true,
                          onTap: () => context.push('/daily-challenge'),
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 48,
                                color: AppColors.accent,
                                shadows: [
                                  Shadow(
                                    color: AppColors.accent.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const CustomText.body(
                                text: 'Daily Challenge',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  CustomElevatedButton(
                    text: _userName != null ? 'Change Name' : 'Set Name',
                    backgroundColor: AppColors.cardBackground,
                    onPressed: _showUserNameDialog,
                    icon: Icons.edit,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}