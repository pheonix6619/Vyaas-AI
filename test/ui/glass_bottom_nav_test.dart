import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workspace/ui/glass_bottom_nav.dart';

void main() {
  testWidgets('GlassBottomNavigationBar renders items and calls onTap', (WidgetTester tester) async {
    int tappedIndex = -1;
    const items = [
      GlassBottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      GlassBottomNavItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Chat',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(
          child: Scaffold(
            body: GlassBottomNavigationBar(
              currentIndex: 0,
              onTap: (i) => tappedIndex = i,
              items: items,
            ),
          ),
        ),
      ),
    );

    // Verify both items present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);

    // Tap second item
    await tester.tap(find.text('Chat').first);
    await tester.pumpAndSettle();

    expect(tappedIndex, 1);
  });
}
