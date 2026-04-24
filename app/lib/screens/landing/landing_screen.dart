import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_name.dart';
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
                  SizedBox(height: 100),
                  _AboutSection(),
                  SizedBox(height: 100),
                  _ForWhomSection(),
                  SizedBox(height: 100),
                  _TopicsSection(),
                  SizedBox(height: 100),
                  _AuthoritySection(),
                  SizedBox(height: 100),
                  _AppSection(),
                  SizedBox(height: 100),
                  _TestimonialsSection(),
                  SizedBox(height: 100),
                  _CTASection(),
                  SizedBox(height: 60),
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
      color: AppColors.pbBlack,
      child: Stack(
        children: [
          // Brilho prateado discreto no topo-direito
          Positioned(
            top: -180,
            right: -140,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.pbSilver.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Toque dourado muito sutil embaixo à esquerda
          Positioned(
            bottom: -220,
            left: -180,
            child: Container(
              width: 550,
              height: 550,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.pbGold.withValues(alpha: 0.05),
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
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.pbSilver.withValues(alpha: 0.08),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60, vertical: 18),
      child: Row(
        children: [
          const _LogoMark(size: 40),
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
            color: AppColors.pbSilver,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
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
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/protocolo-black/Logomarca_fundoremovido.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.pbSilver.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
          child: Center(
            child: Text(
              'PB',
              style: GoogleFonts.chakraPetch(
                color: AppColors.pbSilverLight,
                fontWeight: FontWeight.w700,
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60, vertical: 60),
      child: Column(
        children: [
          // Selo "MENTORIA PREMIUM"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.pbGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.pbGold.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.pbGold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'MENTORIA PREMIUM',
                  style: GoogleFonts.inter(
                    color: AppColors.pbGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 32),

          // Marca com tipografia real
          BrandName(
            blackSize: isMobile ? 56 : 92,
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 700.ms)
              .slideY(begin: 0.1, end: 0, delay: 150.ms),

          const SizedBox(height: 28),

          // Tagline profissional
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              'O método definitivo para organizar finanças pessoais e empresariais.\nConstrua patrimônio com clareza, disciplina e decisões baseadas em dados.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 15 : 19,
                color: AppColors.pbSilver,
                fontWeight: FontWeight.w400,
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 600.ms),

          const SizedBox(height: 36),

          // CTAs
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _GoldButton(
                label: 'Quero entrar na mentoria',
                onPressed: () {},
                large: true,
              ),
              _OutlineSilverButton(
                label: 'Conhecer o App',
                onPressed: () => context.go('/app'),
              ),
            ],
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

          const SizedBox(height: 24),

          // Prova social enxuta
          Text(
            '+500 mentorados · 98% recomendariam · Acesso vitalício',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.pbSilverDark,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

          const SizedBox(height: 60),

          // Banner maior, mais imponente
          _BannerImage()
              .animate()
              .fadeIn(delay: 400.ms, duration: 900.ms)
              .slideY(begin: 0.08, end: 0, delay: 400.ms),
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
    final maxW = w > 1400 ? 1280.0 : w - 32;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.pbSilver.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pbGold.withValues(alpha: 0.12),
                blurRadius: 60,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/protocolo-black/Banner Protocolo Black.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.pbCharcoal,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_outlined,
                              color: AppColors.pbSilver.withValues(alpha: 0.4),
                              size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Banner: adicione Banner Protocolo Black.png',
                            style: GoogleFonts.inter(
                              color: AppColors.pbSilverDark,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Linha dourada fina no topo (acabamento luxuoso)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.pbGold,
                          AppColors.pbGoldLight,
                          AppColors.pbGold,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          children: [
            const _SectionTitle(
              pretitle: 'A Mentoria',
              title: 'Clareza financeira para quem\njá cansou de improvisar.',
            ),
            const SizedBox(height: 28),
            Text(
              'O Protocolo Black é uma mentoria estruturada para profissionais, empresários '
              'e famílias que buscam controle real sobre suas finanças. O método cobre desde '
              'a reorganização completa do seu fluxo pessoal até a separação correta entre '
              'pessoa física e empresa, com ferramentas práticas e acompanhamento direto.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 15 : 17,
                color: AppColors.pbSilver,
                height: 1.75,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              alignment: WrapAlignment.center,
              children: const [
                _StatCard(number: '+500', label: 'Mentorados ativos'),
                _StatCard(number: '8', label: 'Módulos completos'),
                _StatCard(number: '12 meses', label: 'de acompanhamento'),
                _StatCard(number: '100%', label: 'Online e gravado'),
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
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.pbCharcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.pbSilver.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          // Linha dourada de acabamento
          Container(
            height: 2,
            width: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.pbGoldGradient,
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 14),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.pbSilverLight,
                AppColors.pbSilver,
              ],
            ).createShader(b),
            child: Text(
              number,
              style: GoogleFonts.chakraPetch(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.pbSilverDark,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
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
      width: 340,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.pbCharcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.pbSilver.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone com moldura prata + accent dourado
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.pbSilver.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  topic.icon,
                  color: AppColors.pbSilverLight,
                  size: 24,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.pbGold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            topic.title,
            style: GoogleFonts.inter(
              color: AppColors.pbSilverLight,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            topic.desc,
            style: GoogleFonts.inter(
              color: AppColors.pbSilverDark,
              fontSize: 14,
              height: 1.6,
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
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1160),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 28 : 56),
          decoration: BoxDecoration(
            color: AppColors.pbCharcoal,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.pbSilver.withValues(alpha: 0.1),
            ),
          ),
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
          // Selo discreto dourado
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4, height: 18,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.pbGoldGradient,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'INCLUSO NA MENTORIA',
                style: GoogleFonts.inter(
                  color: AppColors.pbGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Maestro Finanças',
            style: GoogleFonts.inter(
              color: AppColors.pbSilverLight,
              fontSize: isMobile ? 30 : 40,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'O app oficial do Protocolo Black',
            style: GoogleFonts.inter(
              color: AppColors.pbGold,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Desenvolvido para colocar em prática o método da mentoria. '
            'Unifique contas pessoais e de múltiplas empresas em uma '
            'única plataforma, com relatórios automáticos e insights '
            'inteligentes de IA.',
            style: GoogleFonts.inter(
              color: AppColors.pbSilver,
              fontSize: 15,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),
          ..._features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.pbGold.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Icon(Icons.check,
                          color: AppColors.pbGold, size: 12),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.inter(
                          color: AppColors.pbSilverLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          _OutlineSilverButton(
            label: 'Ver demonstração do app',
            onPressed: () => context.go('/app'),
          ),
        ],
      ),
      SizedBox(height: isMobile ? 40 : 0, width: isMobile ? 0 : 48),
      Center(
        child: _AppMockup(),
      ),
    ];
  }

  static const _features = [
    'Pessoa Física e múltiplas PJs unificadas',
    'Dashboard consolidado em tempo real',
    'Insights estratégicos com inteligência artificial',
    'Relatórios mensais automáticos e compartilháveis',
    'Sincronização bancária multi-instituição',
  ];
}

class _AppMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 560,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.pbBlack,
        borderRadius: BorderRadius.circular(42),
        border: Border.all(
          color: AppColors.pbSilver.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pbGold.withValues(alpha: 0.15),
            blurRadius: 60,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black,
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Container(
          color: AppColors.bg1,
          child: Stack(
            children: [
              // Fundo com gradiente sutil
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accent3.withValues(alpha: 0.3),
                      AppColors.bg1,
                    ],
                  ),
                ),
              ),
              // Notch
              Positioned(
                top: 8, left: 0, right: 0,
                child: Center(
                  child: Container(
                    width: 100, height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              // Conteúdo
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Olá, devchave',
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 12)),
                    Text('Bom dia!',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    // Balance card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patrimônio total',
                              style: GoogleFonts.inter(
                                  color: Colors.white54, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text('R\$ 48.320,00',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.positive.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('+2,4% hoje',
                                style: GoogleFonts.inter(
                                    color: AppColors.positive,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Grid de apps
                    Expanded(
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        children: List.generate(8, (i) {
                          final colors = [
                            AppColors.accent1,
                            AppColors.accent2,
                            AppColors.accent3,
                            AppColors.positive,
                            const Color(0xFFF59E0B),
                            const Color(0xFFEC4899),
                            const Color(0xFF8B5CF6),
                            const Color(0xFF14B8A6),
                          ];
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors[i],
                                  colors[i].withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }),
                      ),
                    ),
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
        constraints: const BoxConstraints(maxWidth: 860),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 36 : 56),
          decoration: BoxDecoration(
            color: AppColors.pbCharcoal,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.pbSilver.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              // Linha dourada decorativa
              Container(
                height: 2,
                width: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.pbGoldGradient,
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'PRÓXIMA TURMA',
                style: GoogleFonts.inter(
                  color: AppColors.pbGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Decida agora.\nMude sua relação com o dinheiro.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.pbSilverLight,
                  fontSize: isMobile ? 26 : 36,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Acesso vitalício à mentoria + app Maestro Finanças + '
                'encontros ao vivo mensais + comunidade exclusiva.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.pbSilver,
                  fontSize: 15,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 32),
              _GoldButton(
                label: 'Quero garantir minha vaga',
                onPressed: () {},
                large: true,
              ),
              const SizedBox(height: 14),
              Text(
                'Vagas limitadas · Garantia incondicional de 7 dias',
                style: GoogleFonts.inter(
                  color: AppColors.pbSilverDark,
                  fontSize: 12,
                  letterSpacing: 0.3,
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
// FOOTER
// ══════════════════════════════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60, vertical: 40),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.pbSilver.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        children: [
          const _LogoMark(size: 44),
          const SizedBox(height: 12),
          const BrandName(blackSize: 22, stacked: false),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink('Mentoria', () {}),
              _FooterLink('App Maestro', () {}),
              _FooterLink('Depoimentos', () {}),
              _FooterLink('Contato', () {}),
              _FooterLink('Termos', () {}),
              _FooterLink('Privacidade', () {}),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 1, width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.pbGold.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '© 2026 Protocolo Black · Mentoria Financeira Premium',
            style: GoogleFonts.inter(
              color: AppColors.pbSilverDark,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: AppColors.pbSilver,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PARA QUEM É
// ══════════════════════════════════════════════════════════════════════════════
class _ForWhomSection extends StatelessWidget {
  const _ForWhomSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          children: [
            const _SectionTitle(
              pretitle: 'Para quem é',
              title: 'Feito para quem decide\nparar de improvisar.',
            ),
            const SizedBox(height: 48),
            isMobile
                ? Column(
                    children: const [
                      _ForWhomCard(
                        isPositive: true,
                        title: 'Esta mentoria é para você se...',
                        items: _positivesItems,
                      ),
                      SizedBox(height: 20),
                      _ForWhomCard(
                        isPositive: false,
                        title: 'Esta mentoria NÃO é para você se...',
                        items: _negativesItems,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(
                        child: _ForWhomCard(
                          isPositive: true,
                          title: 'Esta mentoria é para você se...',
                          items: _positivesItems,
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _ForWhomCard(
                          isPositive: false,
                          title: 'Esta mentoria NÃO é para você se...',
                          items: _negativesItems,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  static const _positivesItems = [
    'Você é empresário, profissional liberal ou autônomo e mistura conta PF e PJ',
    'Ganha bem mas não sabe pra onde o dinheiro vai no fim do mês',
    'Quer construir patrimônio de verdade, não só guardar no poupança',
    'Está cansado de planilhas bagunçadas e controle improvisado',
    'Busca método validado, não promessas vazias de enriquecimento rápido',
  ];

  static const _negativesItems = [
    'Você busca fórmulas mágicas para ficar rico da noite pro dia',
    'Não tem disposição para colocar organização em prática',
    'Acha que app resolve tudo sem mudança de hábito',
    'Prefere continuar no caos e reclamar da situação',
  ];
}

class _ForWhomCard extends StatelessWidget {
  final bool isPositive;
  final String title;
  final List<String> items;
  const _ForWhomCard({
    required this.isPositive,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.pbCharcoal,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPositive
              ? AppColors.pbGold.withValues(alpha: 0.3)
              : AppColors.pbSilver.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: isPositive ? AppColors.pbGold : AppColors.pbSilver,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22, height: 22,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPositive
                            ? AppColors.pbGold.withValues(alpha: 0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color: isPositive
                              ? AppColors.pbGold
                              : AppColors.pbSilverMuted,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isPositive ? Icons.check : Icons.close,
                        color: isPositive
                            ? AppColors.pbGold
                            : AppColors.pbSilverMuted,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          color: isPositive
                              ? AppColors.pbSilverLight
                              : AppColors.pbSilverDark,
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AUTORIDADE / QUEM ESTÁ POR TRÁS
// ══════════════════════════════════════════════════════════════════════════════
class _AuthoritySection extends StatelessWidget {
  const _AuthoritySection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 28 : 48),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.pbCharcoal,
                AppColors.pbBlackSoft,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.pbSilver.withValues(alpha: 0.1),
            ),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _authorityContent(context),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _authorityContent(context)
                      .map((w) => w is _AuthorityPortrait ? w : Expanded(child: w))
                      .toList(),
                ),
        ),
      ),
    );
  }

  List<Widget> _authorityContent(BuildContext context) {
    return [
      const _AuthorityPortrait(),
      const SizedBox(width: 40, height: 32),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUEM ESTÁ POR TRÁS',
            style: GoogleFonts.inter(
              color: AppColors.pbGold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Especialistas que vivem do\nque ensinam.',
            style: GoogleFonts.inter(
              color: AppColors.pbSilverLight,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'O Protocolo Black é conduzido por profissionais com trajetória real em '
            'gestão financeira pessoal e empresarial — não por gurus de internet. '
            'Cada módulo é construído sobre casos reais, ferramentas validadas e '
            'resultados mensuráveis. Aqui, método é o que importa.',
            style: GoogleFonts.inter(
              color: AppColors.pbSilver,
              fontSize: 15,
              height: 1.75,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _AuthorityBadge('+10 anos de experiência'),
              _AuthorityBadge('CVM · CPA'),
              _AuthorityBadge('Empresas gestadas'),
            ],
          ),
        ],
      ),
    ];
  }
}

class _AuthorityPortrait extends StatelessWidget {
  const _AuthorityPortrait();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pbGold.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Image.asset(
          'assets/images/protocolo-black/Protocolo Black - Perfil.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.pbCharcoal,
            child: Icon(
              Icons.person,
              color: AppColors.pbSilverDark,
              size: 72,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorityBadge extends StatelessWidget {
  final String label;
  const _AuthorityBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pbBlack,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.pbSilver.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: AppColors.pbSilver,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DEPOIMENTOS
// ══════════════════════════════════════════════════════════════════════════════
class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            const _SectionTitle(
              pretitle: 'Resultados reais',
              title: 'O que dizem os mentorados.',
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: const [
                _TestimonialCard(
                  quote: 'Pela primeira vez sei exatamente pra onde meu dinheiro vai. '
                      'Em 3 meses consegui separar o que era meu do que era da empresa '
                      'e parar de me sentir no vermelho mesmo faturando bem.',
                  name: 'Rafael M.',
                  role: 'Empresário · Agência de marketing',
                ),
                _TestimonialCard(
                  quote: 'Achei que fosse só mais uma mentoria. Mas aqui tem método. '
                      'Hoje minha PJ e minha PF estão organizadas e consigo tomar '
                      'decisões estratégicas com base em dados reais.',
                  name: 'Juliana C.',
                  role: 'Advogada · Sócia de escritório',
                ),
                _TestimonialCard(
                  quote: 'Sai do Protocolo com controle total. O app fechou um ciclo '
                      'que eu tentava organizar há anos. Investimento que já se pagou '
                      'só com a economia de impostos no primeiro trimestre.',
                  name: 'Carlos D.',
                  role: 'CEO · Indústria alimentícia',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String quote;
  final String name;
  final String role;
  const _TestimonialCard({
    required this.quote,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.pbCharcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.pbSilver.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.pbGold,
              fontSize: 50,
              fontWeight: FontWeight.w700,
              height: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            style: GoogleFonts.inter(
              color: AppColors.pbSilverLight,
              fontSize: 14,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: AppColors.pbSilver.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.inter(
              color: AppColors.pbSilverLight,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: GoogleFonts.inter(
              color: AppColors.pbSilverDark,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 2, width: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.pbGoldGradient,
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              pretitle.toUpperCase(),
              style: GoogleFonts.inter(
                color: AppColors.pbGold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 2, width: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.pbGoldGradient,
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppColors.pbSilverLight,
            fontSize: isMobile ? 28 : 42,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.8,
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.pbGoldGradient,
        ),
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        boxShadow: [
          BoxShadow(
            color: AppColors.pbGold.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 18 : (large ? 40 : 30),
            vertical: compact ? 10 : (large ? 22 : 17),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compact ? 8 : 10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.pbBlack,
            fontSize: compact ? 13 : (large ? 16 : 14),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _OutlineSilverButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _OutlineSilverButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: AppColors.pbSilver.withValues(alpha: 0.35),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 17),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: AppColors.pbSilverLight,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
