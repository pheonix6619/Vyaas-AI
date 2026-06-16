import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/widgets.dart';
import '../ui/theme_palette.dart';
import 'ai_provider.dart';
import 'gemini_provider.dart';
import 'nvidia_provider.dart';
import '../theme/prism_theme.dart';

FlutterSecureStorage secureStorage = const FlutterSecureStorage();

/// Supported AI providers.
enum AIProviderType { gemini, nvidia }

/// Global provider that gives the currently active AIProvider.
final aiProvider = StateNotifierProvider<AIProviderManager, AIProvider>((ref) {
  return AIProviderManager();
});

/// Manages the active AI provider, API keys, and settings.
class AIProviderManager extends StateNotifier<AIProvider> {
  AIProviderManager() : super(NvidiaProvider(apiKey: '')) {
    _loadActiveProvider();
  }

  AIProviderType _activeType = AIProviderType.nvidia;
  final Map<AIProviderType, String> _apiKeys = {};

  /// Loads the last active provider from storage.
  Future<void> _loadActiveProvider() async {
    final geminiKey = await secureStorage.read(key: 'gemini_api_key');
    if (geminiKey != null) _apiKeys[AIProviderType.gemini] = geminiKey;
    final nvidiaKey = await secureStorage.read(key: 'nvidia_api_key');
    if (nvidiaKey != null) _apiKeys[AIProviderType.nvidia] = nvidiaKey;

    final storedType = await secureStorage.read(key: 'active_provider');
    if (storedType == 'gemini') {
      await setActiveProvider(AIProviderType.gemini);
    } else {
      await setActiveProvider(AIProviderType.nvidia);
    }
  }

  /// Sets the active provider and updates state.
  Future<void> setActiveProvider(AIProviderType type) async {
    _activeType = type;
    await secureStorage.write(key: 'active_provider', value: type.name);
    
    switch (type) {
      case AIProviderType.gemini:
        state = GeminiProvider(apiKey: _apiKeys[AIProviderType.gemini] ?? '');
        break;
      case AIProviderType.nvidia:
        state = NvidiaProvider(apiKey: _apiKeys[AIProviderType.nvidia] ?? '');
        break;
    }
  }

  /// Sets the API key for a provider and validates it.
  Future<bool> setApiKey(AIProviderType type, String apiKey) async {
    await secureStorage.write(key: '${type.name}_api_key', value: apiKey);
    _apiKeys[type] = apiKey;
    
    if (type == _activeType) {
      await setActiveProvider(type); // Re-initialize with new key
    }
    
    final isValid = await state.validateApiKey();
    return isValid;
  }

  /// Returns the API key for a provider.
  Future<String?> getApiKey(AIProviderType type) async {
    return _apiKeys[type] ?? await secureStorage.read(key: '${type.name}_api_key');
  }


  /// Returns the currently active provider type.
  AIProviderType get activeType => _activeType;
}

/// Provider that checks if the active provider's API key is configured.
final activeApiKeyExistsProvider = FutureProvider<bool>((ref) async {
  ref.watch(aiProvider); // Re-run when provider changes or updates
  final manager = ref.read(aiProvider.notifier);
  final activeType = manager.activeType;
  final key = await manager.getApiKey(activeType);
  return key != null && key.trim().isNotEmpty;
});

// ─── Theme Mode ───────────────────────────────────────────────────────────────
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final storedValue = await secureStorage.read(key: 'theme_mode');
      if (storedValue == 'light') {
        state = ThemeMode.light;
      } else if (storedValue == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await secureStorage.write(
      key: 'theme_mode', 
      value: mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system'
    );
  }

  void toggleTheme() {
    final newMode = 
      state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setTheme(newMode);
  }
}

// ─── Prism Theme Provider ───────────────────────────────────────────────────
final prismThemeProvider = Provider<PrismTheme>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.light || 
         (themeMode == ThemeMode.system && 
          WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light)
    ? PrismTheme.light()
    : PrismTheme.dark();
});

// ─── Font Scale ────────────────────────────────────────────────────────────────
final fontScaleProvider = StateNotifierProvider<FontScaleNotifier, double>((ref) {
  return FontScaleNotifier();
});

class FontScaleNotifier extends StateNotifier<double> {
  FontScaleNotifier() : super(1.0) { _load(); }

  Future<void> _load() async {
    final v = await secureStorage.read(key: 'font_scale');
    if (v != null) state = double.tryParse(v) ?? 1.0;
  }

  Future<void> setScale(double scale) async {
    state = scale;
    await secureStorage.write(key: 'font_scale', value: scale.toString());
  }
}

// ─── Theme Palette ────────────────────────────────────────────────────────────

final themePaletteProvider = StateNotifierProvider<ThemePaletteNotifier, ThemePalette>((ref) {
  return ThemePaletteNotifier();
});

class ThemePaletteNotifier extends StateNotifier<ThemePalette> {
  ThemePaletteNotifier() : super(ThemePalette.midnightNavy) { _load(); }

  Future<void> _load() async {
    final v = await secureStorage.read(key: 'theme_palette');
    if (v == 'nordicForest') {
      state = ThemePalette.nordicForest;
    } else {
      state = ThemePalette.midnightNavy;
    }
  }

  Future<void> setPalette(ThemePalette palette) async {
    state = palette;
    await secureStorage.write(key: 'theme_palette', value: palette.name);
  }
}

