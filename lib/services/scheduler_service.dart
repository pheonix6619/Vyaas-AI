import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/providers.dart';
import '../providers/provider_manager.dart';

/// Provider for the SchedulerService.
final schedulerServiceProvider = Provider<SchedulerService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final service = SchedulerService(ref, db);
  ref.onDispose(() => service.dispose());
  return service;
});

class SchedulerService {
  final Ref _ref;
  final AppDatabase _db;
  Timer? _timer;
  bool _isProcessing = false;

  SchedulerService(this._ref, this._db) {
    _startScheduler();
  }

  void _startScheduler() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _processNextJob();
    });
  }

  void dispose() {
    _timer?.cancel();
  }

  Future<void> _processNextJob() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // Find the next job that is pending or paused whose scheduledTime has passed or is null
      final now = DateTime.now();
      final job = await (_db.select(_db.queueJobs)
            ..where((t) =>
                t.statusString.equals('pending') |
                (t.statusString.equals('paused') &
                    (t.scheduledTime.isNull() | t.scheduledTime.isSmallerThanValue(now))))
            ..orderBy([
              (t) => OrderingTerm(expression: t.priorityCode, mode: OrderingMode.asc),
              (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc)
            ])
            ..limit(1))
          .getSingleOrNull();

      if (job != null) {
        await _executeJob(job);
      }
    } catch (e) {
      // Ignored for background safety
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _executeJob(QueueJob job) async {
    // 1. Update status to 'processing'
    await (_db.update(_db.queueJobs)..where((t) => t.id.equals(job.id))).write(
      QueueJobsCompanion(
        statusString: const Value('processing'),
        progressValue: const Value(0.2),
      ),
    );

    // 2. Decode payload
    final Map<String, dynamic> payload = job.payload != null 
        ? Map<String, dynamic>.from(jsonDecode(job.payload!)) 
        : <String, dynamic>{};
    final prompt = payload['prompt'] as String? ?? '';
    final tokenCost = prompt.length;

    // Get active provider
    final ai = _ref.read(aiProvider);
    final limiter = ai.rateLimiter;

    // 3. Rate limiter check
    if (!limiter.canSend(tokenCost: tokenCost)) {
      // Exponential backoff or constant retry delay (e.g. 10s)
      final retryTime = DateTime.now().add(const Duration(seconds: 10));
      await (_db.update(_db.queueJobs)..where((t) => t.id.equals(job.id))).write(
        QueueJobsCompanion(
          statusString: const Value('paused'),
          progressValue: const Value(0.0),
          scheduledTime: Value(retryTime),
        ),
      );
      return;
    }

    try {
      // Update progress
      await (_db.update(_db.queueJobs)..where((t) => t.id.equals(job.id))).write(
        QueueJobsCompanion(
          progressValue: const Value(0.6),
        ),
      );

      // Record request in rate limiter
      limiter.recordSend(tokenCost: tokenCost);

      // Run execution
      final response = await ai.sendMessage(prompt);

      // Save output
      await (_db.update(_db.queueJobs)..where((t) => t.id.equals(job.id))).write(
        QueueJobsCompanion(
          statusString: const Value('completed'),
          progressValue: const Value(1.0),
          result: Value(response),
        ),
      );

      // Route results back to target components
      await _handlePostExecution(job.taskType, payload, response);
    } catch (e) {
      await (_db.update(_db.queueJobs)..where((t) => t.id.equals(job.id))).write(
        QueueJobsCompanion(
          statusString: const Value('failed'),
          progressValue: const Value(0.0),
          result: Value(e.toString()),
        ),
      );
      // Route the error message back to the target interface for visibility
      await _handlePostExecution(job.taskType, payload, '⚠️ Error: ${e.toString()}');
    }
  }

  Future<void> _handlePostExecution(String? type, Map<String, dynamic> payload, String result) async {
    if (type == 'chat') {
      final chatId = payload['chatId'] as int?;
      if (chatId != null) {
        final repo = _ref.read(chatRepositoryProvider);
        await repo.insertMessage(ChatMessagesCompanion(
          chatId: Value(chatId),
          content: Value(result),
          isUser: const Value(false),
          createdAt: Value(DateTime.now()),
          completionTokens: Value(result.length),
        ));
      }
    }
    // Additional tasks (like Resume optimizations) can be handled here as well.
  }

  /// Helper to queue a background job
  Future<int> queueJob({
    required String title,
    required int priority,
    required String taskType,
    required Map<String, dynamic> payload,
  }) async {
    return await _db.into(_db.queueJobs).insert(QueueJobsCompanion(
      taskTitle: Value(title),
      priorityCode: Value(priority),
      statusString: const Value('pending'),
      progressValue: const Value(0.0),
      scheduledTime: Value(DateTime.now()),
      taskType: Value(taskType),
      payload: Value(jsonEncode(payload)),
    ));
  }

  /// Cancel a queued job or delete it
  Future<int> cancelJob(int id) async {
    return await (_db.delete(_db.queueJobs)..where((t) => t.id.equals(id))).go();
  }
}
