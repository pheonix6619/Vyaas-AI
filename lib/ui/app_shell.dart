import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/prism_theme.dart';
import 'glass_components.dart';
import 'glass_bottom_nav.dart';
import '../providers/provider_manager.dart';
import '../database/providers.dart';
import '../services/scheduler_service.dart';
import 'dashboard_screen.dart';
import 'chat_screen.dart';
import 'resume_hub_screen.dart';
import 'template_hub_screen.dart';
import 'scheduler_screen.dart';
import 'settings_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _isSettingsExpanded = false;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ChatScreen(),
    ResumeHubScreen(),
    TemplateHubScreen(),
    SettingsScreen(), // Settings - Model Provider
    SchedulerScreen(), // Settings - Model Usage (Scheduler)
  ];

  @override
  Widget build(BuildContext context) {
    // Read scheduler provider to ensure background polling starts
    ref.read(schedulerServiceProvider);

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;
    final theme = context.prismTheme;
    
    // Watch global shell index provider
    final selectedIndex = ref.watch(appShellIndexProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Full-screen gradient background
          Container(
            decoration: BoxDecoration(
              gradient: theme.backgroundGradient,
            ),
          ),
          Row(
            children: [
              // Premium Custom Sidebar Menu (Desktop)
              if (isDesktop) ...[
                SizedBox(
                  width: 250,
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 0,
                    blurSigma: 20,
                    borderWidth: 0.5,
                    borderColorOverride: theme.glassBorder,
                    child: Column(
                    children: [
                      // App Title / Branding Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.accentIndigo,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.accentIndigo,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Vyaas AI',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                                color: theme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Navigation Scrollable List
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          children: [
                            _buildSidebarTile(
                              icon: Icons.dashboard_outlined,
                              selectedIcon: Icons.dashboard_rounded,
                              label: 'Home',
                              selected: selectedIndex == 0,
                              onTap: () => ref.read(appShellIndexProvider.notifier).state = 0,
                              theme: theme,
                            ),
                            _buildSidebarTile(
                              icon: Icons.chat_bubble_outline_rounded,
                              selectedIcon: Icons.chat_bubble_rounded,
                              label: 'AI Chat',
                              selected: selectedIndex == 1,
                              onTap: () => ref.read(appShellIndexProvider.notifier).state = 1,
                              theme: theme,
                            ),
                            _buildSidebarTile(
                              icon: Icons.description_outlined,
                              selectedIcon: Icons.description_rounded,
                              label: 'Resume Hub',
                              selected: selectedIndex == 2,
                              onTap: () => ref.read(appShellIndexProvider.notifier).state = 2,
                              theme: theme,
                            ),
                            _buildSidebarTile(
                              icon: Icons.widgets_outlined,
                              selectedIcon: Icons.widgets_rounded,
                              label: 'Templates',
                              selected: selectedIndex == 3,
                              onTap: () => ref.read(appShellIndexProvider.notifier).state = 3,
                              theme: theme,
                            ),
                            
                            Divider(color: theme.glassBorder, height: 24),
                            
                            // Expandable Settings Header Tile
                            _buildSettingsHeaderTile(selectedIndex, theme),
                            
                            // Collapsible settings child nodes
                            if (_isSettingsExpanded) ...[
                              _buildSidebarSubTile(
                                label: 'Model Provider',
                                selected: selectedIndex == 4,
                                onTap: () => ref.read(appShellIndexProvider.notifier).state = 4,
                                theme: theme,
                              ),
                              _buildSidebarSubTile(
                                label: 'Model Usage',
                                selected: selectedIndex == 5,
                                onTap: () => ref.read(appShellIndexProvider.notifier).state = 5,
                                theme: theme,
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Device status or mini info card in sidebar footer
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Consumer(
                          builder: (context, ref, _) {
                            final activeProvider = ref.watch(aiProvider);
                            final manager = ref.watch(aiProvider.notifier);
                            final limits = activeProvider.estimateLimits();
                            
                            String providerName = manager.activeType.name.toUpperCase();
                            String rpmInfo = '---';
                            String tpmInfo = '---';
                            
                            limits.then((value) {
                              rpmInfo = '${value['rpm']} / ${manager.activeType == AIProviderType.gemini ? 2 : 40} RPM';
                              tpmInfo = '${value['tpm']} / ${manager.activeType == AIProviderType.gemini ? 32000 : 5000} TPM';
                            });
                            
                            return GlassCard(
                              padding: const EdgeInsets.all(12),
                              borderRadius: 12,
                              borderColorOverride: theme.glassBorder,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.green),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(providerName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                                            Text('Provider', style: TextStyle(fontSize: 9, color: theme.textSecondary)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        providerName == 'GEMINI' ? Icons.star_rounded : Icons.memory_rounded,
                                        size: 16,
                                        color: providerName == 'GEMINI' ? Colors.orange : Colors.green,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Divider(color: theme.glassBorder.withValues(alpha: 0.2), height: 1),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('RPM', style: TextStyle(fontSize: 10, color: theme.textSecondary)),
                                      FutureBuilder(
                                        future: limits,
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.hasData ? '${snapshot.data!['rpm']} / ${manager.activeType == AIProviderType.gemini ? 2 : 40}' : rpmInfo,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textPrimary),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('TPM', style: TextStyle(fontSize: 10, color: theme.textSecondary)),
                                      FutureBuilder(
                                        future: limits,
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.hasData ? '${snapshot.data!['tpm']} / ${manager.activeType == AIProviderType.gemini ? 32000 : 5000}' : tpmInfo,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textPrimary),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ],
              
              // Main View Content Viewport
              Expanded(child: _screens[selectedIndex]),
            ],
          ),
          // Floating bottom navigation for mobile
          if (!isDesktop)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: GlassBottomNavigationBar(
                currentIndex: selectedIndex > 3 ? 4 : selectedIndex,
                onTap: (index) {
                  if (index == 4) {
                    // Settings tab on mobile defaults to Settings Providers screen
                    ref.read(appShellIndexProvider.notifier).state = 4;
                  } else {
                    ref.read(appShellIndexProvider.notifier).state = index;
                  }
                },
                items: const [
                  GlassBottomNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Home',
                  ),
                  GlassBottomNavItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    activeIcon: Icons.chat_bubble_rounded,
                    label: 'Chat',
                  ),
                  GlassBottomNavItem(
                    icon: Icons.description_outlined,
                    activeIcon: Icons.description_rounded,
                    label: 'Resumes',
                  ),
                  GlassBottomNavItem(
                    icon: Icons.widgets_outlined,
                    activeIcon: Icons.widgets_rounded,
                    label: 'Templates',
                  ),
                  GlassBottomNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'Settings',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarTile({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required PrismTheme theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: selected ? theme.accentIndigo.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: theme.accentIndigo.withValues(alpha: 0.25)) : null,
          ),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? theme.accentIndigo : theme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: selected ? theme.textPrimary : theme.textSecondary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsHeaderTile(int selectedIndex, PrismTheme theme) {
    final isSettingsTabSelected = selectedIndex == 4 || selectedIndex == 5;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _isSettingsExpanded = !_isSettingsExpanded;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSettingsTabSelected && !_isSettingsExpanded 
                ? theme.accentIndigo.withValues(alpha: 0.08) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isSettingsTabSelected ? Icons.settings_rounded : Icons.settings_outlined,
                    color: isSettingsTabSelected ? theme.accentIndigo : theme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: isSettingsTabSelected ? theme.textPrimary : theme.textSecondary,
                      fontWeight: isSettingsTabSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Icon(
                _isSettingsExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                color: theme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarSubTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required PrismTheme theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 34.0, bottom: 4.0, right: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: selected ? theme.accentIndigo.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: theme.accentIndigo.withValues(alpha: 0.2)) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? theme.accentIndigo : Colors.transparent,
                  border: !selected ? Border.all(color: theme.textSecondary, width: 1.5) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? theme.textPrimary : theme.textSecondary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
