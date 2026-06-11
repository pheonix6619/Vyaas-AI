import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/rate_limiter.dart';
import 'ai_provider.dart';

/// Real NVIDIA NIM Provider — uses OpenAI-compatible REST API.
/// Free tier: 40 RPM, 200k TPM.
class NvidiaProvider implements AIProvider {
  final String apiKey;

  @override
  String activeModel = 'openai/gpt-oss-20b';

  // NVIDIA NIM free tier limits
  final RateLimiter _rateLimiter =
      RateLimiter(maxRequestsPerMinute: 40, maxTokensPerMinute: 200000);

  final List<String> _requestLog = [];

  NvidiaProvider({required this.apiKey});

  static const _base = 'https://integrate.api.nvidia.com/v1';

  @override
  RateLimiter get rateLimiter => _rateLimiter;

  // ── Validate ────────────────────────────────────────────────────────────────

  @override
  Future<bool> validateApiKey() async {
    if (apiKey.isEmpty) return false;
    try {
      final uri = Uri.parse('$_base/models');
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── List Models ──────────────────────────────────────────────────────────────

  @override
  Future<List<String>> listModels() async {
    try {
      final uri = Uri.parse('$_base/models');
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        return data
            .map((m) => m['id'] as String)

            .toList();
      }
    } catch (_) {}
    return [
      'openai/gpt-oss-20b',
      'meta/llama-3.1-8b-instruct',
      'mistralai/mistral-7b-instruct-v0.3',
      'nvidia/llama-3.1-nemotron-70b-instruct',
    ];
  }

  // ── Send Message ─────────────────────────────────────────────────────────────

  @override
  Future<String> sendMessage(String prompt) async {
    final tokenCost = math.max(1, (prompt.length / 4).ceil());

    if (!_rateLimiter.canSend(tokenCost: tokenCost)) {
      throw Exception(
          '⚠️ Rate limit reached. Max 40 requests/min. Please wait a moment.');
    }

    _logRequest(prompt);
    _rateLimiter.recordSend(tokenCost: tokenCost);

    final uri = Uri.parse('$_base/chat/completions');

    final body = jsonEncode({
      'model': activeModel,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 4096,
      'temperature': 0.7,
      'top_p': 0.95,
      'stream': false,
    });

    try {
      final res = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 120));

      if (res.statusCode == 200) {
        return _parseNvidiaResponse(res.body);
      } else {
        final snippet =
            res.body.substring(0, math.min(300, res.body.length));
        throw Exception('NVIDIA API error ${res.statusCode}: $snippet');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error contacting NVIDIA NIM: $e');
    }
  }

  // ── Stream Message ───────────────────────────────────────────────────────────

  @override
  Stream<String> streamMessage(String prompt) async* {
    // Yield full response as one chunk (SSE parsing is MVP-deferred)
    final result = await sendMessage(prompt);
    yield result;
  }

  // ── Limits & Capabilities ────────────────────────────────────────────────────

  @override
  Future<Map<String, int>> estimateLimits() async {
    return {
      'rpm': _rateLimiter.currentRPM,
      'tpm': _rateLimiter.currentTPM,
      'rpd': 2000,
    };
  }

  @override
  Future<Map<String, dynamic>> getCapabilities() async {
    return {
      'supportsStreaming': true,
      'supportsReasoning': false,
      'contextWindow': 128000,
      'provider': 'NVIDIA NIM',
    };
  }

  // ── Request Log ──────────────────────────────────────────────────────────────

  @override
  List<String> getRequestLog() => List.unmodifiable(_requestLog);

  // ── Private Helpers ──────────────────────────────────────────────────────────

  String _parseNvidiaResponse(String rawBody) {
    try {
      final data = jsonDecode(rawBody) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final message =
            choices[0]['message'] as Map<String, dynamic>?;
        return message?['content'] as String? ??
            'NVIDIA returned no content.';
      }
      return 'NVIDIA returned an empty response.';
    } catch (e) {
      return 'Failed to parse NVIDIA response: $e';
    }
  }

  void _logRequest(String prompt) {
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    final preview = prompt.substring(0, math.min(60, prompt.length));
    _requestLog.add('$timestamp: $preview...');
    if (_requestLog.length > 10) _requestLog.removeAt(0);
  }
}