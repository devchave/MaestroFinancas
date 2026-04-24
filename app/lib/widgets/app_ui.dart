import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'liquid_glass.dart';

// ════════════════════════════════════════════════════════════════════════════
// AppButton — botão unificado (primary / secondary / ghost)
// ════════════════════════════════════════════════════════════════════════════

enum AppButtonVariant { primary, secondary, ghost }

enum AppButtonSize { compact, regular, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final (padH, padV, fontSize) = switch (size) {
      AppButtonSize.compact => (AppSpacing.md, 10.0, 13.0),
      AppButtonSize.regular => (AppSpacing.lg, 14.0, 14.0),
      AppButtonSize.large   => (AppSpacing.xl, 18.0, 16.0),
    };

    final Widget inner = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: fontSize + 4, color: _fgColor()),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label,
                  style: AppTypo.body.copyWith(
                    color: _fgColor(),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  )),
            ],
          );

    final padding = EdgeInsets.symmetric(horizontal: padH, vertical: padV);

    switch (variant) {
      case AppButtonVariant.primary:
        return Opacity(
          opacity: disabled ? 0.5 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.accentGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.accent1.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: disabled ? null : onPressed,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(padding: padding, child: Center(child: inner)),
              ),
            ),
          ),
        );

      case AppButtonVariant.secondary:
        return Opacity(
          opacity: disabled ? 0.5 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: disabled ? null : onPressed,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(padding: padding, child: Center(child: inner)),
              ),
            ),
          ),
        );

      case AppButtonVariant.ghost:
        return Opacity(
          opacity: disabled ? 0.5 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: disabled ? null : onPressed,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(padding: padding, child: Center(child: inner)),
            ),
          ),
        );
    }
  }

  Color _fgColor() => switch (variant) {
        AppButtonVariant.primary => Colors.white,
        AppButtonVariant.secondary => AppColors.textPrimary,
        AppButtonVariant.ghost => AppColors.accent2,
      };
}

// ════════════════════════════════════════════════════════════════════════════
// AppCard — card Liquid Glass
//
// Construído sobre LiquidGlass. Aceita opcionalmente um `accentColor`
// para dar uma tinta ambiente (ex: card de tool placeholder tingido
// com a cor da ferramenta).
// ════════════════════════════════════════════════════════════════════════════

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? accentColor;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppRadius.lg;

    Widget card = LiquidGlass(
      tint: accentColor,
      tintStrength: accentColor != null ? 0.5 : 0,
      radius: r,
      blur: 14,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r),
          child: card,
        ),
      );
    }
    return card;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// AppIconBadge — ícone Liquid Glass / Clear Colorful
//
// O ícone aparece "colorido através do vidro": há uma tinta ambiente
// (color bleed) por baixo da camada frost; o ícone em si é desenhado
// na cor da categoria sobre o vidro. Rim de luz no topo e borda
// translúcida dão a sensação de squircle de vidro do iOS 26.
// ════════════════════════════════════════════════════════════════════════════

class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;

  const AppIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 36,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow externo colorido (halo)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: size * 0.45,
                  spreadRadius: -size * 0.15,
                  offset: Offset(0, size * 0.08),
                ),
              ],
            ),
          ),
          // Liquid glass + ícone
          LiquidGlass(
            tint: color,
            tintStrength: 1.1,
            radius: radius,
            blur: 18,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: iconSize ?? size * 0.5,
                  shadows: [
                    Shadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// StatusChip — chip colorido para valores, filtros, tags
// ════════════════════════════════════════════════════════════════════════════

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final int? count;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.selected = true,
    this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? color.withValues(alpha: 0.18)
        : AppColors.glassWhite;
    final border = selected ? color : AppColors.glassBorder;
    final fg = selected ? color : AppColors.textSecondary;

    Widget inner = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          label,
          style: AppTypo.bodySmall.copyWith(
            color: fg,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs + 2, vertical: 1),
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '$count',
              style: AppTypo.labelSmall.copyWith(color: fg),
            ),
          ),
        ],
      ],
    );

    final chip = Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: border, width: selected ? 1.2 : 1),
      ),
      child: inner,
    );

    return onTap == null
        ? chip
        : GestureDetector(onTap: onTap, child: chip);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// AppTextField — input padronizado
// ════════════════════════════════════════════════════════════════════════════

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  final String? hintText;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.hintText,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      textAlign: textAlign,
      autofocus: autofocus,
      style: AppTypo.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: AppTypo.bodySmall,
        hintStyle: AppTypo.bodySmall.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.5)),
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: AppColors.textSecondary, size: 19),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.glassWhite,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.smd + 2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              const BorderSide(color: AppColors.accent1, width: 1.5),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SectionLabel — rótulo pequeno uppercase para seções
// ════════════════════════════════════════════════════════════════════════════

class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final title = Text(text, style: AppTypo.label);
    if (trailing == null) return title;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [title, trailing!],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// AppDivider — divisor horizontal sutil
// ════════════════════════════════════════════════════════════════════════════

class AppDivider extends StatelessWidget {
  final double? indent;
  const AppDivider({super.key, this.indent});

  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 1,
        color: AppColors.glassBorder.withValues(alpha: 0.5),
        indent: indent,
        endIndent: indent,
      );
}
