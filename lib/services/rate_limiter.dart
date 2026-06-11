import 'dart:collection';

/// Simple in‑memory rate limiter.
/// Tracks the number of requests and token usage per minute.
///
/// This implementation is deliberately minimal – it stores timestamps
/// of recent calls and clears entries older than 60 seconds.
/// It is sufficient for MVP usage and can be replaced with a
/// persistent or more sophisticated solution later.
class RateLimiter {
  /// Maximum number of requests allowed per minute.
  final int maxRequestsPerMinute;

  /// Maximum number of tokens (e.g. characters) allowed per minute.
  final int maxTokensPerMinute;

  // Internal entry tracking a request timestamp and token cost.
  final Queue<_Entry> _entries = Queue<_Entry>();

  RateLimiter({required this.maxRequestsPerMinute, required this.maxTokensPerMinute});

  /// Returns `true` if a request with the given [tokenCost] can be sent now.
  /// The check is performed against the per‑minute limits.
  bool canSend({required int tokenCost}) {
    _purgeOldEntries();
    final requestCount = _entries.length;
    final tokenSum = _entries.fold<int>(0, (sum, e) => sum + e.tokens);
    return requestCount < maxRequestsPerMinute && (tokenSum + tokenCost) <= maxTokensPerMinute;
  }

  /// Records that a request with the given [tokenCost] has been sent.
  /// Should be called only after [canSend] returns `true`.
  void recordSend({required int tokenCost}) {
    _purgeOldEntries();
    _entries.add(_Entry(DateTime.now(), tokenCost));
  }

  /// Returns the number of requests sent in the last 60 seconds.
  int get currentRPM {
    _purgeOldEntries();
    return _entries.length;
  }

  /// Returns the total token count of requests sent in the last 60 seconds.
  int get currentTPM {
    _purgeOldEntries();
    return _entries.fold<int>(0, (sum, e) => sum + e.tokens);
  }

  // Removes entries older than 60 seconds from the queue.
  void _purgeOldEntries() {
    final cutoff = DateTime.now().subtract(const Duration(seconds: 60));
    while (_entries.isNotEmpty && _entries.first.timestamp.isBefore(cutoff)) {
      _entries.removeFirst();
    }
  }
}

class _Entry {
  final DateTime timestamp;
  final int tokens;
  _Entry(this.timestamp, this.tokens);
}
