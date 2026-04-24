import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Escala tipográfica unificada do app (fonte Inter).
///
/// Uso:
///   Text('Título', style: AppTypo.headline)
///   Text('Descrição', style: AppTypo.body)
///
/// Para variações de cor rápidas:
///   Text('...', style: AppTypo.body.copyWith(color: AppColors.accent1))
class AppTypo {
  AppTypo._();

  // ─── Display: telas hero, landing ────────────────────────────────────────
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.15,
        letterSpacing: -1,
      );

  // ─── Headline: título principal de tela ──────────────────────────────────
  static TextStyle get headline => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: -0.4,
      );

  // ─── Title: título de card / seção forte ─────────────────────────────────
  static TextStyle get title => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // ─── Title small: subtítulos, headers de app bar ─────────────────────────
  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // ─── Body large: parágrafos de destaque ──────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.55,
      );

  // ─── Body: texto padrão ───────────────────────────────────────────────────
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // ─── Body small: texto auxiliar ──────────────────────────────────────────
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.45,
      );

  // ─── Label: rótulos de seção (maiúsculas / destaque) ────────────────────
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  // ─── Label small: tags, badges, pills ────────────────────────────────────
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  // ─── Caption: metadados (data, versão) ──────────────────────────────────
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      );

  // ─── Number large: valor monetário principal ─────────────────────────────
  static TextStyle get numberLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.8,
      );

  // ─── Number: valores em cards de stats ───────────────────────────────────
  static TextStyle get number => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  // ─── Mono: versão, IDs técnicos ──────────────────────────────────────────
  static TextStyle get mono => GoogleFonts.robotoMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
        letterSpacing: 0.2,
      );
}
