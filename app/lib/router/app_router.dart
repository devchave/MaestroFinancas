import 'package:go_router/go_router.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/presentation/presentation_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/tools/dashboard_screen.dart';
import '../screens/tools/transactions_screen.dart';
import '../screens/tools/tool_placeholder_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const LandingScreen()),
    GoRoute(path: '/app', builder: (_, __) => const PresentationScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    // Telas implementadas — devem vir antes do catch-all :id
    GoRoute(path: '/tools/dashboard', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/tools/transactions', builder: (_, __) => const TransactionsScreen()),
    // Placeholder para ferramentas ainda não construídas
    GoRoute(
      path: '/tools/:id',
      builder: (context, state) =>
          ToolPlaceholderScreen(toolId: state.pathParameters['id']!),
    ),
  ],
);
