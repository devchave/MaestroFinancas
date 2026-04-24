import 'dart:ui';
import 'package:flutter/material.dart';

/// Primitivo "Liquid Glass" — estilo Clear/Colorful do iOS/macOS 26.
///
/// Afinado para **tema claro**: borda mais sutil, rim menos brilhante,
/// highlight mais suave, cor de tint visível sem dominar.
///
/// Camadas:
///   1. BackdropFilter         — borra o fundo claro
///   2. Color bleed (opcional) — tinta ambiente
///   3. Highlight interno      — brilho difuso do topo
///   4. Conteúdo (child)
///   5. Rim especular no topo  — fina linha clara
///   6. Borda translúcida      — contorno sutil
class LiquidGlass extends StatelessWidget {
  final Widget child;

  /// Cor que "vaza" pelo vidro. Null = vidro clear (neutro branco).
  final Color? tint;

  /// Intensidade do tint.
  final double tintStrength;

  final double radius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final bool showRim;
  final bool showHighlight;
  final double borderStrength;

  const LiquidGlass({
    super.key,
    required this.child,
    this.tint,
    this.tintStrength = 1.0,
    this.radius = 20,
    this.padding,
    this.blur = 20,
    this.showRim = true,
    this.showHighlight = true,
    this.borderStrength = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);

    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Stack(
          children: [
            // ── 1. Base: ou tint, ou vidro clear branco ────────────────
            if (tint != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.35),
                        radius: 1.3,
                        colors: [
                          tint!.withValues(alpha: 0.55 * tintStrength),
                          tint!.withValues(alpha: 0.25 * tintStrength),
                          tint!.withValues(alpha: 0.08 * tintStrength),
                        ],
                        stops: const [0, 0.6, 1],
                      ),
                    ),
                  ),
                ),
              )
            else
              // Vidro clear: branco translúcido
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),

            // ── 2. Highlight interno (luz de cima, sutil no claro) ────
            if (showHighlight)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.45),
                          Colors.white.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.4, 1],
                      ),
                    ),
                  ),
                ),
              ),

            // ── 3. Conteúdo ────────────────────────────────────────────
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),

            // ── 4. Rim especular — linha clara no topo ────────────────
            if (showRim)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.85),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0, 0.5, 1],
                      ),
                    ),
                  ),
                ),
              ),

            // ── 5. Borda translúcida (contorno sutil) ─────────────────
            if (borderStrength > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: br,
                      border: Border.all(
                        color: Colors.white
                            .withValues(alpha: 0.7 * borderStrength),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LiquidShimmer extends StatelessWidget {
  final double intensity;
  const LiquidShimmer({super.key, this.intensity = 0.08});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: intensity),
              Colors.transparent,
              Colors.transparent,
              Colors.white.withValues(alpha: intensity * 0.5),
            ],
            stops: const [0, 0.35, 0.7, 1],
          ),
        ),
      ),
    );
  }
}
