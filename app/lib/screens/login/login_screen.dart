import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/version_badge.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.go('/app');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppSpacing.lg : AppSpacing.hero,
                vertical: AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    // Back + logo
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: AppColors.textSecondary),
                          onPressed: () => context.go('/'),
                        ),
                        const Spacer(),
                        const _Brand(),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: AppSpacing.xl),

                    // Card de login
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      radius: AppRadius.xxl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bem-vindo de volta',
                              style: AppTypo.headline),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Entre na sua conta para continuar',
                              style: AppTypo.bodySmall),
                          const SizedBox(height: AppSpacing.xl),

                          AppTextField(
                            controller: _emailCtrl,
                            label: 'E-mail',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          AppTextField(
                            controller: _passCtrl,
                            label: 'Senha',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscure,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xs),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text('Esqueceu a senha?',
                                  style: AppTypo.bodySmall.copyWith(
                                      color: AppColors.accent2)),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          AppButton(
                            label: 'Entrar',
                            onPressed: _login,
                            size: AppButtonSize.large,
                            expand: true,
                            loading: _loading,
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Divider "ou"
                          Row(
                            children: [
                              const Expanded(child: AppDivider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.smd),
                                child: Text('ou',
                                    style: AppTypo.bodySmall),
                              ),
                              const Expanded(child: AppDivider()),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          AppButton(
                            label: 'Entrar com biometria',
                            icon: Icons.fingerprint_rounded,
                            onPressed: _login,
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.large,
                            expand: true,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Não tem conta? ',
                            style: AppTypo.bodySmall),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Criar conta',
                            style: AppTypo.bodySmall.copyWith(
                              color: AppColors.accent2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: AppSpacing.lg),
                    const VersionBadge().animate().fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppIconBadge(
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.accent1,
          size: 32,
          iconSize: 18,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('Maestro', style: AppTypo.titleSmall),
      ],
    );
  }
}
