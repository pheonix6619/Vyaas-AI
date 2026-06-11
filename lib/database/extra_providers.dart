import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'app_database.dart';
import 'providers.dart';
import '../repositories/chat_repository.dart';
import '../repositories/resume_repository.dart';
import '../models/resume.dart';

/// Stream of all chats.
final allChatsProvider = StreamProvider<List<Chat>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchAllChats();
});

/// Stream of all resumes.
final allResumesProvider = StreamProvider<List<Resume>>((ref) {
  final repo = ref.watch(resumeRepositoryProvider);
  return repo.watchAllResumes();
});

/// Stream of all background queue jobs.
final allQueueJobsProvider = StreamProvider<List<QueueJob>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.queueJobs)
    ..orderBy([
      (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)
    ]))
    .watch();
});

/// Stream of total tokens used today (calculated by summing prompt and completion tokens).
final todayTokensProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);

  final query = db.select(db.chatMessages)
    ..where((t) => t.createdAt.isBiggerOrEqualValue(startOfDay));

  return query.watch().map((messages) {
    int sum = 0;
    for (final msg in messages) {
      sum += msg.promptTokens;
      sum += msg.completionTokens;
    }
    return sum;
  });
});
