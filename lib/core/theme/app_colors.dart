import 'package:flutter/material.dart';

/// Paleta de cores do MedConnect.
///
/// Espelha as variáveis CSS do projeto original (`css/style.css`):
/// `--primary`, `--bg`, `--text-dark`, `--text-gray`, `--green-light`, etc.
abstract final class AppColors {
  // Identidade principal
  static const Color primary = Color(0xFF009879);
  static const Color primaryDark = Color(0xFF089277);

  // Fundo e superfícies
  static const Color background = Color(0xFFD1D1D6);
  static const Color surface = Color(0xFFFFFFFF);

  // Texto
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF7A7A7A);

  // Tons de apoio (tags, avatares, chips)
  static const Color greenLight = Color(0xFFE6F8F5);
  static const Color greenSoft = Color(0xFFC4E9D4);
  static const Color chipLavender = Color(0xFFD8DBFF);
  static const Color star = Color(0xFFFFB300);

  // Status das consultas (badges do projeto original)
  static const Color statusConfirmed = Color(0xFF009879);
  static const Color statusConfirmedBg = Color(0xFFE6F8F5);
  static const Color statusPending = Color(0xFFB45309);
  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusDone = Color(0xFF4338CA);
  static const Color statusDoneBg = Color(0xFFE0E7FF);
  static const Color statusCanceled = Color(0xFFB91C1C);
  static const Color statusCanceledBg = Color(0xFFFEE2E2);

  // Avatares coloridos (avatar-green / orange / purple)
  static const Color avatarGreen = Color(0xFF009879);
  static const Color avatarOrange = Color(0xFFF59E0B);
  static const Color avatarPurple = Color(0xFF8B5CF6);
}
