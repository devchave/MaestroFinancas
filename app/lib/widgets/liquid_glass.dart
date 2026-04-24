import 'dart:ui';
import 'package:flutter/material.dart';

/// Primitivo "Liquid Glass" — inspirado no design Clear/Colorful
/// do iOS/macOS 26.
///
/// Empilha 5 camadas para compor o efeito:
///   1. BackdropFilter         — borra o que está atrás
///   2. Color bleed            — tinta ambiente que "sangra" pelo vidro
///   3. Inner highlight        — brilho suave no topo (luz refletindo)
///   4. Conteúdo (child)
///   5. Rim (borda branca translúcida + linha especular no topo)
///
/// Uso:
///   LiquidGlass(
///     tint: Colors.cyan,
///     radius: 22,
///     padding: EdgeInsets.all(16),
///     child: Text('Olá'),
///   );
class LiquidGlass extends StatelessWidget {
  final Widget child;

  /// Cor que "vaza" por baixo do vidro (ambient tint).
  /// Null = vidro neutro.
  final Color? tint;

  /// Intensidade do tint (0.0-1.0). Default 1.0 = cor vívida.
  final double tintStrength;

  /// Raio de canto.
  final double radius;

  /// Padding interno.
  final EdgeInsetsGeometry? padding;

  /// Blur do fundo — maior = mais vidro fosco.
  final double blur;

  /// Mostra rim no topo (linha de luz fina).
  final bool showRim;

  /// Mostra highlight interno (brilho difuso).
  final bool showHighlight;

  /// Força da borda translúcida (0 = sem borda).
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
            // ── 1. Camada base: tint de cor (ambient bleed) ──────────────
            if (tint != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.35),
                        radius: 1.3,
                        colors: [
                          tint!.withValues(alpha: 0.45 * tintStrength),
                          tint!.withValues(alpha: 0.18 * tintStrength),
                          tint!.withValues(alpha: 0.05 * tintStrength),
                        ],
                        stops: const [0, 0.6, 1],
                      ),
                    ),
                  ),
                ),
              )
            else
              // Sem tint: leve véu branco translúcido
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),

            // ── 2. Highlight interno difuso (luz ambiente de cima) ────────
            if (showHighlight)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.4, 1],
                      ),
                    ),
                  ),
                ),
              ),

            // ── 3. Conteúdo ────────────────────────────────────────────────
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),

            // ── 4. Rim — linha especular fina no topo ────────────────────
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
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0, 0.5, 1],
                      ),
                    ),
                  ),
                ),
              ),

            // ── 5. Borda translúcida (acabamento de vidro) ───────────────
            if (borderStrength > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: br,
                      border: Border.all(
                        color: Colors.white
                            .withValues(alpha: 0.22 * borderStrength),
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

/// Variação com um padrão "shimmer" diagonal — passa uma faixa de luz
/// sutil que reforça a sensação líquida em elementos maiores.
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
