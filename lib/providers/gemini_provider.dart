import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/rate_limiter.dart';
import 'ai_provider.dart';

/// Real Gemini Provider — uses Google Generative Language REST API.
/// Free tier: 15 RPM, 1M TPM (gemini-3.5-flash).
class GeminiProvider implements AIProvider {
  final String apiKey;

  @override
  String activeModel = 'gemini-3.5-flash';

  // Gemini 3.5 Flash free tier limits
  final RateLimiter _rateLimiter =
      RateLimiter(maxRequestsPerMinute: 15, maxTokensPerMinute: 1000000);

  final List<String> _requestLog = [];

  GeminiProvider({required this.apiKey});

  static const _base = 'https://generativelanguage.googleapis.com/v1beta';

  @override
  RateLimiter get rateLimiter => _rateLimiter;

  // ── Validate ────────────────────────────────────────────────────────────────

  @override
  Future<bool> validateApiKey() async {
    if (apiKey.isEmpty) return false;
    try {
      final uri = Uri.parse('$_base/models?key=$apiKey');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── List Models ──────────────────────────────────────────────────────────────

  @override
  Future<List<String>> listModels() async {
    try {
      final uri = Uri.parse('$_base/models?key=$apiKey');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final models = body['models'] as List<dynamic>? ?? [];
        return models
            .map((m) =>
                (m['name'] as String).replaceFirst('models/', ''))
            .where((n) => n.contains('gemini'))
            .toList();
      }
    } catch (_) {}
    return ['gemini-3.5-flash', 'gemini-3.1-pro', 'gemini-3.1-flash-lite'];
  }

  // ── Send Message ─────────────────────────────────────────────────────────────

  @override
  Future<String> sendMessage(String prompt) async {
    // Approximate token cost: 1 token ≈ 4 chars
    final tokenCost = math.max(1, (prompt.length / 4).ceil());

    if (!_rateLimiter.canSend(tokenCost: tokenCost)) {
      throw Exception(
          '⚠️ Rate limit reached. Max 15 requests/min. Please wait a moment.');
    }

    _logRequest(prompt);
    _rateLimiter.recordSend(tokenCost: tokenCost);

    final uri =
        Uri.parse('$_base/models/$activeModel:generateContent?key=$apiKey');

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 8192,
        'topP': 0.95,
      },
    });

    try {
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 120));

      if (res.statusCode == 200) {
        return _parseGeminiResponse(res.body);
      } else {
        final snippet =
            res.body.substring(0, math.min(300, res.body.length));
        throw Exception('Gemini API error ${res.statusCode}: $snippet');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error contacting Gemini: $e');
    }
  }

  // ── Stream Message ───────────────────────────────────────────────────────────

  @override
  Stream<String> streamMessage(String prompt) async* {
    // Yield full response as one chunk (SSE parsing is complex for MVP)
    final result = await sendMessage(prompt);
    yield result;
  }

  // ── Limits & Capabilities ────────────────────────────────────────────────────

  @override
  Future<Map<String, int>> estimateLimits() async {
    return {
      'rpm': _rateLimiter.currentRPM,
      'tpm': _rateLimiter.currentTPM,
      'rpd': 1500,
    };
  }

  @override
  Future<Map<String, dynamic>> getCapabilities() async {
    return {
      'supportsStreaming': true,
      'supportsReasoning': true,
      'contextWindow': 1000000,
      'provider': 'Google Gemini',
    };
  }

  // ── Request Log (for Settings debug panel) ───────────────────────────────────

  @override
  List<String> getRequestLog() => List.unmodifiable(_requestLog);

  // ── Private Helpers ──────────────────────────────────────────────────────────

  String _parseGeminiResponse(String rawBody) {
    try {
      final data = jsonDecode(rawBody) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final content =
            candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'] as String? ?? 'Gemini returned no text.';
        }
      }
      // Check for prompt feedback / block reason
      final feedback = data['promptFeedback'] as Map<String, dynamic>?;
      final blockReason = feedback?['blockReason'] as String?;
      if (blockReason != null) {
        return '⚠️ Content blocked by Gemini safety filters: $blockReason';
      }
      return 'Gemini returned an empty response.';
    } catch (e) {
      return 'Failed to parse Gemini response: $e';
    }
  }

  void _logRequest(String prompt) {
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    final preview = prompt.substring(0, math.min(60, prompt.length));
    _requestLog.add('$timestamp: $preview...');
    if (_requestLog.length > 10) _requestLog.removeAt(0);
  }
}