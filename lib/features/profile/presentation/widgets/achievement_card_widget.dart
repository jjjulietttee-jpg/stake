import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/shared/widgets/card_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/achievement.dart';

class AchievementCardWidget extends StatefulWidget {
  final Achievement achievement;
  final bool showAnimation;

  const AchievementCardWidget({
    super.key,
    required this.achievement,
    this.showAnimation = true,
  });

  @override
  State<AchievementCardWidget> createState() => _AchievementCardWidgetState();
}

class _AchievementCardWidgetState extends State<AchievementCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    if (widget.achievement.isUnlocked && widget.showAnimation) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      hasGlow: widget.achievement.isUnlocked,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: widget.achievement.isUnlocked
                      ? [
                          widget.achievement.rarityColor.withValues(alpha: 0.3),
                          Colors.transparent,
                        ]
                      : [
                          AppColors.cardBackground.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                ),
                border: Border.all(
                  color: widget.achievement.isUnlocked
                      ? widget.achievement.rarityColor
                      : AppColors.textPrimary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: widget.achievement.isUnlocked && widget.showAnimation
                  ? AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Icon(
                              widget.achievement.icon,
                              size: 28,
                              color: widget.achievement.rarityColor,
                            ),
                          ),
                        );
                      },
                    )
                  : Icon(
                      widget.achievement.icon,
                      size: 28,
                      color: widget.achievement.isUnlocked
                          ? widget.achievement.rarityColor
                          : AppColors.textPrimary.withValues(alpha: 0.5),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText.body(
                          text: widget.achievement.title,
                          fontWeight: FontWeight.bold,
                          color: widget.achievement.isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.achievement.rarityColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.achievement.rarityColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: CustomText(
                          text: widget.achievement.rarityName,
                          fontSize: 10,
                          color: widget.achievement.rarityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: widget.achievement.description,
                    fontSize: 13,
                    color: widget.achievement.isUnlocked
                        ? AppColors.textPrimary.withValues(alpha: 0.8)
                        : AppColors.textPrimary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  if (widget.achievement.isUnlocked) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        CustomText(
                          text: '+${widget.achievement.xpReward} XP',
                          fontSize: 12,
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                        const Spacer(),
                        if (widget.achievement.unlockedAt != null)
                          CustomText(
                            text: _formatDate(widget.achievement.unlockedAt!),
                            fontSize: 10,
                            color: AppColors.textPrimary.withValues(alpha: 0.6),
                          ),
                      ],
                    ),
                  ] else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: '${widget.achievement.progressPercentage.toInt()}% Complete',
                              fontSize: 12,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                            CustomText(
                              text: '+${widget.achievement.xpReward} XP',
                              fontSize: 12,
                              color: AppColors.textPrimary.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: widget.achievement.progress,
                          backgroundColor: AppColors.cardBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.achievement.rarityColor.withValues(alpha: 0.8),
                          ),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              widget.achievement.isUnlocked ? Icons.check_circle : Icons.lock,
              color: widget.achievement.isUnlocked
                  ? AppColors.accent
                  : AppColors.textPrimary.withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}