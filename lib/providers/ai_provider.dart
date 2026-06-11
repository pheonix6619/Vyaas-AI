import 'dart:async';
import '../services/rate_limiter.dart';

/// Abstract contract for AI providers (NVIDIA, Gemini, etc.)
abstract class AIProvider {
  /// Currently selected active model name.
  String get activeModel;
  set activeModel(String model);

  /// Expose the rate limiter for token scheduling.
  RateLimiter get rateLimiter;

  /// Validate the stored API key – returns true if OK.
  Future<bool> validateApiKey();

  /// List available model names.
  Future<List<String>> listModels();

  /// Send a single‑turn message and return the full response.
  Future<String> sendMessage(String prompt);

  /// Stream a response – not used in MVP but defined for later.
  Stream<String> streamMessage(String prompt);

  /// Estimate remaining limits (RPM, TPM, RPD) – placeholder for now.
  Future<Map<String, int>> estimateLimits();

  /// Provider capabilities – placeholder.
  Future<Map<String, dynamic>> getCapabilities();

  /// Get request logs for this provider.
  List<String> getRequestLog();
}
