import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/shared/widgets/card_widget.dart';
import '../../../../core/theme/app_theme.dart';

class GameStatsWidget extends StatelessWidget {
  final int moves;
  final int matches;
  final int totalPairs;
  final int score;
  final Duration elapsedTime;

  const GameStatsWidget({
    super.key,
    required this.moves,
    required this.matches,
    required this.totalPairs,
    required this.score,
    required this.elapsedTime,
  });

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds % 60);
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CardWidget(
            child: Column(
              children: [
                const Icon(
                  Icons.timer,
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CustomText(
                    text: _formatTime(elapsedTime),
                    fontSize: 14,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CardWidget(
            child: Column(
              children: [
                const Icon(
                  Icons.touch_app,
                  color: AppColors.buttonRed,
                  size: 24,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CustomText(
                    text: moves.toString(),
                    fontSize: 14,
                    color: AppColors.buttonRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CardWidget(
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CustomText(
                    text: '$matches/$totalPairs',
                    fontSize: 14,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CardWidget(
            hasGlow: true,
            child: Column(
              children: [
                const Icon(
                  Icons.star,
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CustomText(
                    text: score.toString(),
                    fontSize: 14,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}