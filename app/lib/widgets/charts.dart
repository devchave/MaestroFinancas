import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

// ─── Sparkline ────────────────────────────────────────────────────────────────

class SparklineChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;

  const SparklineChart({
    super.key,
    required this.data,
    required this.color,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return SizedBox(height: height);
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(data: data, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  const _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = maxV == minV ? 1.0 : maxV - minV;
    const vPad = 0.1;

    double px(int i) => i / (data.length - 1) * size.width;
    double py(double v) =>
        size.height -
        ((v - minV) / range * (1 - vPad * 2) + vPad) * size.height;

    final path = Path()..moveTo(px(0), py(data[0]));
    for (int i = 1; i < data.length; i++) {
      final cx = (px(i - 1) + px(i)) / 2;
      path.cubicTo(cx, py(data[i - 1]), cx, py(data[i]), px(i), py(data[i]));
    }

    // Gradient fill under the line
    final fillPath = Path.from(path)
      ..lineTo(px(data.length - 1), size.height)
      ..lineTo(px(0), size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // End dot
    canvas.drawCircle(
      Offset(px(data.length - 1), py(data.last)),
      3,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter o) =>
      o.data != data || o.color != color;
}

// ─── Donut chart ──────────────────────────────────────────────────────────────

class DonutSegment {
  final Color color;
  final double value;
  final String label;
  const DonutSegment(
      {required this.color, required this.value, required this.label});
}

class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double size;
  final double strokeWidth;
  final String? centerLabel;
  final String? centerSub;

  const DonutChart({
    super.key,
    required this.segments,
    this.size = 130,
    this.strokeWidth = 20,
    this.centerLabel,
    this.centerSub,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
            segments: segments, strokeWidth: strokeWidth),
        child: Center(
          child: centerLabel != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (centerSub != null)
                      Text(centerSub!,
                          style: AppTypo.caption.copyWith(fontSize: 9)),
                    Text(centerLabel!,
                        style: AppTypo.bodySmall.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 11)),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double strokeWidth;

  const _DonutPainter({required this.segments, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold(0.0, (s, e) => s + e.value);
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    double angle = -math.pi / 2;
    for (final seg in segments) {
      final sweep = (seg.value / total) * 2 * math.pi;
      canvas.drawArc(
        rect,
        angle,
        sweep - 0.05,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter o) =>
      o.segments != segments || o.strokeWidth != strokeWidth;
}

// ─── Horizontal bar list ──────────────────────────────────────────────────────

class HBarItem {
  final String label;
  final double value;
  final Color color;
  final IconData? icon;
  const HBarItem(
      {required this.label,
      required this.value,
      required this.color,
      this.icon});
}

class HorizontalBarList extends StatelessWidget {
  final List<HBarItem> items;

  const HorizontalBarList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final max = items.map((e) => e.value).reduce(math.max);
    return Column(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final ratio = max > 0 ? (item.value / max).clamp(0.0, 1.0) : 0.0;
        return Padding(
          padding: EdgeInsets.only(
              bottom: i < items.length - 1 ? AppSpacing.smd : 0),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: item.icon != null
                    ? Icon(item.icon, color: item.color, size: 14)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.label,
                              style: AppTypo.bodySmall,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(fmtBRL(item.value),
                            style: AppTypo.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LayoutBuilder(builder: (ctx, c) {
                      return Stack(
                        children: [
                          Container(
                            height: 5,
                            width: c.maxWidth,
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            height: 5,
                            width: c.maxWidth * ratio,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Monthly grouped bar chart ────────────────────────────────────────────────

class MonthlyGroupedBarChart extends StatelessWidget {
  final List<MonthSummary> series;
  final double height;

  const MonthlyGroupedBarChart({
    super.key,
    required this.series,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) return SizedBox(height: height);
    final maxV = series.fold<double>(
        0, (m, s) => math.max(m, math.max(s.income, s.expense)));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Legend
        Row(
          children: [
            _LegendDot(color: AppColors.positive),
            const SizedBox(width: 4),
            Text('Receitas', style: AppTypo.caption),
            const SizedBox(width: AppSpacing.smd),
            _LegendDot(color: AppColors.negative),
            const SizedBox(width: 4),
            Text('Despesas', style: AppTypo.caption),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Chart body
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: series.map((s) {
              final incRatio =
                  maxV > 0 ? (s.income / maxV).clamp(0.0, 1.0) : 0.0;
              final expRatio =
                  maxV > 0 ? (s.expense / maxV).clamp(0.0, 1.0) : 0.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: FractionallySizedBox(
                                heightFactor: incRatio * 0.92 + 0.02,
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.positive,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: FractionallySizedBox(
                                heightFactor: expRatio * 0.92 + 0.02,
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.negative
                                        .withValues(alpha: 0.82),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kDayNames[s.month.month].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ─── Balance trend line chart ─────────────────────────────────────────────────

class BalanceTrendChart extends StatelessWidget {
  final List<MonthSummary> series;
  final double height;

  const BalanceTrendChart({
    super.key,
    required this.series,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final balances = series.map((s) => s.balance).toList();
    if (balances.length < 2) return SizedBox(height: height);
    final last = balances.last;
    final color = last >= 0 ? AppColors.positive : AppColors.negative;
    return SparklineChart(data: balances, color: color, height: height);
  }
}
