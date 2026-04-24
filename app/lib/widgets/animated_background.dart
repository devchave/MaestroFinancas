import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(sin(t * pi) * 0.5 - 0.5, -1),
              end: Alignment(cos(t * pi) * 0.5 + 0.5, 1),
              colors: [
                Color.lerp(const Color(0xFF0A0E1A), const Color(0xFF0D1B35), t)!,
                Color.lerp(const Color(0xFF0D1B2A), const Color(0xFF071020), t)!,
                Color.lerp(const Color(0xFF0A1628), const Color(0xFF120A2E), t)!,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Orb 1
              Positioned(
                top: -100 + (t * 80),
                left: -80 + (t * 60),
                child: _Orb(
                  color: AppColors.accent3.withValues(alpha: 0.15),
                  size: 350,
                ),
              ),
              // Orb 2
              Positioned(
                bottom: -120 + (t * 60),
                right: -100 + (t * 80),
                child: _Orb(
                  color: AppColors.accent1.withValues(alpha: 0.12),
                  size: 400,
                ),
              ),
              // Orb 3
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                left: MediaQuery.of(context).size.width * 0.3,
                child: _Orb(
                  color: AppColors.accent2.withValues(alpha: 0.08),
                  size: 250,
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
