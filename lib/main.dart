import 'package:flutter/material.dart';
import 'routes.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'features/engagement/domain/services/daily_reset_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  // Initialize engagement features
  try {
    final dailyResetService = di.sl<DailyResetService>();
    await dailyResetService.checkAndPerformDailyReset();
  } catch (e) {
    // Silently fail - engagement features are optional
    // Log error in production app
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Memory Games',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}