import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fundo animado claro — gradiente levemente azulado com orbs coloridos
/// vivíssimos que se deslocam suavemente, criando a sensação de
/// "água/vidro/vivo" característica do Liquid Glass do iOS.
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
      duration: const Duration(seconds: 12),
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
    // Orbs mais contidos — não queremos ofuscar o fundo médio-claro
    final orbAlpha = night ? 0.22 : 0.28;
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
              // 1. Indigo/violet — cantão superior esquerdo
              Positioned(
                top: -140 + (t * 100),
                left: -80 + (t * 80),
                child: _Orb(
                  color: AppColors.accent3.withValues(alpha: orbAlpha),
                  size: 420,
                ),
              ),
              // 2. Sky blue — cantão inferior direito
              Positioned(
                bottom: -160 + (t * 80),
                right: -120 + (t * 100),
                child: _Orb(
                  color: AppColors.accent1.withValues(alpha: orbAlpha - 0.05),
                  size: 480,
                ),
              ),
              // 3. Teal (água) — centro-esquerda
              Positioned(
                top: screen.height * 0.3,
                left: screen.width * 0.15 - (t * 50),
                child: _Orb(
                  color: AppColors.accent4.withValues(alpha: orbAlpha - 0.06),
                  size: 340,
                ),
              ),
              // 4. Violeta — meio baixo
              Positioned(
                bottom: screen.height * 0.15,
                left: screen.width * 0.45 + (t * 30),
                child: _Orb(
                  color: AppColors.accent5.withValues(alpha: orbAlpha - 0.1),
                  size: 260,
                ),
              ),
              // 5. Cyan — highlight pequeno no topo
              Positioned(
                top: screen.height * 0.08 + (t * 40),
                right: screen.width * 0.2,
                child: _Orb(
                  color: AppColors.accent2.withValues(alpha: orbAlpha - 0.08),
                  size: 220,
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
