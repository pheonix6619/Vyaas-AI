import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'theme.dart';
import 'chat_screen.dart';
import '../providers/provider_manager.dart';
import '../database/providers.dart';
import '../database/app_database.dart';

class TemplateHubScreen extends ConsumerStatefulWidget {
  const TemplateHubScreen({super.key});

  @override
  ConsumerState<TemplateHubScreen> createState() => _TemplateHubScreenState();
}

class _TemplateHubScreenState extends ConsumerState<TemplateHubScreen> {
  String _selectedCategory = 'Career';
  String? _selectedTemplate;

  final Map<String, List<String>> _templates = {
    'Career': ['Cover Letter', 'Statement of Purpose (SOP)', 'Letter of Recommendation (LOR)', 'LinkedIn Summary'],
    'Communication': ['Professional Email', 'Follow-up Email', 'Leave Request'],
    'Study': ['Notes Summarizer', 'MCQ Generator', 'Flashcard Deck Creator', 'Viva Prep Questions'],
  };

  // Controllers for parameter input fields
  final _recipientController = TextEditingController();
  final _contextController = TextEditingController();
  final _toneController = TextEditingController();

  bool _isGenerating = false;
  String _generatedDraft = '';

  @override
  void dispose() {
    _recipientController.dispose();
    _contextController.dispose();
    _toneController.dispose();
    super.dispose();
  }

  Future<void> _generateTemplate() async {
    final recipient = _recipientController.text.trim();
    final contextDetail = _contextController.text.trim();
    final tone = _toneController.text.trim();

    if (contextDetail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter context details first.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedDraft = 'Generating draft template using active AI provider...';
    });

    try {
      final ai = ref.read(aiProvider);
      final prompt = '''
You are a professional template writer.
Generate a draft for the following template: "$_selectedTemplate".
PARAMETERS:
Recipient: ${recipient.isEmpty ? 'General' : recipient}
Context / Main Details: $contextDetail
Tone: ${tone.isEmpty ? 'Professional' : tone}

Please write a polished, complete, and contextually rich draft. Do not return any metadata or instruction headers, just return the raw template text.
''';

      final response = await ai.sendMessage(prompt);
      setState(() {
        _generatedDraft = response;
      });
    } catch (e) {
      setState(() {
        _generatedDraft = 'Failed to generate template: $e';
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _exportToChat() async {
    if (_generatedDraft.isEmpty) return;

    try {
      final repo = ref.read(chatRepositoryProvider);
      
      // 1. Create a new chat session in Drift
      final chatId = await repo.insertChat(ChatsCompanion(
        title: Value('Template: $_selectedTemplate'),
        createdAt: Value(DateTime.now()),
      ));

      // 2. Insert the generated draft as an AI message in this session
      await repo.insertMessage(ChatMessagesCompanion(
        chatId: Value(chatId),
        content: Value('Here is your generated template:\n\n$_generatedDraft'),
        isUser: const Value(false),
        createdAt: Value(DateTime.now()),
      ));

      // 3. Update active session and navigate to Chat tab (index 1)
      ref.read(activeChatIdProvider.notifier).state = chatId;
      ref.read(appShellIndexProvider.notifier).state = 1;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported successfully! Opening AI Chat...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Template Hub')),
      body: Row(
        children: [
          // Sidebar categories
          NavigationRail(
            selectedIndex: _templates.keys.toList().indexOf(_selectedCategory),
            onDestinationSelected: (index) {
              setState(() {
                _selectedCategory = _templates.keys.toList()[index];
                _selectedTemplate = null;
                _generatedDraft = '';
                _recipientController.clear();
                _contextController.clear();
                _toneController.clear();
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.slateCard.withOpacity(0.3),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.business_center_outlined),
                selectedIcon: Icon(Icons.business_center),
                label: Text('Career'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.alternate_email_rounded),
                selectedIcon: Icon(Icons.contact_mail_rounded),
                label: Text('Comm'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_rounded),
                selectedIcon: Icon(Icons.book),
                label: Text('Study'),
              ),
            ],
          ),
          const VerticalDivider(width: 1, color: AppColors.borderTransparent),
          
          // Template selector & editing pane
          Expanded(
            child: _selectedTemplate == null 
              ? _buildTemplateGrid(theme)
              : _buildTemplateForm(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateGrid(ThemeData theme) {
    final list = _templates[_selectedCategory] ?? [];
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Adjust card aspect ratio and padding on mobile to prevent vertical text overflow
    final double aspectRatio = screenWidth < 360
        ? 0.8
        : (screenWidth < 500 ? 0.95 : 1.3);

    return GridView.builder(
      padding: EdgeInsets.all(screenWidth < 500 ? 12.0 : 24.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final title = list[index];
        return InkWell(
          onTap: () {
            setState(() {
              _selectedTemplate = title;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.widgets_rounded, 
                  color: AppColors.accentPurple, 
                  size: screenWidth < 500 ? 22 : 28,
                ),
                SizedBox(height: screenWidth < 500 ? 6 : 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemplateForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedTemplate = null;
                    _generatedDraft = '';
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(_selectedTemplate!, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Enter details to populate the template:'),
          const SizedBox(height: 16),
          TextField(
            controller: _recipientController,
            decoration: const InputDecoration(labelText: 'Recipient Name / Company'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contextController,
            decoration: const InputDecoration(labelText: 'Key Context Details (e.g. key achievements, reason for email, etc.)'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _toneController,
            decoration: const InputDecoration(labelText: 'Tone Preference (e.g. Professional, Enthused, Persuasive)'),
          ),
          const SizedBox(height: 24),
          Center(
            child: _isGenerating
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Draft Text'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentIndigo),
                    onPressed: _generateTemplate,
                  ),
          ),
          const SizedBox(height: 32),
          Text('Generated Draft Output', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          GlassCard(
            child: Text(
              _generatedDraft.isEmpty
                  ? '[Draft output will appear here after clicking generate...]'
                  : _generatedDraft,
              style: TextStyle(
                color: _generatedDraft.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_generatedDraft.isNotEmpty && !_isGenerating)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Text'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _generatedDraft));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Copied to clipboard!')),
                      );
                    }
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Export to AI Chat'),
                  onPressed: _exportToChat,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
