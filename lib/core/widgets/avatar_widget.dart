import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vmeet/core/theme/theme.dart';

class VMeetAvatar extends StatelessWidget {
  final int avatarIndex;
  final String name;
  final double size;
  final bool isSelected;

  // Same curated gradients to guarantee absolute visual harmony across screens
  static const List<List<Color>> avatarGradients = [
    [Color(0xFFC7D2FE), Color(0xFF818CF8)], // Lavender to Periwinkle
    [Color(0xFFFCA5A5), Color(0xFFF472B6)], // Dusty Rose to Warm Pink
    [Color(0xFFA7F3D0), Color(0xFF0D9488)], // Soft Sage to Muted Teal
    [Color(0xFFFDE68A), Color(0xFFFDBA74)], // Champagne Gold to Soft Apricot
    [Color(0xFFE9D5FF), Color(0xFFC084FC)], // Dusky Violet to Lilac
    [Color(0xFFBAE6FD), Color(0xFF38BDF8)], // Muted Sky to Soft Blue
  ];

  const VMeetAvatar({
    super.key,
    required this.avatarIndex,
    required this.name,
    this.size = 50.0,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Graceful boundary index protection
    final safeIndex = (avatarIndex >= 0 && avatarIndex < avatarGradients.length)
        ? avatarIndex
        : 0;
    
    final gradients = avatarGradients[safeIndex];
    final bool hasName = name.trim().isNotEmpty;
    final initial = hasName ? name.trim()[0].toUpperCase() : "";

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradients,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: isSelected
            ? Border.all(color: Colors.white, width: 3)
            : Border.all(color: VMeetTheme.border.withAlpha(80), width: 1.2),
        boxShadow: isSelected
            ? VMeetTheme.glowShadow(gradients[0], radius: 10)
            : null,
      ),
      child: Center(
        child: hasName
            ? Text(
                initial,
                style: GoogleFonts.outfit(
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(0.5, 1.5),
                      blurRadius: 2,
                    ),
                  ],
                ),
              )
            : Icon(
                Icons.person_rounded,
                color: Colors.white.withAlpha(200),
                size: size * 0.5,
              ),
      ),
    );
  }
}
