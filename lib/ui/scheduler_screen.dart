import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import '../providers/provider_manager.dart';
import '../database/extra_providers.dart';
import '../services/scheduler_service.dart';

class SchedulerScreen extends ConsumerStatefulWidget {
  const SchedulerScreen({super.key});

  @override
  ConsumerState<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends ConsumerState<SchedulerScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Update live RPM/TPM gauges every 1 second
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Color _getPriorityColor(int code) {
    switch (code) {
      case 1:
        return AppColors.errorRed;
      case 2:
        return AppColors.accentPurple;
      case 3:
        return AppColors.successGreen;
      case 4:
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ai = ref.watch(aiProvider);
    final limiter = ai.rateLimiter;

    final currentRpm = limiter.currentRPM;
    final currentTpm = limiter.currentTPM;
    final maxRpm = limiter.maxRequestsPerMinute;
    final maxTpm = limiter.maxTokensPerMinute;

    final rpmFraction = maxRpm > 0 ? (currentRpm / maxRpm).clamp(0.0, 1.0) : 0.0;
    final tpmFraction = maxTpm > 0 ? (currentTpm / maxTpm).clamp(0.0, 1.0) : 0.0;

    final jobsAsync = ref.watch(allQueueJobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Token Scheduler Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gauge header title
            Text('Active Request Rate Limiters', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLimitGauge(
                    context,
                    'RPM Limiter',
                    rpmFraction,
                    '$currentRpm / $maxRpm requests/min',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLimitGauge(
                    context,
                    'TPM Limiter',
                    tpmFraction,
                    '${(currentTpm / 1000).toStringAsFixed(1)}k / ${(maxTpm / 1000).toStringAsFixed(1)}k tokens/min',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Queue items title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Task Queue', style: theme.textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            jobsAsync.when(
              data: (jobs) {
                if (jobs.isEmpty) {
                  return const GlassCard(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No background jobs queued.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }

                return GlassCard(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: jobs.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: AppColors.borderTransparent,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return _buildQueueTile(
                        jobId: job.id,
                        title: job.taskTitle,
                        priority: 'P${job.priorityCode}',
                        status: job.statusString,
                        progress: job.progressValue,
                        priorityColor: _getPriorityColor(job.priorityCode),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading queue: $e')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewJobSheet,
        backgroundColor: AppColors.accentIndigo,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Job'),
      ),
    );
  }

  Widget _buildLimitGauge(BuildContext context, String title, double value, String details) {
    return GlassCard(
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 72,
                width: 72,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentIndigo),
                ),
              ),
              Text('${(value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Text(details, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildQueueTile({
    required int jobId,
    required String title,
    required String priority,
    required String status,
    required double progress,
    required Color priorityColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: priorityColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.grey),
                onPressed: () {
                  ref.read(schedulerServiceProvider).cancelJob(jobId);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: status == 'completed'
                      ? AppColors.successGreen
                      : status == 'processing'
                          ? AppColors.accentPurple
                          : status == 'paused'
                              ? Colors.orange
                              : status == 'failed'
                                  ? AppColors.errorRed
                                  : AppColors.textSecondary,
                ),
              ),
              if (progress > 0)
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPurple),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNewJobSheet() {
    final titleCtrl = TextEditingController();
    final promptCtrl = TextEditingController();
    int selectedPriority = 2; // Medium
    String selectedType = 'chat';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Background Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Priority', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        DropdownButton<int>(
                          value: selectedPriority,
                          isExpanded: true,
                          underline: Container(),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('🔴 High')),
                            DropdownMenuItem(value: 2, child: Text('🟡 Medium')),
                            DropdownMenuItem(value: 3, child: Text('🟢 Low')),
                          ],
                          onChanged: (v) => setSheetState(() => selectedPriority = v ?? 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Task Type', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        DropdownButton<String>(
                          value: selectedType,
                          isExpanded: true,
                          underline: Container(),
                          items: const [
                            DropdownMenuItem(value: 'chat', child: Text('💬 Chat')),
                            DropdownMenuItem(value: 'resume_optimize', child: Text('📄 Resume')),
                            DropdownMenuItem(value: 'document_summary', child: Text('📁 Document')),
                          ],
                          onChanged: (v) => setSheetState(() => selectedType = v ?? 'chat'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: promptCtrl,
                maxLines: 4,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Prompt / Instructions',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentIndigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.queue_rounded),
                  label: const Text('Queue Job'),
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final prompt = promptCtrl.text.trim();
                    if (title.isEmpty || prompt.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Title and Prompt are required.')),
                      );
                      return;
                    }
                    await ref.read(schedulerServiceProvider).queueJob(
                      title: title,
                      priority: selectedPriority,
                      taskType: selectedType,
                      payload: {'prompt': prompt},
                    );
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Job queued successfully!')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }
