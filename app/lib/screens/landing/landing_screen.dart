import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pbBlack,
      body: Stack(
        children: [
          const _BlackBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  _Header(),
                  _HeroSection(),
                  SizedBox(height: 80),
                  _AboutSection(),
                  SizedBox(height: 80),
                  _TopicsSection(),
                  SizedBox(height: 80),
                  _AppSection(),
                  SizedBox(height: 80),
                  _CTASection(),
                  SizedBox(height: 40),
                  _Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FUNDO ESCURO COM GRADIENTE + DETALHES DOURADOS
// ══════════════════════════════════════════════════════════════════════════════
class _BlackBackground extends StatelessWidget {
  const _BlackBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1410),
            Color(0xFF0A0A0A),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -150,
            right: -120,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.pbGold.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.pbGoldDark.withValues(alpha: 0.12),
                    Colors.transparent,
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

// ══════════════════════════════════════════════════════════════════════════════
// HEADER
// ══════════════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60, vertical: 20),
      child: Row(
        children: [
          const _LogoMark(size: 40),
          const SizedBox(width: 12),
          Text(
            'PROTOCOLO BLACK',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: isMobile ? 14 : 16,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            _NavLink('Sobre', onTap: () {}),
            _NavLink('Conteúdo', onTap: () {}),
            _NavLink('App', onTap: () => context.go('/app')),
            const SizedBox(width: 16),
          ],
          _GoldButton(
            label: isMobile ? 'Entrar' : 'Acessar App',
            onPressed: () => context.go('/login'),
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LOGOMARK — usa asset logo.png, cai em fallback "PB" se não existir
// ══════════════════════════════════════════════════════════════════════════════
class _LogoMark extends StatelessWidget {
  final double size;
  const _LogoMark({this.size = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.pbGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: AppColors.pbGold.withValues(alpha: 0.4),
            blurRadius: size * 0.3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.25),
        child: Image.asset(
          'assets/images/protocolo-black/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              'PB',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.45,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HERO SECTION
// ══════════════════════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60, vertical: 40),
      child: Column(
        children: [
          const _LogoMark(size: 90)
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 600.ms),
          const SizedBox(height: 32),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: AppColors.pbGradient,
            ).createShader(bounds),
            child: Text(
              'Protocolo Black',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: isMobile ? 42 : 64,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -1,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            'A mentoria que domina sua vida financeira.\nPessoal. Empresarial. Sem ruído.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 16 : 20,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          const SizedBox(height: 40),
          _BannerImage()
              .animate()
              .fadeIn(delay: 600.ms, duration: 800.ms)
              .slideY(begin: 0.1, end: 0, delay: 600.ms),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _GoldButton(
                label: 'Quero entrar na mentoria',
                onPressed: () {},
              ),
              _OutlineGoldButton(
                label: 'Conhecer o App',
                onPressed: () => context.go('/app'),
              ),
            ],
          ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BANNER — usa banner.jpg, cai em fallback se não existir
// ══════════════════════════════════════════════════════════════════════════════
class _BannerImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final maxW = w > 1100 ? 1000.0 : w - 40;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW, maxHeight: 500),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.pbGold.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pbGold.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/images/protocolo-black/banner.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1410),
                      Color(0xFF0A0A0A),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined,
                          color: AppColors.pbGold.withValues(alpha: 0.5),
                          size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Banner: adicione banner.jpg em\nassets/images/protocolo-black/',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SOBRE A MENTORIA
// ══════════════════════════════════════════════════════════════════════════════
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            _SectionTitle(
              pretitle: 'A Mentoria',
              title: 'Organização financeira que transforma',
            ),
            const SizedBox(height: 32),
            Text(
              'O Protocolo Black é uma mentoria direta, prática e sem enrolação — '
              'feita para pessoas físicas e empresários que querem deixar o caos '
              'financeiro para trás. Você aprende a organizar PF e PJ, separar o '
              'que é seu do que é da empresa, controlar o fluxo de caixa e '
              'construir patrimônio com clareza.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 15 : 17,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.7,
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: const [
                _StatCard(number: '+500', label: 'Mentorados'),
                _StatCard(number: '8x', label: 'Módulos práticos'),
                _StatCard(number: '100%', label: 'Online'),
                _StatCard(number: 'App', label: 'Incluso'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.pbGold.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: AppColors.pbGradient,
            ).createShader(b),
            child: Text(
              number,
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// O QUE VOCÊ APRENDE
// ══════════════════════════════════════════════════════════════════════════════
class _TopicsSection extends StatelessWidget {
  const _TopicsSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    const topics = <_Topic>[
      _Topic(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Organização Pessoal',
        desc: 'Organize sua vida financeira do zero. Gastos, receitas, reservas.',
      ),
      _Topic(
        icon: Icons.business_center_rounded,
        title: 'Gestão Empresarial',
        desc: 'Controle de múltiplas PJs, fluxo de caixa e decisão estratégica.',
      ),
      _Topic(
        icon: Icons.swap_horiz_rounded,
        title: 'Separação PF × PJ',
        desc: 'Pare de misturar. Aprenda a pró-labore, distribuição e retirada.',
      ),
      _Topic(
        icon: Icons.trending_up_rounded,
        title: 'Investimentos',
        desc: 'Carteira estruturada para proteger e multiplicar patrimônio.',
      ),
      _Topic(
        icon: Icons.pie_chart_rounded,
        title: 'Planejamento Tributário',
        desc: 'Pague menos impostos dentro da lei. Regime, enquadramento, folha.',
      ),
      _Topic(
        icon: Icons.auto_graph_rounded,
        title: 'Mentalidade de Dono',
        desc: 'Pense como empresário. Decisões financeiras baseadas em dados.',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          children: [
            _SectionTitle(
              pretitle: 'O que você aprende',
              title: 'Conteúdo que gera resultado',
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: topics.map((t) => _TopicCard(topic: t)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Topic {
  final IconData icon;
  final String title;
  final String desc;
  const _Topic({required this.icon, required this.title, required this.desc});
}

class _TopicCard extends StatelessWidget {
  final _Topic topic;
  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.pbGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(topic.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            topic.title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            topic.desc,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// APP INCLUSO
// ══════════════════════════════════════════════════════════════════════════════
class _AppSection extends StatelessWidget {
  const _AppSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: GlassContainer(
          padding: EdgeInsets.all(isMobile ? 24 : 48),
          borderRadius: 28,
          child: isMobile
              ? Column(children: _appSectionContent(context, isMobile))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _appSectionContent(context, isMobile)
                      .map((w) => Expanded(child: w))
                      .toList(),
                ),
        ),
      ),
    );
  }

  List<Widget> _appSectionContent(BuildContext context, bool isMobile) {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.pbGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.pbGold.withValues(alpha: 0.3)),
            ),
            child: Text(
              'INCLUSO NA MENTORIA',
              style: GoogleFonts.inter(
                color: AppColors.pbGold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Maestro Finanças',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'O app que coloca em prática tudo que você aprende na mentoria. '
            'Unifique suas contas PF e múltiplas PJs em um só lugar, com '
            'relatórios automáticos e insights de IA.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          ..._features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.pbGold, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          _OutlineGoldButton(
            label: 'Ver demonstração',
            onPressed: () => context.go('/app'),
          ),
        ],
      ),
      SizedBox(height: isMobile ? 32 : 0, width: isMobile ? 0 : 32),
      // Mockup do app
      Center(
        child: _AppMockup(),
      ),
    ];
  }

  static const _features = [
    'PF + PJ unificado em uma conta',
    'Dashboard consolidado em tempo real',
    'Insights inteligentes com IA',
    'Relatórios automáticos mensais',
  ];
}

class _AppMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: AppColors.pbGold.withValues(alpha: 0.4),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pbGold.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          color: AppColors.bg1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Maestro',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Finanças',
                style: GoogleFonts.inter(
                  color: AppColors.accent2,
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('R\$ 48.320,00',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    Text('Patrimônio total',
                        style: GoogleFonts.inter(
                            color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CTA FINAL
// ══════════════════════════════════════════════════════════════════════════════
class _CTASection extends StatelessWidget {
  const _CTASection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 32 : 48),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.pbGold.withValues(alpha: 0.15),
                AppColors.pbGoldDark.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.pbGold.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Pronto pra dominar suas finanças?',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: isMobile ? 26 : 36,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Entre para o Protocolo Black e receba o acesso vitalício à '
                'mentoria + app Maestro Finanças.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              _GoldButton(
                label: 'Quero garantir minha vaga',
                onPressed: () {},
                large: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FOOTER
// ══════════════════════════════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const _LogoMark(size: 32),
          const SizedBox(height: 12),
          Text(
            '© 2026 Protocolo Black · Mentoria Financeira',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPONENTES REUTILIZÁVEIS
// ══════════════════════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String pretitle;
  final String title;
  const _SectionTitle({required this.pretitle, required this.title});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Column(
      children: [
        Text(
          pretitle.toUpperCase(),
          style: GoogleFonts.inter(
            color: AppColors.pbGold,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: isMobile ? 28 : 40,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool large;
  final bool compact;
  const _GoldButton({
    required this.label,
    required this.onPressed,
    this.large = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.pbGradient,
        ),
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        boxShadow: [
          BoxShadow(
            color: AppColors.pbGold.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 18 : (large ? 36 : 28),
            vertical: compact ? 10 : (large ? 20 : 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compact ? 10 : 14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: compact ? 13 : (large ? 17 : 15),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _OutlineGoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _OutlineGoldButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: AppColors.pbGold.withValues(alpha: 0.6),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: AppColors.pbGold,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
