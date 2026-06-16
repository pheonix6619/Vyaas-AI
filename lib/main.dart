import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'ui/app_shell.dart';
import 'ui/splash_screen.dart';
import 'providers/provider_manager.dart';
import 'theme/prism_theme.dart';

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
    final themePalette = ref.watch(themePaletteProvider);

  final prismTheme = ref.watch(prismThemeProvider);

  return MaterialApp.router(
    title: 'Vyaas AI',
    theme: prismTheme.toThemeData(),
    themeMode: themeMode,
    routerConfig: _router,
    debugShowCheckedModeBanner: false,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: fontScale),
        child: child!,
      );
    },
  );
  }
}
