import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'custom_elevated_button.dart';
import 'custom_text.dart';

class CustomPopup extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? initialValue;
  final String confirmButtonText;
  final String? cancelButtonText;
  final Function(String) onConfirm;
  final VoidCallback? onCancel;
  final String? hintText;

  const CustomPopup({
    super.key,
    required this.title,
    this.subtitle,
    this.initialValue,
    this.confirmButtonText = 'Confirm',
    this.cancelButtonText,
    required this.onConfirm,
    this.onCancel,
    this.hintText,
  });

  @override
  State<CustomPopup> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onConfirm(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cardBackground,
                      AppColors.secondaryDark.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      offset: const Offset(0, 0),
                      blurRadius: 40,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText.title(
                      text: widget.title,
                      textAlign: TextAlign.center,
                      hasGlow: true,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 12),
                      CustomText.body(
                        text: widget.subtitle!,
                        textAlign: TextAlign.center,
                        color: AppColors.textPrimary.withValues(alpha: 0.8),
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextField(
                      controller: _controller,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText ?? 'Enter text...',
                        hintStyle: TextStyle(
                          color: AppColors.textPrimary.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: AppColors.primaryDark.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (widget.cancelButtonText != null) ...[
                          Expanded(
                            child: CustomElevatedButton(
                              text: widget.cancelButtonText!,
                              backgroundColor: AppColors.cardBackground,
                              onPressed: widget.onCancel,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: CustomElevatedButton(
                            text: widget.confirmButtonText,
                            backgroundColor: AppColors.accent,
                            textColor: AppColors.primaryDark,
                            onPressed: _handleConfirm,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}