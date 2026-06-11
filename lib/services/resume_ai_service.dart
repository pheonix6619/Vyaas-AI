import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_manager.dart';
import '../models/resume.dart';

class ResumeAIService {
  final Ref ref;

  ResumeAIService(this.ref);

  /// Generates a tailored resume objective using the active AI provider.
  Future<String> generateObjective(String jdText, Resume resume) async {
    if (jdText.isEmpty) {
      throw Exception('Job Description text is empty');
    }

    final prompt = _buildObjectivePrompt(jdText, resume);
    final ai = ref.read(aiProvider);
    return await ai.sendMessage(prompt);
  }

  /// Builds the prompt for the AI provider.
  String _buildObjectivePrompt(String jdText, Resume resume) {
    return """
Write a concise 2-3 sentence resume objective tailored to the following job description:

---
$jdText
---

Resume data:
- Education: ${resume.education.map((e) => "${e.degree} at ${e.school} (${e.duration})").join("; ")}
- Skills: ${resume.skills.entries.map((e) => "${e.key}: ${e.value.join(", ")}").join("; ")}
- Key Projects:
${resume.projects.map((p) => "  - ${p.title}: ${p.description}").join("\n")}

Guidelines:
1. Match keywords from the job description.
2. Keep it under 50 words.
3. Use professional tone.
4. Start with "To leverage..." or "Seeking to...".
5. Output ONLY the direct resume objective text. Do NOT include any preambles, explanations, conversational filler, comments, introductory remarks, or assumptions. Write only the tailored objective sentences.
""";
  }
}

final resumeAIServiceProvider = Provider<ResumeAIService>((ref) {
  return ResumeAIService(ref);
});