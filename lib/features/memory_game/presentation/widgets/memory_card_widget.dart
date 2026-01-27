import 'package:flutter/material.dart';
import '../../domain/entities/memory_card.dart';
import '../../../../core/theme/app_theme.dart';

class MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final bool isEnabled;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only animate if the flip state actually changed
    if (widget.card.isFlipped != oldWidget.card.isFlipped || 
        widget.card.isMatched != oldWidget.card.isMatched) {
      
      final shouldShowFront = widget.card.isFlipped || widget.card.isMatched;
      final wasShowingFront = oldWidget.card.isFlipped || oldWidget.card.isMatched;
      
      if (shouldShowFront && !wasShowingFront) {
        print('🎴 Card ${widget.card.id}: Flipping to FRONT (showing icon)');
        _controller.forward();
      } else if (!shouldShowFront && wasShowingFront) {
        print('🎴 Card ${widget.card.id}: Flipping to BACK (hiding icon)');
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('🎴 Card ${widget.card.id} tapped! isEnabled: ${widget.isEnabled}, isFlipped: ${widget.card.isFlipped}, isMatched: ${widget.card.isMatched}');
        if (widget.isEnabled) {
          widget.onTap();
        }
      },
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value >= 0.5;
          final shouldShowIcon = widget.card.isFlipped || widget.card.isMatched;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: (isShowingFront && shouldShowIcon) ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.card.isMatched
              ? LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.8),
                    AppColors.accent.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    AppColors.buttonRed.withValues(alpha: 0.8),
                    AppColors.buttonRed.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.card.isMatched ? AppColors.accent : AppColors.buttonRed,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.card.isMatched ? AppColors.accent : AppColors.buttonRed)
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            widget.card.icon,
            size: 32,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground,
            AppColors.secondaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.help_outline,
          size: 32,
          color: AppColors.textPrimary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}