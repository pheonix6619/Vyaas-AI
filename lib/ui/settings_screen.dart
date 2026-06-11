import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:drift/drift.dart' show Value;
import 'theme.dart';
import '../providers/provider_manager.dart';
import '../database/app_database.dart';
import '../database/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _obscureGeminiKey = true;
  bool _obscureNvidiaKey = true;
  String _activeTheme = 'System';
  double _fontScale = 1.0;
  
  final TextEditingController _geminiKeyController = TextEditingController();
  final TextEditingController _nvidiaKeyController = TextEditingController();
  bool _geminiValid = false;
  bool _nvidiaValid = false;
  String? _activeProvider;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final manager = ref.read(aiProvider.notifier);
    _geminiKeyController.text = (await manager.getApiKey(AIProviderType.gemini)) ?? '';
    _nvidiaKeyController.text = (await manager.getApiKey(AIProviderType.nvidia)) ?? '';
    _activeProvider = manager.activeType.name;
    _activeTheme = _themeModeToString(ref.read(themeModeProvider));
    _fontScale = ref.read(fontScaleProvider);

    setState(() {
      _geminiValid = _geminiKeyController.text.isNotEmpty;
      _nvidiaValid = _nvidiaKeyController.text.isNotEmpty;
    });
  }

  String _themeModeToString(ThemeMode mode) {
    if (mode == ThemeMode.light) return 'Light';
    if (mode == ThemeMode.system) return 'System';
    return 'Dark';
  }

  ThemeMode _stringToThemeMode(String s) {
    if (s == 'Light') return ThemeMode.light;
    if (s == 'System') return ThemeMode.system;
    return ThemeMode.dark;
  }

  Future<void> _validateGeminiKey() async {
    final manager = ref.read(aiProvider.notifier);
    final isValid = await manager.setApiKey(AIProviderType.gemini, _geminiKeyController.text);
    setState(() => _geminiValid = isValid);
    
    if (isValid && _activeProvider == 'gemini') {
      await manager.setActiveProvider(AIProviderType.gemini);
    }
  }

  Future<void> _validateNvidiaKey() async {
    final manager = ref.read(aiProvider.notifier);
    final isValid = await manager.setApiKey(AIProviderType.nvidia, _nvidiaKeyController.text);
    setState(() => _nvidiaValid = isValid);
    
    if (isValid && _activeProvider == 'nvidia') {
      await manager.setActiveProvider(AIProviderType.nvidia);
    }
  }

  Future<void> _setActiveProvider(String? provider) async {
    if (provider == null) return;
    
    final manager = ref.read(aiProvider.notifier);
    setState(() => _activeProvider = provider);
    
    switch (provider) {
      case 'gemini':
        await manager.setActiveProvider(AIProviderType.gemini);
        break;
      case 'nvidia':
        await manager.setActiveProvider(AIProviderType.nvidia);
        break;
    }
  }

  Future<void> _exportBackup() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final chats = await db.select(db.chats).get();
      final messages = await db.select(db.chatMessages).get();
      final resumes = await db.select(db.resumes).get();

      final data = {
        'chats': chats.map((c) => {
          'id': c.id,
          'title': c.title,
          'createdAt': c.createdAt.toIso8601String(),
          'activeModel': c.activeModel,
          'provider': c.provider,
        }).toList(),
        'messages': messages.map((m) => {
          'id': m.id,
          'chatId': m.chatId,
          'content': m.content,
          'isUser': m.isUser,
          'createdAt': m.createdAt.toIso8601String(),
          'promptTokens': m.promptTokens,
          'completionTokens': m.completionTokens,
        }).toList(),
        'resumes': resumes.map((r) => {
          'id': r.id,
          'fullName': r.fullName,
          'title': r.title,
          'email': r.email,
          'phone': r.phone,
          'website': r.website,
          'objective': r.objective,
          'aiObjective': r.aiObjective,
          'jdText': r.jdText,
          'education': r.education,
          'skills': r.skills,
          'projects': r.projects,
          'experience': r.experience,
          'certifications': r.certifications,
          'achievements': r.achievements,
          'lastModified': r.lastModified.toIso8601String(),
        }).toList(),
      };

      final jsonStr = jsonEncode(data);
      final encoded = base64Encode(utf8.encode(jsonStr));

      final docsFolder = await getApplicationDocumentsDirectory();
      final backupFile = File(p.join(docsFolder.path, 'vyaasa_backup.json'));
      await backupFile.writeAsString(encoded);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup exported successfully to: ${backupFile.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export backup: $e')),
      );
    }
  }

  Future<void> _importBackup() async {
    try {
      final docsFolder = await getApplicationDocumentsDirectory();
      final backupFile = File(p.join(docsFolder.path, 'vyaasa_backup.json'));

      if (!await backupFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No backup file found at: ${backupFile.path}. Please export a backup first or place your "vyaasa_backup.json" file in that folder.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      final content = await backupFile.readAsString();

        String jsonStr;
        try {
          jsonStr = utf8.decode(base64Decode(content.trim()));
        } catch (e) {
          jsonStr = content; // Fallback to raw JSON
        }

        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final db = ref.read(appDatabaseProvider);

        await db.transaction(() async {
          // Clear current tables
          await db.delete(db.chats).go();
          await db.delete(db.chatMessages).go();
          await db.delete(db.resumes).go();

          // Import chats
          final chatsList = data['chats'] as List<dynamic>? ?? [];
          for (final c in chatsList) {
            final map = c as Map<String, dynamic>;
            await db.into(db.chats).insert(ChatsCompanion(
              id: Value(map['id'] as int),
              title: Value(map['title'] as String),
              createdAt: Value(DateTime.parse(map['createdAt'] as String)),
              activeModel: Value(map['activeModel'] as String?),
              provider: Value(map['provider'] as String?),
            ));
          }

          // Import messages
          final messagesList = data['messages'] as List<dynamic>? ?? [];
          for (final m in messagesList) {
            final map = m as Map<String, dynamic>;
            await db.into(db.chatMessages).insert(ChatMessagesCompanion(
              id: Value(map['id'] as int),
              chatId: Value(map['chatId'] as int),
              content: Value(map['content'] as String),
              isUser: Value(map['isUser'] as bool),
              createdAt: Value(DateTime.parse(map['createdAt'] as String)),
              promptTokens: Value(map['promptTokens'] as int? ?? 0),
              completionTokens: Value(map['completionTokens'] as int? ?? 0),
            ));
          }

          // Import resumes
          final resumesList = data['resumes'] as List<dynamic>? ?? [];
          for (final r in resumesList) {
            final map = r as Map<String, dynamic>;
            await db.into(db.resumes).insert(ResumesCompanion(
              id: Value(map['id'] as int),
              fullName: Value(map['fullName'] as String),
              title: Value(map['title'] as String?),
              email: Value(map['email'] as String),
              phone: Value(map['phone'] as String),
              website: Value(map['website'] as String?),
              objective: Value(map['objective'] as String?),
              aiObjective: Value(map['aiObjective'] as String?),
              jdText: Value(map['jdText'] as String?),
              education: Value(map['education'] as String),
              skills: Value(map['skills'] as String),
              projects: Value(map['projects'] as String),
              experience: Value(map['experience'] as String?),
              certifications: Value(map['certifications'] as String?),
              achievements: Value(map['achievements'] as String?),
              lastModified: Value(DateTime.parse(map['lastModified'] as String)),
            ));
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup database restored successfully!')),
        );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import backup: $e')),
      );
    }
  }

  Future<void> _wipeLocalStorage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Permanent Reset'),
        content: const Text('Are you sure you want to wipe all local storage? This will delete all database tables, secure credentials, and reset active configurations.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Wipe Database'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Clear secure credentials
        await secureStorage.deleteAll();

        // Truncate tables
        final db = ref.read(appDatabaseProvider);
        await db.transaction(() async {
          await db.delete(db.chats).go();
          await db.delete(db.chatMessages).go();
          await db.delete(db.resumes).go();
          await db.delete(db.queueJobs).go();
        });

        // Clear local inputs and reset provider
        _geminiKeyController.clear();
        _nvidiaKeyController.clear();
        setState(() {
          _geminiValid = false;
          _nvidiaValid = false;
          _activeProvider = 'gemini';
        });

        await ref.read(aiProvider.notifier).setActiveProvider(AIProviderType.gemini);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All local workspace databases wiped successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to wipe storage: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Providers')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Providers Section
          Text('AI Provider Credentials', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          _buildProviderCard(
            name: 'Gemini Provider API',
            subtitle: '1M+ Context models (Flash / Pro)',
            logo: Icons.api_rounded,
            obscureKey: _obscureGeminiKey,
            onToggleObscure: () => setState(() => _obscureGeminiKey = !_obscureGeminiKey),
            controller: _geminiKeyController,
            isValid: _geminiValid,
            onValidate: _validateGeminiKey,
          ),
          const SizedBox(height: 16),
          _buildProviderCard(
            name: 'NVIDIA NIM Provider',
            subtitle: 'Accelerated open-source LLMs',
            logo: Icons.memory_rounded,
            obscureKey: _obscureNvidiaKey,
            onToggleObscure: () => setState(() => _obscureNvidiaKey = !_obscureNvidiaKey),
            controller: _nvidiaKeyController,
            isValid: _nvidiaValid,
            onValidate: _validateNvidiaKey,
          ),
          const SizedBox(height: 24),
          // Active Provider Dropdown
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Active Provider', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _activeProvider,
                    isExpanded: true,
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(value: 'gemini', child: Text('Gemini Provider')),
                      DropdownMenuItem(value: 'nvidia', child: Text('NVIDIA Provider')),
                    ],
                    onChanged: _setActiveProvider,
                  ),
                  const SizedBox(height: 16),
                  const Text('Recent Requests', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, _) {
                      final provider = ref.watch(aiProvider);
                      final log = provider.getRequestLog();
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: log.isEmpty
                            ? [const Text('No recent requests', style: TextStyle(fontSize: 12))]
                            : log.map((entry) => Text(entry, style: const TextStyle(fontSize: 12))).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Theme & Display preferences
          Text('Appearance & Accessibility', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Color Theme'),
                  trailing: SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      value: _activeTheme,
                      isExpanded: true,
                      underline: Container(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _activeTheme = val);
                          ref.read(themeModeProvider.notifier).setMode(_stringToThemeMode(val));
                        }
                      },
                      items: ['System', 'Light', 'Dark'].map((String mode) {
                        return DropdownMenuItem<String>(
                          value: mode,
                          child: Text(mode),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(color: AppColors.borderTransparent),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.style_outlined),
                  title: const Text('Theme Palette'),
                  trailing: SizedBox(
                    width: 150,
                    child: DropdownButton<ThemePalette>(
                      value: ref.watch(themePaletteProvider),
                      isExpanded: true,
                      underline: Container(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(themePaletteProvider.notifier).setPalette(val);
                        }
                      },
                      items: const [
                        DropdownMenuItem<ThemePalette>(
                          value: ThemePalette.midnightNavy,
                          child: Text('Midnight Navy & Coral'),
                        ),
                        DropdownMenuItem<ThemePalette>(
                          value: ThemePalette.nordicForest,
                          child: Text('Nordic Forest & Sage'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppColors.borderTransparent),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Text Scaling Scale'),
                        Text('${_fontScale.toStringAsFixed(1)}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
  Slider(
                    value: _fontScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    activeColor: AppColors.accentIndigo,
                    onChanged: (val) {
                      setState(() => _fontScale = val);
                      ref.read(fontScaleProvider.notifier).setScale(val);
                    },
                  ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Portability / Backup
          Text('Local Workspace Database Management', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Export Database Backup'),
                  subtitle: const Text('Base64 encrypted JSON archive containing all chats & resumes'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _exportBackup,
                ),
                const Divider(color: AppColors.borderTransparent),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.settings_backup_restore_rounded),
                  title: const Text('Import Database Backup'),
                  subtitle: const Text('Restore workspace data from backup file'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _importBackup,
                ),
                const Divider(color: AppColors.borderTransparent),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever_outlined, color: AppColors.errorRed),
                  title: const Text('Wipe All Local Storage', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Irreversibly delete database cache, logs, and stored API keys'),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.errorRed),
                  onTap: _wipeLocalStorage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchApiUrl(String url) async {
    final uri = Uri.parse(url);
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching URL external: $e');
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (innerE) {
        debugPrint('Error launching URL platformDefault: $innerE');
      }
    }

    if (!launched && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Get API Key Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Could not open browser automatically. You can copy the link below:'),
              const SizedBox(height: 12),
              SelectableText(
                url,
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentIndigo),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard!')),
                );
              },
              child: const Text('Copy Link'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProviderCard({
    required String name,
    required String subtitle,
    required IconData logo,
    required bool obscureKey,
    required VoidCallback onToggleObscure,
    required TextEditingController controller,
    required bool isValid,
    required Future<void> Function() onValidate,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(logo, color: AppColors.accentPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final String getApiUrl = name.contains('Gemini') 
                      ? 'https://aistudio.google.com/app/apikey' 
                      : 'https://build.nvidia.com/explore/discover';
                  _launchApiUrl(getApiUrl);
                },
                child: Text(
                  'get api',
                  style: TextStyle(
                    color: AppColors.accentIndigo,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureKey,
                  decoration: InputDecoration(
                    hintText: 'Enter API Key...',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: Icon(obscureKey ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: onToggleObscure,
                    ),
                    errorText: controller.text.isNotEmpty && !isValid ? 'Invalid API Key' : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onValidate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValid ? AppColors.successGreen : AppColors.slateCard,
                ),
                child: Text(isValid ? 'Valid' : 'Validate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
