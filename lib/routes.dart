import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/game/presentation/screens/game_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/achievements_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/memory_game/presentation/screens/memory_game_screen.dart';
import 'features/memory_game/presentation/bloc/memory_game_bloc.dart';
import 'features/engagement/presentation/screens/daily_challenge_screen.dart';
import 'features/engagement/presentation/screens/daily_bonus_screen.dart';
import 'features/engagement/presentation/bloc/daily_challenge_bloc.dart';
import 'features/engagement/presentation/bloc/daily_bonus_bloc.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'core/di/injection_container.dart' as di;

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => BlocProvider(
        create: (context) => di.sl<SplashBloc>(),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/game',
      name: 'game',
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/achievements',
      name: 'achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/memory-game',
      name: 'memory-game',
      builder: (context, state) => BlocProvider(
        create: (context) => di.sl<MemoryGameBloc>(),
        child: const MemoryGameScreen(),
      ),
    ),
    // Engagement feature routes
    GoRoute(
      path: '/daily-challenge',
      name: 'daily-challenge',
      builder: (context, state) => BlocProvider(
        create: (context) => di.sl<DailyChallengeBloc>(),
        child: const DailyChallengeScreen(),
      ),
    ),
    GoRoute(
      path: '/daily-bonus',
      name: 'daily-bonus',
      builder: (context, state) => BlocProvider(
        create: (context) => di.sl<DailyBonusBloc>(),
        child: const DailyBonusScreen(),
      ),
    ),
  ],
);