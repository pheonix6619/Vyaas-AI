import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import '../repositories/chat_repository.dart';
import '../repositories/resume_repository.dart';

/// Provides a singleton instance of the Drift database.
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// Global provider for managing the active AppShell navigation tab.
final appShellIndexProvider = StateProvider<int>((ref) => 0);

/// Exposes the ChatRepository.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return ChatRepository(db);
});

/// Exposes the ResumeRepository.
final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return ResumeRepository(db);
});
