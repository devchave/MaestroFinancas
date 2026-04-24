import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fundo animado do app — sensação de vidro/água/vivo.
/// Quatro orbs que se deslocam suavemente sobre um gradiente
/// deslizante azul profundo. À noite o fundo fica mais escuro.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final night = AppColors.isNight;
    final gradient = night
        ? AppColors.backgroundGradientNight
        : AppColors.backgroundGradient;
    // Orbs mais discretos à noite
    final orbAlpha = night ? 0.08 : 0.15;
    final screen = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(sin(t * pi) * 0.6 - 0.4, -1),
              end: Alignment(cos(t * pi) * 0.6 + 0.4, 1),
              colors: gradient,
            ),
          ),
          child: Stack(
            children: [
              // 1. Indigo — profundidade "vivo"
              Positioned(
                top: -120 + (t * 100),
                left: -80 + (t * 80),
                child: _Orb(
                  color: AppColors.accent3.withValues(alpha: orbAlpha),
                  size: 380,
                ),
              ),
              // 2. Sky blue — amplitude "céu"
              Positioned(
                bottom: -140 + (t * 80),
                right: -120 + (t * 100),
                child: _Orb(
                  color: AppColors.accent1.withValues(alpha: orbAlpha - 0.02),
                  size: 440,
                ),
              ),
              // 3. Teal / aqua — "água" (novo)
              Positioned(
                top: screen.height * 0.35,
                left: screen.width * 0.2 - (t * 50),
                child: _Orb(
                  color: AppColors.accent4.withValues(alpha: orbAlpha - 0.04),
                  size: 320,
                ),
              ),
              // 4. Cyan — highlight pequeno e mais vivo
              Positioned(
                top: screen.height * 0.08 + (t * 40),
                right: screen.width * 0.18,
                child: _Orb(
                  color: AppColors.accent2.withValues(alpha: orbAlpha - 0.02),
                  size: 200,
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;
  const _Orb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      );
}
