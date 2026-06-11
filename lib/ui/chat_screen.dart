import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../providers/provider_manager.dart';
import '../database/providers.dart';
import '../database/extra_providers.dart';
import '../database/app_database.dart';
import '../models/message.dart';
import '../services/scheduler_service.dart';
import 'theme.dart';
import 'splash_screen.dart' show VyaasLogo;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

// Active Chat Session ID Provider
final activeChatIdProvider = StateProvider<int?>((ref) => null);

// Reactive messages stream provider watching the active chat
final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, int>((ref, chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(chatId);
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  bool _deepThinkEnabled = false;
  bool _contentVisible = true; // Controls fade animation when session changes

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(chatRepositoryProvider);
      final activeChatNotifier = ref.read(activeChatIdProvider.notifier);

      // Attempt to restore last active chat ID from secure storage
      final storedIdStr = await secureStorage.read(key: 'active_chat_id');
      int? storedId = storedIdStr != null ? int.tryParse(storedIdStr) : null;
      if (storedId != null) {
        // Verify the stored chat still exists
        final allChats = await repo.watchAllChats().first;
        if (allChats.any((c) => c.id == storedId)) {
          activeChatNotifier.state = storedId;
          return;
        }
      }

      // Load all chats (fallback)
      final chats = await repo.watchAllChats().first;
      if (chats.isEmpty) {
        // Create default chat session
        final id = await repo.insertChat(ChatsCompanion(
          title: const Value('AI Chat'),
          createdAt: Value(DateTime.now()),
        ));
        activeChatNotifier.state = id;
        // Persist new active chat ID
        await secureStorage.write(key: 'active_chat_id', value: id.toString());
      } else {
        final id = chats.first.id;
        activeChatNotifier.state = id;
        // Persist restored active chat ID
        await secureStorage.write(key: 'active_chat_id', value: id.toString());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final manager = ref.read(aiProvider.notifier);
    final activeType = manager.activeType;
    final key = await manager.getApiKey(activeType);
    if (key == null || key.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key Required'),
          content: Text('Please add your ${activeType == AIProviderType.gemini ? "Gemini" : "NVIDIA NIM"} API key in settings before sending messages.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(appShellIndexProvider.notifier).state = 4;
              },
              child: const Text('Configure Settings'),
            ),
          ],
        ),
      );
      return;
    }

    final chatId = ref.read(activeChatIdProvider);
    if (chatId != null) {
      _controller.clear();
      final repo = ref.read(chatRepositoryProvider);

      // Insert user message in database immediately
      await repo.insertMessage(ChatMessagesCompanion(
        chatId: Value(chatId),
        content: Value(text),
        isUser: const Value(true),
        createdAt: Value(DateTime.now()),
        promptTokens: Value(text.length),
      ));

      try {
        // Queue the prompt in the background scheduler queue
        await ref.read(schedulerServiceProvider).queueJob(
          title: 'AI Chat: ${text.substring(0, math.min(20, text.length))}',
          priority: 1, // P1 (highest priority)
          taskType: 'chat',
          payload: {
            'chatId': chatId,
            'prompt': text,
          },
        );
      } catch (e) {
        // Insert error message in chat
        await repo.insertMessage(ChatMessagesCompanion(
          chatId: Value(chatId),
          content: const Value('⚠️ **Error**: Failed to send prompt.\n\n*Please verify your API key, model selection, or network connection.*'),
          isUser: const Value(false),
          createdAt: Value(DateTime.now()),
          promptTokens: const Value(0),
        ));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Failed to send prompt. Check your network or API keys.')),
              ],
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeChatId = ref.watch(activeChatIdProvider);
    final messagesAsync = activeChatId != null 
        ? ref.watch(chatMessagesProvider(activeChatId))
        : const AsyncValue<List<ChatMessage>>.data([]);

    // Check if background job is thinking
    final jobsAsync = ref.watch(allQueueJobsProvider);
    final isThinking = jobsAsync.value?.any((j) {
      if (j.statusString == 'completed' || j.statusString == 'failed') return false;
      if (j.taskType != 'chat') return false;
      try {
        final payload = jsonDecode(j.payload ?? '{}');
        return payload['chatId'] == activeChatId;
      } catch (_) {
        return false;
      }
    }) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Assistant'),
        actions: [
          Row(
            children: [
              const Text('Deep Think', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Switch(
                value: _deepThinkEnabled,
                activeColor: AppColors.accentIndigo,
                onChanged: (val) => setState(() => _deepThinkEnabled = val),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Session management menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case 'clear':
                  await _clearChat();
                  break;
                case 'new':
                  await _newChat();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
              const PopupMenuItem(value: 'new', child: Text('New Chat')),
            ],
          ),
        ],
      ),
      drawer: const _ChatControlDrawer(),
      body: AnimatedOpacity(
        opacity: _contentVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
        children: [
          // Sub-header controls bar (Static Read-Only Model Info)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.slateCard.withOpacity(0.4),
              border: const Border(
                bottom: BorderSide(color: AppColors.borderTransparent),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final provider = ref.watch(aiProvider);
                      return Text(
                        provider.activeModel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final provider = ref.watch(aiProvider);
                    final limits = provider.estimateLimits();
                    final manager = ref.watch(aiProvider.notifier);
                    
                    return FutureBuilder<Map<String, int>>(
                      future: limits,
                      builder: (context, snapshot) {
                        final rpm = snapshot.data?['rpm'] ?? 0;
                        final tpm = snapshot.data?['tpm'] ?? 0;
                        
                        final maxRPM = manager.activeType == AIProviderType.gemini ? 15 : (manager.activeType == AIProviderType.nvidia ? 40 : 60);
                        final maxTPM = manager.activeType == AIProviderType.gemini ? 1000000 : (manager.activeType == AIProviderType.nvidia ? 200000 : 100000);
                        
                        return Row(
                          children: [
                            Icon(
                              Icons.speed_outlined,
                              size: 14,
                              color: rpm >= maxRPM * 0.8 || tpm >= maxTPM * 0.8
                                  ? AppColors.errorRed
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              MediaQuery.of(context).size.width < 500
                                  ? '$rpm/$maxRPM RPM'
                                  : '$rpm/$maxRPM RPM | $tpm/$maxTPM TPM',
                              style: TextStyle(
                                fontSize: 11,
                                color: rpm >= maxRPM * 0.8 || tpm >= maxTPM * 0.8
                                    ? AppColors.errorRed
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Chat message list (Reversed starting from bottom)
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                final showTyping = isThinking;
                final itemCount = messages.length + (showTyping ? 1 : 0);

                if (itemCount == 0) {
                  return const Center(
                    child: Text(
                      'No messages yet. Send a prompt to start.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true, // Start from bottom, stick to bottom
                  padding: const EdgeInsets.all(16.0),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (showTyping && index == 0) {
                      return _buildTypingBubble();
                    }

                    final msgIndex = showTyping ? index - 1 : index;
                    final msg = messages[messages.length - 1 - msgIndex];
                    
                    final align = msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                    final bubbleColor = msg.isUser
                        ? AppColors.accentIndigo.withOpacity(0.25)
                        : AppColors.slateCard.withOpacity(0.6);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Column(
                        crossAxisAlignment: align,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.all(14.0),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                                bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                              ),
                              border: Border.all(color: AppColors.borderTransparent),
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: _parseMarkdown(
                                  msg.content,
                                  const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                                ),
                              ),
                            ),
                          ),
                          if (!msg.isUser) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: msg.content));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Copied to clipboard'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading messages: $e')),
            ),
          ),
          
          // Input block
          const Divider(height: 1, color: AppColors.borderTransparent),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.slateCard.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: _deepThinkEnabled 
                            ? AppColors.accentPurple.withOpacity(0.5) 
                            : AppColors.borderTransparent
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _controller,
                      enabled: !isThinking,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Type a message securely...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppColors.accentIndigo,
                  child: IconButton(
                    icon: isThinking 
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: isThinking ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  // Clear all messages in the current chat session.
  Future<void> _clearChat() async {
    final chatId = ref.read(activeChatIdProvider);
    if (chatId == null) return;
    final repo = ref.read(chatRepositoryProvider);
    // Fade out content
    setState(() => _contentVisible = false);
    // Delete messages
    await repo.clearChatMessages(chatId);
    // Persist active chat ID (unchanged)
    await secureStorage.write(key: 'active_chat_id', value: chatId.toString());
    // Fade back in after short delay
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _contentVisible = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat cleared'), duration: Duration(seconds: 1)),
    );
  }

  // Create a fresh chat session and switch to it.
  Future<void> _newChat() async {
    final repo = ref.read(chatRepositoryProvider);
    // Fade out current view
    setState(() => _contentVisible = false);
    final newId = await repo.insertChat(ChatsCompanion(
      title: const Value('AI Chat'),
      createdAt: Value(DateTime.now()),
    ));
    // Update active chat state
    ref.read(activeChatIdProvider.notifier).state = newId;
    // Persist new active chat ID
    await secureStorage.write(key: 'active_chat_id', value: newId.toString());
    // Fade back in
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _contentVisible = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New chat started'), duration: Duration(seconds: 1)),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: AppColors.slateCard.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.borderTransparent),
            ),
            child: const SizedBox(
              width: 45,
              height: 12,
              child: TypingIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Typing Indicator Wave ───────────────────────────────────────────────────
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final double t = _controller.value - (index * 0.15);
            final double dy = math.sin(t * math.pi * 2).clamp(-1.0, 0.0) * -8.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Transform.translate(
                offset: Offset(0, dy - 2),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.accentIndigo.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── AI Control Panel Drawer ─────────────────────────────────────────────────
class _ChatControlDrawer extends ConsumerStatefulWidget {
  const _ChatControlDrawer();

  @override
  ConsumerState<_ChatControlDrawer> createState() => _ChatControlDrawerState();
}

class _ChatControlDrawerState extends ConsumerState<_ChatControlDrawer> {
  final _geminiKeyController = TextEditingController();
  final _nvidiaKeyController = TextEditingController();
  bool _obscureGemini = true;
  bool _obscureNvidia = true;
  bool _isValidatingGemini = false;
  bool _isValidatingNvidia = false;
  
  List<String> _models = [];
  bool _isLoadingModels = false;

  @override
  void initState() {
    super.initState();
    _loadKeysAndModels();
  }

  Future<void> _loadKeysAndModels() async {
    final manager = ref.read(aiProvider.notifier);
    _geminiKeyController.text = (await manager.getApiKey(AIProviderType.gemini)) ?? '';
    _nvidiaKeyController.text = (await manager.getApiKey(AIProviderType.nvidia)) ?? '';
    _loadModels();
  }

  Future<void> _loadModels() async {
    if (!mounted) return;
    setState(() => _isLoadingModels = true);
    try {
      final provider = ref.read(aiProvider);
      final list = await provider.listModels();
      if (mounted) {
        setState(() {
          _models = list;
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingModels = false);
    }
  }

  Future<void> _saveKey(AIProviderType type, String key) async {
    setState(() {
      if (type == AIProviderType.gemini) _isValidatingGemini = true;
      if (type == AIProviderType.nvidia) _isValidatingNvidia = true;
    });

    final manager = ref.read(aiProvider.notifier);
    final isValid = await manager.setApiKey(type, key);

    if (mounted) {
      setState(() {
        if (type == AIProviderType.gemini) _isValidatingGemini = false;
        if (type == AIProviderType.nvidia) _isValidatingNvidia = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isValid 
              ? '${type == AIProviderType.gemini ? "Gemini" : "NVIDIA"} Key saved & validated!' 
              : 'Failed to validate ${type == AIProviderType.gemini ? "Gemini" : "NVIDIA"} API Key.'),
          backgroundColor: isValid ? AppColors.successGreen : AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      _loadModels();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayTokensAsync = ref.watch(todayTokensProvider);
    final todayTokens = todayTokensAsync.value ?? 0;
    const maxTokens = 10000;
    final tokenProgress = maxTokens > 0 ? (todayTokens / maxTokens).clamp(0.0, 1.0) : 0.0;
    
    final quotaLeft = (maxTokens - todayTokens).clamp(0, maxTokens);
    final quotaProgress = maxTokens > 0 ? (quotaLeft / maxTokens).clamp(0.0, 1.0) : 0.0;
    
    final activeProvider = ref.watch(aiProvider);
    final activeType = ref.watch(aiProvider.notifier).activeType;

    return Drawer(
      backgroundColor: AppColors.obsidianBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header Branding
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderTransparent),
                ),
              ),
              child: Row(
                children: [
                  const VyaasLogo(size: 45, animate: false),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vyaas AI',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'AI Control Panel',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textSecondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 1. Quota Remaining Visualization (Circular/Radial progress)
                  Text('Daily Limits & Quota', style: theme.textTheme.titleMedium?.copyWith(fontSize: 13)),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Circular radial visualizer
                            SizedBox(
                              width: 68,
                              height: 68,
                              child: CustomPaint(
                                painter: _RadialProgressPainter(
                                  progress: quotaProgress,
                                  startColor: AppColors.accentIndigo,
                                  endColor: AppColors.accentPurple,
                                ),
                                child: Center(
                                  child: Text(
                                    '${(quotaProgress * 100).toInt()}%',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Quota Remaining', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${NumberFormat('#,###').format(quotaLeft)} / ${NumberFormat('#,###').format(maxTokens)} tokens left today.',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.borderTransparent),
                        // Linear usage visualizer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Today\'s Usage', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text('${(tokenProgress * 100).toInt()}% Used', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: tokenProgress,
                            minHeight: 6,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentIndigo),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Active Provider Selector
                  Text('Model & API Provider', style: theme.textTheme.titleMedium?.copyWith(fontSize: 13)),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active Provider', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<AIProviderType>(
                            value: activeType,
                            isExpanded: true,
                            dropdownColor: AppColors.slateCard,
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(aiProvider.notifier).setActiveProvider(val);
                                _loadModels();
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: AIProviderType.gemini, child: Text('Gemini Provider')),
                              DropdownMenuItem(value: AIProviderType.nvidia, child: Text('NVIDIA NIM Provider')),
                            ],
                          ),
                        ),
                        const Divider(color: AppColors.borderTransparent, height: 16),
                        const Text('Active Model', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        _isLoadingModels
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _models.contains(activeProvider.activeModel)
                                      ? activeProvider.activeModel
                                      : (_models.isNotEmpty ? _models.first : activeProvider.activeModel),
                                  isExpanded: true,
                                  dropdownColor: AppColors.slateCard,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        activeProvider.activeModel = val;
                                      });
                                    }
                                  },
                                  items: _models.isEmpty
                                      ? [
                                          DropdownMenuItem(
                                            value: activeProvider.activeModel,
                                            child: Text(activeProvider.activeModel),
                                          )
                                        ]
                                      : _models.map((m) {
                                          return DropdownMenuItem(value: m, child: Text(m));
                                        }).toList(),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. API Key Credentials Management
                  Text('API Credentials', style: theme.textTheme.titleMedium?.copyWith(fontSize: 13)),
                  const SizedBox(height: 12),
                  // Gemini key field
                  _buildApiKeyField(
                    label: 'Gemini API Key',
                    controller: _geminiKeyController,
                    obscure: _obscureGemini,
                    isValidating: _isValidatingGemini,
                    onToggleObscure: () => setState(() => _obscureGemini = !_obscureGemini),
                    onSave: (val) => _saveKey(AIProviderType.gemini, val),
                  ),
                  const SizedBox(height: 12),
                  // NVIDIA key field
                  _buildApiKeyField(
                    label: 'NVIDIA API Key',
                    controller: _nvidiaKeyController,
                    obscure: _obscureNvidia,
                    isValidating: _isValidatingNvidia,
                    onToggleObscure: () => setState(() => _obscureNvidia = !_obscureNvidia),
                    onSave: (val) => _saveKey(AIProviderType.nvidia, val),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildApiKeyField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required bool isValidating,
    required VoidCallback onToggleObscure,
    required ValueChanged<String> onSave,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              GestureDetector(
                onTap: () {
                  final String getApiUrl = label.contains('Gemini') 
                      ? 'https://aistudio.google.com/app/apikey' 
                      : 'https://build.nvidia.com/explore/discover';
                  _launchApiUrl(getApiUrl);
                },
                child: Text(
                  'get api',
                  style: TextStyle(
                    color: AppColors.accentIndigo,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Enter API key...',
                    isDense: true,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 16),
                      onPressed: onToggleObscure,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: isValidating ? null : () => onSave(controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentIndigo,
                    foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: isValidating
                      ? const SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                        )
                      : const Text('Save', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

List<TextSpan> _parseMarkdown(String text, TextStyle baseStyle) {
  final List<TextSpan> spans = [];
  final RegExp regExp = RegExp(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)');
  
  int lastIndex = 0;
  
  text.splitMapJoin(
    regExp,
    onMatch: (Match match) {
      final String matchStr = match.group(0)!;
      final String textBefore = text.substring(lastIndex, match.start);
      if (textBefore.isNotEmpty) {
        spans.add(TextSpan(text: textBefore, style: baseStyle));
      }
      
      if (matchStr.startsWith('**') && matchStr.endsWith('**')) {
        final String content = matchStr.substring(2, matchStr.length - 2);
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (matchStr.startsWith('*') && matchStr.endsWith('*')) {
        final String content = matchStr.substring(1, matchStr.length - 1);
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (matchStr.startsWith('`') && matchStr.endsWith('`')) {
        final String content = matchStr.substring(1, matchStr.length - 1);
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Colors.white.withAlpha(25),
          ),
        ));
      }
      
      lastIndex = match.end;
      return '';
    },
    onNonMatch: (String nonMatch) {
      return '';
    },
  );
  
  if (lastIndex < text.length) {
    spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
  }
  
  return spans;
}

// ─── Radial Progress Visualizer Painter ──────────────────────────────────────
class _RadialProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color startColor;
  final Color endColor;

  _RadialProgressPainter({
    required this.progress,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final fgPaint = Paint()
      ..shader = SweepGradient(
        colors: [startColor, endColor, startColor],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RadialProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor;
  }
}
