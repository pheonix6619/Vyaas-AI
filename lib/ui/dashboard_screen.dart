import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'theme.dart';
import '../database/providers.dart';
import '../database/extra_providers.dart';
import '../providers/provider_manager.dart';
import 'chat_screen.dart'; // To access activeChatIdProvider

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Watch today's total token usage
    final todayTokensAsync = ref.watch(todayTokensProvider);
    final todayTokens = todayTokensAsync.value ?? 0;
    const maxTokens = 10000;
    final tokenProgress = maxTokens > 0 ? (todayTokens / maxTokens).clamp(0.0, 1.0) : 0.0;

    // Watch recent chats and resumes
    final chatsAsync = ref.watch(allChatsProvider);
    final resumesAsync = ref.watch(allResumesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secure Workspace',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your data remains completely on this device.',
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.shield_rounded, color: AppColors.successGreen, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Local-First',
                        style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Active API Key configuration warning tile (conditional)
            ref.watch(activeApiKeyExistsProvider).when(
              data: (exists) {
                if (!exists) {
                  return _buildApiKeyAlertCard(context, ref);
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            // Quick action layout
            Text('Quick Operations', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 768;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 1.5 : 2.5,
                  children: [
                    _buildQuickActionCard(
                      context,
                      title: 'Start AI Chat',
                      subtitle: 'Secure conversational assistant',
                      icon: Icons.chat_bubble_outline_rounded,
                      color: AppColors.accentIndigo,
                      onTap: () {
                        ref.read(appShellIndexProvider.notifier).state = 1;
                      },
                    ),
                    _buildQuickActionCard(
                      context,
                      title: 'Optimize Resume',
                      subtitle: 'ATS keywords & alignment',
                      icon: Icons.document_scanner_rounded,
                      color: AppColors.accentPurple,
                      onTap: () {
                        ref.read(appShellIndexProvider.notifier).state = 2;
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Local Token limits & usage tracking
            Text('API Keys & Daily Tokens Limit', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Icon(Icons.speed_rounded, color: AppColors.accentIndigo),
                            const SizedBox(width: 12),
                            const Flexible(child: Text('Token Usage Today', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(child: Text('$todayTokens / $maxTokens Tokens (Est.)', overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: tokenProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentIndigo),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Flexible(child: Text('Scheduler Load: Low', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                      SizedBox(width: 8),
                      Flexible(child: Text('Cost Saved: \$0.00 (Local)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Recent items lists (responsive grid layout)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 500;
                
                final chatsWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Chats', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    chatsAsync.when(
                      data: (chats) {
                        if (chats.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No recent chats',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          );
                        }
                        final sortedChats = List.from(chats)
                          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                        final recent = sortedChats.take(4).toList();
                        return Column(
                          children: recent.map<Widget>((chat) {
                            return _buildRecentItemTile(
                              chat.title,
                              DateFormat('MMM d, h:mm a').format(chat.createdAt),
                              Icons.chat_bubble_outline_rounded,
                              () {
                                ref.read(activeChatIdProvider.notifier).state = chat.id;
                                ref.read(appShellIndexProvider.notifier).state = 1;
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error: $e'),
                    ),
                  ],
                );

                final resumesWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Resumes', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    resumesAsync.when(
                      data: (resumes) {
                        if (resumes.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No recent resumes',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          );
                        }
                        final sortedResumes = List.from(resumes)
                          ..sort((a, b) => b.lastModified.compareTo(a.lastModified));
                        final recent = sortedResumes.take(4).toList();
                        return Column(
                          children: recent.map<Widget>((resume) {
                            return _buildRecentItemTile(
                              resume.fullName,
                              resume.title ?? 'Untitled Title',
                              Icons.description_outlined,
                              () {
                                ref.read(appShellIndexProvider.notifier).state = 2;
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error: $e'),
                    ),
                  ],
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: chatsWidget),
                      const SizedBox(width: 24),
                      Expanded(child: resumesWidget),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      chatsWidget,
                      const SizedBox(height: 32),
                      resumesWidget,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.slateCard.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.borderTransparent),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItemTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildApiKeyAlertCard(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(aiProvider.notifier);
    final providerName = manager.activeType == AIProviderType.gemini ? 'Gemini' : 'NVIDIA NIM';

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.slateCard.withOpacity(0.8),
            AppColors.slateCard.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.warningAmber.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warningAmber.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Icon(
              Icons.vpn_key_rounded,
              size: 110,
              color: AppColors.warningAmber.withOpacity(0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.warningAmber.withOpacity(0.25)),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warningAmber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$providerName API Required',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'To unlock professional AI features, including secure resume parsing and ATS optimizations, configure your $providerName API key. AI operations will remain inactive until configured.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(appShellIndexProvider.notifier).state = 4;
                        },
                        icon: const Icon(Icons.settings_rounded, size: 14),
                        label: const Text('Configure API Key'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warningAmber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
