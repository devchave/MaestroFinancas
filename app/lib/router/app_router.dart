import 'package:go_router/go_router.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/tools/dashboard_screen.dart';
import '../screens/tools/transactions_screen.dart';
import '../screens/tools/tool_placeholder_screen.dart';

/// Fluxo: Landing (`/`) → Login (`/login`) → App (`/app`) → Ferramenta (`/app/:id`)
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Público
    GoRoute(path: '/', builder: (_, __) => const LandingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

    // App (grid de ferramentas)
    GoRoute(path: '/app', builder: (_, __) => const HomeScreen()),

    // Ferramentas implementadas (devem vir antes do catch-all :id)
    GoRoute(
      path: '/app/dashboard',
      builder: (_, __) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/app/transactions',
      builder: (_, __) => const TransactionsScreen(),
    ),

    // Placeholder para ferramentas em construção
    GoRoute(
      path: '/app/:id',
      builder: (context, state) =>
          ToolPlaceholderScreen(toolId: state.pathParameters['id']!),
    ),
  ],
);
