import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
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
    
    // Watch global shell index provider
    final selectedIndex = ref.watch(appShellIndexProvider);

    return Scaffold(
      body: Row(
        children: [
          // Premium Custom Sidebar Menu (Desktop)
          if (isDesktop) ...[
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: AppColors.obsidianBackground.withOpacity(0.95),
                border: const Border(
                  right: BorderSide(color: AppColors.borderTransparent),
                ),
              ),
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.successGreen,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.successGreen,
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Vyaas AI',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.5,
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
                        ),
                        _buildSidebarTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          selectedIcon: Icons.chat_bubble_rounded,
                          label: 'AI Chat',
                          selected: selectedIndex == 1,
                          onTap: () => ref.read(appShellIndexProvider.notifier).state = 1,
                        ),
                        _buildSidebarTile(
                          icon: Icons.description_outlined,
                          selectedIcon: Icons.description_rounded,
                          label: 'Resume Hub',
                          selected: selectedIndex == 2,
                          onTap: () => ref.read(appShellIndexProvider.notifier).state = 2,
                        ),
                        _buildSidebarTile(
                          icon: Icons.widgets_outlined,
                          selectedIcon: Icons.widgets_rounded,
                          label: 'Templates',
                          selected: selectedIndex == 3,
                          onTap: () => ref.read(appShellIndexProvider.notifier).state = 3,
                        ),
                        
                        const Divider(color: AppColors.borderTransparent, height: 24),
                        
                        // Expandable Settings Header Tile
                        _buildSettingsHeaderTile(selectedIndex),
                        
                        // Collapsible settings child nodes
                        if (_isSettingsExpanded) ...[
                          _buildSidebarSubTile(
                            label: 'Model Provider',
                            selected: selectedIndex == 4,
                            onTap: () => ref.read(appShellIndexProvider.notifier).state = 4,
                          ),
                          _buildSidebarSubTile(
                            label: 'Model Usage',
                            selected: selectedIndex == 5,
                            onTap: () => ref.read(appShellIndexProvider.notifier).state = 5,
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
                        
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.slateCard.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderTransparent),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.successGreen),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(providerName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        Text('Provider', style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
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
                              Divider(color: AppColors.borderTransparent.withOpacity(0.2), height: 1),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('RPM', style: const TextStyle(fontSize: 10)),
                                  FutureBuilder(
                                    future: limits,
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.hasData ? '${snapshot.data!['rpm']} / ${manager.activeType == AIProviderType.gemini ? 2 : 40}' : rpmInfo,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('TPM', style: const TextStyle(fontSize: 10)),
                                  FutureBuilder(
                                    future: limits,
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.hasData ? '${snapshot.data!['tpm']} / ${manager.activeType == AIProviderType.gemini ? 32000 : 5000}' : tpmInfo,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
          ],
          
          // Main View Content Viewport
          Expanded(child: _screens[selectedIndex]),
        ],
      ),
      
      // Bottom navigation menu for mobile devices
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: selectedIndex > 3 ? 4 : selectedIndex,
              onTap: (index) {
                if (index == 4) {
                  // Settings tab on mobile defaults to Settings Providers screen
                  ref.read(appShellIndexProvider.notifier).state = 4;
                } else {
                  ref.read(appShellIndexProvider.notifier).state = index;
                }
              },
              backgroundColor: AppColors.slateCard,
              selectedItemColor: AppColors.accentIndigo,
              unselectedItemColor: AppColors.textSecondary,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_rounded),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.description_rounded),
                  label: 'Resumes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.widgets_rounded),
                  label: 'Templates',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildSidebarTile({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentIndigo.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: AppColors.accentIndigo.withOpacity(0.25)) : null,
          ),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? AppColors.accentIndigo : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
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

  Widget _buildSettingsHeaderTile(int selectedIndex) {
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
                ? AppColors.accentPurple.withOpacity(0.08) 
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
                    color: isSettingsTabSelected ? AppColors.accentPurple : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: isSettingsTabSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: isSettingsTabSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Icon(
                _isSettingsExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                color: AppColors.textSecondary,
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 34.0, bottom: 4.0, right: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentPurple.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: AppColors.accentPurple.withOpacity(0.2)) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.accentPurple : Colors.transparent,
                  border: !selected ? Border.all(color: AppColors.textSecondary, width: 1.5) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary,
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
