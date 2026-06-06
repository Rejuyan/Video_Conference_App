import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vmeet/core/theme/theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final BorderSide? borderSide;
  final BoxBorder? customBorder;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? glowColor;
  final List<Color>? gradientColors;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.08,
    this.borderRadius = 24.0,
    this.borderSide,
    this.customBorder,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.glowColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glowColor != null
            ? VMeetTheme.glowShadow(glowColor!, radius: 16)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: customBorder ??
                  Border.all(
                    color: borderSide?.color ??
                        VMeetTheme.border.withAlpha(80),
                    width: borderSide?.width ?? 1.2,
                  ),
              gradient: LinearGradient(
                colors: gradientColors ??
                    [
                      Colors.white.withAlpha((255 * opacity * 1.5).round()),
                      Colors.white.withAlpha((255 * opacity * 0.4).round()),
                    ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
