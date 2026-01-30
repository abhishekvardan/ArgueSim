import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color obsidian = Color(0xFF0D0D0D);
  static const Color midnight = Color(0xFF141416);
  static const Color cardBg = Color(0xFF1C1C1E);
  static const Color glassWhite = Color(0x1AFFFFFF);
  
  // Neon Accents
  static const Color politeCyan = Color(0xFF00E5FF);
  static const Color sarcasticAmber = Color(0xFFFFAB40);
  static const Color philosophicalPurple = Color(0xFFD1C4E9);
  static const Color absurdGreen = Color(0xFFB2FF59);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF8E8E93);

  // Joy Mode (White Theme)
  static const Color joyBg = Color(0xFFFFFFFF);
  static const Color joyCard = Color(0xFFF2F2F7);
  static const Color joyTextPrimary = Color(0xFF000000);
  static const Color joyTextSecondary = Color(0xFF3C3C43);
}

class AppStyles {
  static BoxDecoration glassDecoration({Color? borderColor}) {
    return BoxDecoration(
      color: AppColors.glassWhite,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.1),
        width: 1,
      ),
    );
  }
}
