import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:ai_workspace/main.dart';
import 'package:ai_workspace/database/app_database.dart';
import 'package:ai_workspace/database/providers.dart';
import 'package:ai_workspace/providers/provider_manager.dart';
import 'package:ai_workspace/services/scheduler_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('Vyaas AI — Navigation Smoke Tests', () {
    late AppDatabase testDb;

    setUp(() {
      testDb = AppDatabase.testDb(NativeDatabase.memory());
      secureStorage = FakeSecureStorage();
    });

    tearDown(() async {
      await testDb.close();
    });

    testWidgets('App loads and shows Home tab (Dashboard)', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            schedulerServiceProvider.overrideWithValue(FakeSchedulerService()),
          ],
          child: const AIWorkspaceApp(),
        ),
      );

      // Wait for splash screen navigation (2.5s) plus transition
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 300));

      // Dashboard headline should be visible
      expect(find.text('Secure Workspace'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Bottom nav bar has 5 tabs', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            schedulerServiceProvider.overrideWithValue(FakeSchedulerService()),
          ],
          child: const AIWorkspaceApp(),
        ),
      );

      // Wait for splash screen navigation (2.5s) plus transition
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 300));

      // All 5 bottom nav items should exist on a narrow (mobile) screen
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Resumes'), findsOneWidget);
      expect(find.text('Templates'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Tapping Chat tab navigates to Chat screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            schedulerServiceProvider.overrideWithValue(FakeSchedulerService()),
          ],
          child: const AIWorkspaceApp(),
        ),
      );

      // Wait for splash screen navigation (2.5s) plus transition
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap the Chat bottom nav item
      await tester.tap(find.text('Chat'));

      // Use runAsync to allow the FFI database async calls to execute
      await tester.runAsync(() async {
        await tester.pump(const Duration(milliseconds: 300));
        // Give database operations a brief moment to complete
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Chat screen app bar title should be visible
      expect(find.text('AI Chat Assistant'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async {
        await tester.pump(const Duration(milliseconds: 100));
      });
    });

    testWidgets('Tapping Settings tab navigates to Settings screen',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            schedulerServiceProvider.overrideWithValue(FakeSchedulerService()),
          ],
          child: const AIWorkspaceApp(),
        ),
      );

      // Wait for splash screen navigation (2.5s) plus transition
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Settings & Providers'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Tapping Resumes tab navigates to Resume Hub screen',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(testDb),
            schedulerServiceProvider.overrideWithValue(FakeSchedulerService()),
          ],
          child: const AIWorkspaceApp(),
        ),
      );

      // Wait for splash screen navigation (2.5s) plus transition
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Resumes'));

      // Use runAsync to allow the FFI database async calls to execute
      await tester.runAsync(() async {
        await tester.pump(const Duration(milliseconds: 300));
        // Give database operations a brief moment to complete
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.text('Resume Hub'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async {
        await tester.pump(const Duration(milliseconds: 100));
      });
    });
  });
}

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _storage = {};

  FakeSecureStorage();

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.from(_storage);
  }
}

class FakeSchedulerService implements SchedulerService {
  @override
  Future<int> queueJob({
    required String title,
    required int priority,
    required String taskType,
    required Map<String, dynamic> payload,
  }) async {
    return 0;
  }

  @override
  Future<int> cancelJob(int id) async {
    return 0;
  }

  @override
  void dispose() {}
}
