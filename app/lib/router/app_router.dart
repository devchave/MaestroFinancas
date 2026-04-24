import 'package:go_router/go_router.dart';
import '../screens/presentation/presentation_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/tools/tool_placeholder_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PresentationScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/tools/:id',
      builder: (context, state) => ToolPlaceholderScreen(
        toolId: state.pathParameters['id']!,
      ),
    ),
  ],
);
