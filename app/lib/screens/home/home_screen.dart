import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/app_tool.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/version_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  final _pageController = PageController();

  // Divide tools into pages of 8 (2 rows × 4 cols), last page has rest
  List<List<AppTool>> get _pages {
    final list = appTools
        .where((t) => !dockTools.any((d) => d.id == t.id))
        .toList();
    final pages = <List<AppTool>>[];
    for (var i = 0; i < list.length; i += 8) {
      pages.add(list.sublist(i, i + 8 > list.length ? list.length : i + 8));
    }
    return pages;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _GreetingBar().animate().fadeIn(delay: 200.ms),

              // Saldo card
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _BalanceCard().animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              ),

              const SizedBox(height: 24),

              // Apps grid (paginado)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, pageIndex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _pages[pageIndex].length,
                        itemBuilder: (context, i) {
                          final tool = _pages[pageIndex][i];
                          return _AppIcon(tool: tool)
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 100 + i * 60),
                              )
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                delay: Duration(milliseconds: 100 + i * 60),
                                duration: 300.ms,
                                curve: Curves.easeOutBack,
                              );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Page indicator
              if (_pages.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppColors.accent1
                            : AppColors.glassBorder,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Dock
              _Dock(),

              const SizedBox(height: 10),
              const VersionBadge(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Olá, devchave',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.waving_hand_rounded,
                    color: Color(0xFFF59E0B),
                    size: 14,
                  ),
                ],
              ),
              Text(
                'Bom dia!',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          GlassContainer(
            borderRadius: 50,
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.accent3.withValues(alpha: 0.4),
              child: const Text(
                'D',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patrimônio total',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ 48.320,00',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.positive.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up_rounded,
                              color: AppColors.positive, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '+2,4% hoje',
                            style: GoogleFonts.inter(
                                color: AppColors.positive,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStat('PF', 'R\$ 22.100', AppColors.accent1),
              const SizedBox(height: 8),
              _MiniStat('PJ', 'R\$ 26.220', AppColors.accent3),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
                style: GoogleFonts.inter(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      );
}

class _AppIcon extends StatelessWidget {
  final AppTool tool;
  const _AppIcon({required this.tool});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(tool.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tool.color,
                  tool.color.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: tool.color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(tool.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            tool.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              shadows: [
                const Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 28,
        blur: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dockTools
              .map((tool) => GestureDetector(
                    onTap: () => context.go(tool.route),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tool.color,
                            tool.color.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: tool.color.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(tool.icon, color: Colors.white, size: 24),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
