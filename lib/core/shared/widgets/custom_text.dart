import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final bool hasGlow;
  final bool hasShadow;
  final Color? glowColor;

  const CustomText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.hasGlow = false,
    this.hasShadow = true,
    this.glowColor,
  });

  const CustomText.title({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.hasGlow = true,
    this.glowColor,
  })  : fontSize = 32,
        fontWeight = FontWeight.bold,
        hasShadow = true;

  const CustomText.subtitle({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.hasGlow = false,
    this.glowColor,
  })  : fontSize = 24,
        fontWeight = FontWeight.w600,
        hasShadow = true;

  const CustomText.body({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.hasGlow = false,
    this.glowColor,
    this.fontWeight,
  })  : fontSize = 18,
        hasShadow = false;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.textPrimary;
    final effectiveGlowColor = glowColor ?? AppColors.accent;

    List<Shadow> shadows = [];
    
    if (hasShadow) {
      shadows.add(
        const Shadow(
          offset: Offset(2, 2),
          blurRadius: 4,
          color: AppColors.shadowColor,
        ),
      );
    }

    if (hasGlow) {
      shadows.addAll([
        Shadow(
          offset: const Offset(0, 0),
          blurRadius: 10,
          color: effectiveGlowColor.withOpacity(0.5),
        ),
        Shadow(
          offset: const Offset(0, 0),
          blurRadius: 20,
          color: effectiveGlowColor.withOpacity(0.3),
        ),
      ]);
    }

    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: textColor,
        shadows: shadows,
      ),
    );
  }
}