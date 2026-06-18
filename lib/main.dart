import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'ui/app_shell.dart';
import 'ui/splash_screen.dart';
import 'providers/provider_manager.dart';
import 'theme/prism_theme.dart';
import 'ui/app_colors.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const AppShell(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AIWorkspaceApp()));
}

class AIWorkspaceApp extends ConsumerWidget {
  const AIWorkspaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final fontScale = ref.watch(fontScaleProvider);
    // Watching prismTheme triggers AppColors sync (isDark, currentPalette, glassTileStyle)
    ref.watch(prismThemeProvider);

    // Build both light and dark ThemeData so ThemeMode can switch between them
    final palette = ref.watch(themePaletteProvider);
    final darkPrism = PrismTheme.fromPalette(palette, true);
    final lightPrism = PrismTheme.fromPalette(palette, false);

    return MaterialApp.router(
      title: 'Vyaas AI',
      theme: lightPrism.toThemeData(),
      darkTheme: darkPrism.toThemeData(),
      themeMode: themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Synchronize static AppColors state with resolved runtime theme brightness
        final resolvedBrightness = Theme.of(context).brightness;
        AppColors.isDark = resolvedBrightness == Brightness.dark;
        AppColors.currentPalette = ref.read(themePaletteProvider);
        AppColors.glassTileStyle = ref.read(glassTileStyleProvider);
        
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(fontScale)),
          child: child!,
        );
      },
    );
  }
}
