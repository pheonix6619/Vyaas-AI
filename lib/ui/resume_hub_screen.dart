import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'theme.dart';
import '../providers/resume_notifier.dart';
import '../providers/provider_manager.dart';
import '../models/resume.dart';
import '../services/resume_ai_service.dart';
import '../database/providers.dart';

class ResumeHubScreen extends ConsumerStatefulWidget {
  const ResumeHubScreen({super.key});

  @override
  ConsumerState<ResumeHubScreen> createState() => _ResumeHubScreenState();
}

class _ResumeHubScreenState extends ConsumerState<ResumeHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _jdController = TextEditingController();
  final _objectiveController = TextEditingController();

  // Local controllers for personal details to prevent cursor jumps
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _importTextController = TextEditingController();

  bool _isOptimizing = false;
  bool _isGeneratingObjective = false;
  bool _isImporting = false;
  int _atsScore = 70;
  List<String> _missingKeywords = ['Kubernetes', 'CI/CD Pipelines', 'Drift DB'];
  String _suggestions = 'Suggestions will appear here after optimization.';
  String _selectedFont = 'Times New Roman';

  // Local state buffers for Resume Form to ensure confirm-before-save
  List<WorkExperience> _localExperiences = [];
  List<Education> _localEducation = [];
  Map<String, List<String>> _localSkills = {};
  List<Project> _localProjects = [];
  List<Certification> _localCertifications = [];
  List<String> _localAchievements = [];
  bool _isInitialized = false;
  Resume? _optimizedResume;
  bool _showOptimized = true;
  DateTime? _originalResumeLastModified;

  // Custom section sequence
  List<String> _sectionOrder = ['personal', 'experience', 'education', 'objective', 'skills', 'projects', 'certifications', 'achievements'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Listen to changes to initialize controllers once data is loaded
    Future.microtask(() {
      final resume = ref.read(resumeStateProvider);
      if (resume != null) {
        _initControllers(resume);
      }
      _loadSectionOrder();
    });
  }

  void _initControllers(Resume resume) {
    _nameController.text = resume.fullName;
    _titleController.text = resume.title ?? '';
    _emailController.text = resume.email;
    _phoneController.text = resume.phone;
    _websiteController.text = resume.website ?? '';
    _linkedinController.text = resume.linkedin ?? '';
    _githubController.text = resume.github ?? '';
    _objectiveController.text = resume.aiObjective ?? '';
    
    _localExperiences = [...resume.experience ?? []];
    _localEducation = [...resume.education];
    _localSkills = Map<String, List<String>>.from(
      resume.skills.map((key, value) => MapEntry(key, [...value])),
    );
    _localProjects = [...resume.projects];
    _localCertifications = [...resume.certifications ?? []];
    _localAchievements = [...resume.achievements ?? []];
    
    _isInitialized = true;
  }

  Future<void> _loadSectionOrder() async {
    try {
      final orderStr = await secureStorage.read(key: 'resume_section_order');
      if (orderStr != null) {
        final List<dynamic> decoded = jsonDecode(orderStr);
        setState(() {
          _sectionOrder = List<String>.from(decoded);
        });
      }
    } catch (_) {}
  }

  Future<void> _saveSectionOrder() async {
    try {
      await secureStorage.write(
        key: 'resume_section_order',
        value: jsonEncode(_sectionOrder),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _jdController.dispose();
    _objectiveController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _importTextController.dispose();
    super.dispose();
  }

  Future<void> _optimizeResume() async {
    final jdText = _jdController.text.trim();
    if (jdText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a Job Description first.')),
      );
      return;
    }

    final manager = ref.read(aiProvider.notifier);
    final activeType = manager.activeType;
    final key = await manager.getApiKey(activeType);
    if (key == null || key.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key Required'),
          content: Text('Please add your ${activeType == AIProviderType.gemini ? "Gemini" : "NVIDIA NIM"} API key in settings before optimizing your resume.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(appShellIndexProvider.notifier).state = 4;
              },
              child: const Text('Configure Settings'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isOptimizing = true);

    try {
      final resume = ref.read(resumeStateProvider);
      if (resume == null) return;

      final ai = ref.read(aiProvider);
      final prompt = '''
You are an expert ATS Resume Optimizer.
Analyze the following resume details and target job description:
RESUME:
Name: ${resume.fullName}
Title: ${resume.title ?? ''}
Objective: ${resume.aiObjective ?? ''}
Skills: ${jsonEncode(resume.skills)}
Work Experience: ${jsonEncode(resume.experience?.map((e) => e.toJson()).toList())}
Projects: ${jsonEncode(resume.projects.map((p) => p.toJson()).toList())}

JOB DESCRIPTION:
$jdText

Perform two tasks:
1. ATS Analysis: Compute a matching ATS score (0-100), identify missing key terms/keywords, and list detailed suggestions.
2. Resume Optimization: Update and tailor the resume fields to align with the Job Description. Keep existing experiences/projects but rewrite their descriptions/titles to highlight relevant technologies/skills. Update the professional objective and skills to integrate missing keywords under appropriate categories.

CRITICAL SKILLS OPTIMIZATION INSTRUCTION:
In the "skills" section, to ensure skill category lines fit within the resume constraints, actively use compact or short forms (e.g. "RAG" instead of "Retrieval-Augmented Generation", "CI/CD" instead of "Continuous Integration/Continuous Deployment", "API" instead of "Application Programming Interface", etc.). If no standard short/compact form is available, keep the name as is.

Output the result as a single valid JSON matching this schema exactly:
{
  "atsScore": 85,
  "missingKeywords": ["keyword1", "keyword2"],
  "suggestions": "bullet points of suggestions...",
  "optimizedResume": {
    "title": "tailored job title",
    "aiObjective": "tailored objective summary",
    "skills": {
      "Category1": ["skill1", "skill2"]
    },
    "experience": [
      {
        "company": "same company name",
        "title": "tailored title",
        "duration": "same duration",
        "description": "tailored description highlighting JD matching requirements"
      }
    ],
    "projects": [
      {
        "title": "same project title",
        "year": "same year",
        "url": "same url or null",
        "description": "tailored description highlighting JD matching requirements"
      }
    ]
  }
}

CRITICAL: Return ONLY valid JSON. Do not include markdown code block formatting (e.g. do not wrap in ```json), and do not add any additional explanations.
''';

      final response = await ai.sendMessage(prompt);
      
      try {
        final jsonStart = response.indexOf('{');
        if (jsonStart != -1) {
          final jsonEnd = response.lastIndexOf('}');
          final jsonString = jsonEnd != -1
              ? response.substring(jsonStart, jsonEnd + 1)
              : response.substring(jsonStart);
          final data = _parseJsonSafely(jsonString);
          setState(() {
            _missingKeywords = List<String>.from(data['missingKeywords'] ?? []);
            _atsScore = data['atsScore'] ?? 75;
            _suggestions = data['suggestions'] ?? '';
          });

          // Apply optimized resume fields to the database & local controllers
          final opt = data['optimizedResume'];
          if (opt != null) {
            final String optTitle = opt['title'] ?? resume.title ?? '';
            final String optObjective = opt['aiObjective'] ?? resume.aiObjective ?? '';
            
            // Parse skills
            final Map<String, List<String>> optSkills = {};
            if (opt['skills'] is Map) {
              (opt['skills'] as Map).forEach((key, val) {
                if (val is List) {
                  optSkills[key.toString()] = List<String>.from(val);
                }
              });
            }
            
            // Parse experience
            final List<WorkExperience> optExp = [];
            if (opt['experience'] is List) {
              for (var e in (opt['experience'] as List)) {
                if (e is Map) {
                  optExp.add(WorkExperience.fromJson(Map<String, dynamic>.from(e)));
                }
              }
            }
            
            // Parse projects
            final List<Project> optProj = [];
            if (opt['projects'] is List) {
              for (var p in (opt['projects'] as List)) {
                if (p is Map) {
                  optProj.add(Project.fromJson(Map<String, dynamic>.from(p)));
                }
              }
            }

            final optimized = resume.copyWith(
              title: optTitle,
              aiObjective: optObjective,
              skills: optSkills.isNotEmpty ? optSkills : resume.skills,
              experience: optExp.isNotEmpty ? optExp : resume.experience,
              projects: optProj.isNotEmpty ? optProj : resume.projects,
            );

            setState(() {
              _optimizedResume = optimized;
              _showOptimized = true;
              _originalResumeLastModified = resume.lastModified;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resume optimized successfully! View changes highlighted in the Preview.'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Animate to Preview tab (index 2)
              _tabController.animateTo(2);
            }
          }
        } else {
          setState(() {
            _missingKeywords = ['Docker', 'CI/CD', 'Kubernetes'];
            _atsScore = 78;
            _suggestions = response;
          });
        }
      } catch (e) {
        setState(() {
          _missingKeywords = ['API Integration', 'Testing'];
          _atsScore = 80;
          _suggestions = 'Failed to parse optimized response from AI. Please try again.';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to optimize resume. Please check your network connection or try again.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      setState(() => _isOptimizing = false);
    }
  }

  Future<void> _importResumeFromText(String text) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste some resume text first.')),
      );
      return;
    }

    final manager = ref.read(aiProvider.notifier);
    final activeType = manager.activeType;
    final key = await manager.getApiKey(activeType);
    if (key == null || key.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key Required'),
          content: Text('Please add your ${activeType == AIProviderType.gemini ? "Gemini" : "NVIDIA NIM"} API key in settings before parsing a resume.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(appShellIndexProvider.notifier).state = 4;
              },
              child: const Text('Configure Settings'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isImporting = true);
    try {
      final ai = ref.read(aiProvider);
      final prompt = '''
You are an expert AI resume parser. Parse the following resume text and output a structured JSON matching this schema exactly.
CRITICAL: Output ONLY valid JSON. Do not include markdown code block formatting (e.g. do not wrap in ```json), and do not add any additional explanation.

Schema:
{
  "fullName": "string",
  "title": "string",
  "email": "string",
  "phone": "string",
  "website": "string",
  "linkedin": "string",
  "github": "string",
  "objective": "string",
  "education": [{"school": "string", "degree": "string", "duration": "string"}],
  "skills": {"category_name": ["skill1", "skill2"]},
  "projects": [{"title": "string", "description": "string", "url": "string", "year": "string"}],
  "experience": [{"company": "string", "title": "string", "duration": "string", "description": "string"}],
  "certifications": [{"name": "string", "issuer": "string", "year": "string", "url": "string"}],
  "achievements": ["string"]
}

Resume Text to Parse:
$text
''';
      final response = await ai.sendMessage(prompt);
      
      String cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      final data = _parseJsonSafely(cleanResponse);
      
      final fullName = data['fullName'] ?? '';
      final title = data['title'] ?? '';
      final email = data['email'] ?? '';
      final phone = data['phone'] ?? '';
      final website = data['website'] ?? '';
      final linkedin = data['linkedin'] ?? '';
      final github = data['github'] ?? '';
      final aiObjective = data['objective'] ?? '';
      
      final educationList = (data['education'] as List? ?? []).map((e) {
        final m = e as Map;
        return Education(
          school: m['school'] ?? '',
          degree: m['degree'] ?? '',
          duration: m['duration'] ?? '',
        );
      }).toList();

      final skillsMap = <String, List<String>>{};
      if (data['skills'] is Map) {
        final map = data['skills'] as Map;
        map.forEach((key, value) {
          if (value is List) {
            skillsMap[key.toString()] = List<String>.from(value);
          }
        });
      }

      final projectsList = (data['projects'] as List? ?? []).map((p) {
        final m = p as Map;
        return Project(
          title: m['title'] ?? '',
          description: m['description'] ?? '',
          url: m['url'],
          year: m['year'] ?? '',
        );
      }).toList();

      final experienceList = (data['experience'] as List? ?? []).map((exp) {
        final m = exp as Map;
        return WorkExperience(
          company: m['company'] ?? '',
          title: m['title'] ?? '',
          duration: m['duration'] ?? '',
          description: m['description'] ?? '',
        );
      }).toList();

      final certificationsList = (data['certifications'] as List? ?? []).map((c) {
        final m = c as Map;
        return Certification(
          name: m['name'] ?? '',
          issuer: m['issuer'] ?? '',
          year: m['year'] ?? '',
          url: m['url'],
        );
      }).toList();

      final achievementsList = data['achievements'] != null
          ? List<String>.from(data['achievements'])
          : <String>[];

      await ref.read(resumeStateProvider.notifier).updateField(
        fullName: fullName,
        title: title,
        email: email,
        phone: phone,
        website: website,
        linkedin: linkedin,
        github: github,
        aiObjective: aiObjective,
        education: educationList,
        skills: skillsMap,
        projects: projectsList,
        experience: experienceList,
        certifications: certificationsList,
        achievements: achievementsList,
      );

      final updatedResume = ref.read(resumeStateProvider);
      if (updatedResume != null) {
        _initControllers(updatedResume);
      }
      
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resume parsed & populated successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to parse resume automatically. The text may be too long or cut off. Please try again or fill in the details manually.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Widget _buildImportResumeCard() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.cloud_upload_outlined, color: AppColors.accentIndigo),
          title: const Text(
            'Import Existing Resume (AI Parse)',
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          childrenPadding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Paste the full text of your existing resume. Vyaas AI will analyze it to automatically extract and populate all the form fields below.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _importTextController,
              minLines: 4,
              maxLines: 15,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Paste resume text here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isImporting)
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text('Parsing resume...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  )
                else
                  const SizedBox(),
                ElevatedButton.icon(
                  onPressed: _isImporting
                      ? null
                      : () => _importResumeFromText(_importTextController.text),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Parse & Populate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _parseJsonSafely(String jsonStr) {
    jsonStr = jsonStr.trim();
    if (jsonStr.isEmpty) return {};

    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    try {
      final parser = _PartialJsonParser(jsonStr);
      final decoded = parser.parse();
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return {};
  }

  String _cleanPdfText(String text) {
    return text
        .replaceAll('\u2013', '-') // en dash
        .replaceAll('\u2014', '-') // em dash
        .replaceAll('\u2011', '-') // non-breaking hyphen
        .replaceAll('\u2022', '*') // bullet
        .replaceAll('\u00a0', ' ') // non-breaking space
        .replaceAll('\u2018', "'") // curly single quote left
        .replaceAll('\u2019', "'") // curly single quote right
        .replaceAll('\u201c', '"') // curly double quote left
        .replaceAll('\u201d', '"') // curly double quote right
        .replaceAll('\u2026', '...') // ellipsis
        .replaceAll('\u200b', '') // zero width space
        .replaceAll('\u200d', '') // zero width joiner
        .replaceAll('\u200e', '') // left-to-right mark
        .replaceAll('\u200f', '') // right-to-left mark
        .replaceAll('\u00ad', '-') // soft hyphen
        .replaceAll('\u2212', '-'); // minus sign
  }

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith(RegExp(r'https?://', caseSensitive: false))) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  Future<void> _exportPdfFile(Resume resume) async {
    if (resume.fullName.isEmpty || resume.email.isEmpty || resume.education.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Required fields missing: Name, Email, Education'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    final pdf = pw.Document();
    
    // Choose font based on selection
    pw.Font baseFont;
    pw.Font boldFont;
    pw.Font italicFont;
    pw.Font boldItalicFont;

    switch (_selectedFont) {
      case 'Helvetica/Arial':
        baseFont = pw.Font.helvetica();
        boldFont = pw.Font.helveticaBold();
        italicFont = pw.Font.helveticaOblique();
        boldItalicFont = pw.Font.helveticaBoldOblique();
        break;
      case 'Courier':
        baseFont = pw.Font.courier();
        boldFont = pw.Font.courierBold();
        italicFont = pw.Font.courierOblique();
        boldItalicFont = pw.Font.courierBoldOblique();
        break;
      case 'Times New Roman':
      default:
        baseFont = pw.Font.times();
        boldFont = pw.Font.timesBold();
        italicFont = pw.Font.timesItalic();
        boldItalicFont = pw.Font.timesBoldItalic();
        break;
    }
    
    final pdfTheme = pw.ThemeData.withFont(
      base: baseFont,
      bold: boldFont,
      italic: italicFont,
      boldItalic: boldItalicFont,
    );
    
    final List<WorkExperience> experiences = (resume.experience ?? []).where((exp) =>
      exp.company.trim().isNotEmpty ||
      exp.title.trim().isNotEmpty ||
      exp.duration.trim().isNotEmpty ||
      exp.description.trim().isNotEmpty
    ).toList();

    final List<Education> education = resume.education.where((edu) =>
      edu.school.trim().isNotEmpty ||
      edu.degree.trim().isNotEmpty ||
      edu.duration.trim().isNotEmpty
    ).toList();

    final List<Project> projects = resume.projects.where((p) =>
      p.title.trim().isNotEmpty ||
      p.description.trim().isNotEmpty ||
      (p.url != null && p.url!.trim().isNotEmpty) ||
      p.year.trim().isNotEmpty
    ).toList();

    final List<Certification> certs = (resume.certifications ?? []).where((c) =>
      c.name.trim().isNotEmpty ||
      c.issuer.trim().isNotEmpty ||
      c.year.trim().isNotEmpty ||
      (c.url != null && c.url!.trim().isNotEmpty)
    ).toList();

    final List<String> achievements = (resume.achievements ?? []).where((a) =>
      a.trim().isNotEmpty
    ).toList();

    final Map<String, List<String>> filteredSkills = Map<String, List<String>>.fromEntries(
      resume.skills.entries.map((entry) {
        final key = entry.key.trim();
        final values = entry.value.map((v) => v.trim()).where((v) => v.isNotEmpty).toList();
        return MapEntry(key, values);
      }).where((entry) =>
        entry.key.isNotEmpty &&
        entry.key.toLowerCase() != 'category_name' &&
        entry.value.isNotEmpty
      )
    );

    pdf.addPage(
      pw.MultiPage(
        theme: pdfTheme,
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 30,
          marginBottom: 30,
          marginLeft: 36,
          marginRight: 36,
        ),
        build: (pw.Context context) {
          final List<pw.Widget> pageBody = [];
          
          for (final section in _sectionOrder) {
            if (section == 'objective') {
              if (resume.aiObjective != null && resume.aiObjective!.trim().isNotEmpty) {
                pageBody.add(
                  pw.Inseparable(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('OBJECTIVE', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Divider(height: 1),
                        pw.SizedBox(height: 3),
                        pw.Text(_cleanPdfText(resume.aiObjective!.trim()), style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify),
                        pw.SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }
            } else if (section == 'skills') {
              if (filteredSkills.isNotEmpty) {
                pageBody.add(
                  pw.Inseparable(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SKILLS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Divider(height: 1),
                        pw.SizedBox(height: 3),
                        ..._buildPdfSkills(filteredSkills, baseFont, boldFont),
                        pw.SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }
            } else if (section == 'experience') {
              if (experiences.isNotEmpty) {
                pageBody.add(
                  pw.Inseparable(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('WORK EXPERIENCE', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Divider(height: 1),
                        pw.SizedBox(height: 4),
                        ...experiences.map((exp) {
                          final headerParts = [
                            if (exp.company.trim().isNotEmpty) exp.company.trim(),
                            if (exp.title.trim().isNotEmpty) exp.title.trim(),
                          ];
                          final headerText = _cleanPdfText(headerParts.join(' - '));
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (headerText.isNotEmpty)
                                      pw.Text(headerText, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                                    if (exp.duration.trim().isNotEmpty)
                                      pw.Text(_cleanPdfText(exp.duration.trim()), style: const pw.TextStyle(fontSize: 8.5)),
                                  ],
                                ),
                                if (exp.description.trim().isNotEmpty) ...[
                                  pw.SizedBox(height: 1.5),
                                  pw.Text(_cleanPdfText(exp.description.trim()), style: const pw.TextStyle(fontSize: 8.5), textAlign: pw.TextAlign.justify),
                                ],
                              ],
                            ),
                          );
                        }),
                        pw.SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }
            } else if (section == 'education') {
              if (education.isNotEmpty) {
                pageBody.add(
                  pw.Inseparable(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('EDUCATION', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Divider(height: 1),
                        pw.SizedBox(height: 4),
                        ...education.map((edu) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      if (edu.school.trim().isNotEmpty)
                                        pw.Text(_cleanPdfText(edu.school.trim()), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                                      if (edu.degree.trim().isNotEmpty)
                                        pw.Text(_cleanPdfText(edu.degree.trim()), style: const pw.TextStyle(fontSize: 8.5)),
                                    ],
                                  ),
                                ),
                                if (edu.duration.trim().isNotEmpty)
                                  pw.Text(_cleanPdfText(edu.duration.trim()), style: const pw.TextStyle(fontSize: 8.5)),
                              ],
                            ),
                          );
                        }),
                        pw.SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }
            } else if (section == 'projects') {
              if (projects.isNotEmpty) {
                pageBody.add(
                  pw.Inseparable(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PROJECTS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Divider(height: 1),
                        pw.SizedBox(height: 4),
                        ...projects.map((p) {
                          final titleParts = [
                            if (p.title.trim().isNotEmpty) p.title.trim(),
                            if (p.url != null && p.url!.trim().isNotEmpty) '(${p.url!.trim()})',
                          ];
                          final titleText = _cleanPdfText(titleParts.join(' '));
                          
                          final bullets = _splitIntoBullets(p.description);
                          final displayedBullets = bullets.take(3).toList();
                          
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (titleText.isNotEmpty)
                                      pw.Text(titleText, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                                    if (p.year.trim().isNotEmpty)
                                      pw.Text(_cleanPdfText(p.year.trim()), style: const pw.TextStyle(fontSize: 8.5)),
                                  ],
                                ),
                                if (displayedBullets.isNotEmpty) ...[
                                  pw.SizedBox(height: 2),
                                  ...displayedBullets.map((bullet) => pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 1.5),
                                    child: pw.Row(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Container(
                                          margin: const pw.EdgeInsets.only(top: 3.0, right: 6),
                                          width: 3.5,
                                          height: 3.5,
                                          decoration: const pw.BoxDecoration(
                                            color: PdfColors.black,
                                            shape: pw.BoxShape.circle,
                                          ),
                                        ),
                                        pw.Expanded(
                                          child: pw.Text(_cleanPdfText(bullet), style: const pw.TextStyle(fontSize: 8.5), textAlign: pw.TextAlign.justify),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ],
                            ),
                          );
                        }),
                        pw.SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }
            } else if (section == 'certifications') {
              if (certs.isNotEmpty) {
                pageBody.add(
                  pw.Inseparable(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('CERTIFICATIONS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Divider(height: 1),
                        pw.SizedBox(height: 4),
                        ...certs.map((c) {
                          final issuerParts = [
                            if (c.issuer.trim().isNotEmpty) c.issuer.trim(),
                            if (c.url != null && c.url!.trim().isNotEmpty) '(${c.url!.trim()})',
                          ];
                          final issuerText = _cleanPdfText(issuerParts.join(' '));
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      if (c.name.trim().isNotEmpty)
                                        pw.Text(_cleanPdfText(c.name.trim()), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                                      if (issuerText.isNotEmpty)
                                        pw.Text(issuerText, style: const pw.TextStyle(fontSize: 8.5)),
                                    ],
                                  ),
                                ),
                                if (c.year.trim().isNotEmpty)
                                  pw.Text(_cleanPdfText(c.year.trim()), style: const pw.TextStyle(fontSize: 8.5)),
                              ],
                            ),
                          );
                        }),
                        pw.SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }
            } else if (section == 'achievements') {
              if (achievements.isNotEmpty) {
                pageBody.add(
                  pw.Inseparable(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ACHIEVEMENTS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Divider(height: 1),
                        pw.SizedBox(height: 4),
                        ...achievements.map((a) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 3),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  margin: const pw.EdgeInsets.only(top: 3.0, right: 6),
                                  width: 3.5,
                                  height: 3.5,
                                  decoration: const pw.BoxDecoration(
                                    color: PdfColors.black,
                                    shape: pw.BoxShape.circle,
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Text(_cleanPdfText(a), style: const pw.TextStyle(fontSize: 8.5), textAlign: pw.TextAlign.justify),
                                ),
                              ],
                            ),
                          );
                        }),
                        pw.SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }
            }
          }

          final contactWidgets = <pw.Widget>[];

          if (resume.email.trim().isNotEmpty) {
            final email = resume.email.trim();
            contactWidgets.add(
              pw.UrlLink(
                destination: 'mailto:$email',
                child: pw.Text(
                  _cleanPdfText(email),
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: PdfColors.blue700,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
            );
          }

          if (resume.phone.trim().isNotEmpty) {
            final phone = resume.phone.trim();
            contactWidgets.add(
              pw.UrlLink(
                destination: 'tel:$phone',
                child: pw.Text(
                  _cleanPdfText(phone),
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                  ),
                ),
              ),
            );
          }

          if (resume.website != null && resume.website!.trim().isNotEmpty) {
            final web = resume.website!.trim();
            final destination = _normalizeUrl(web);
            contactWidgets.add(
              pw.UrlLink(
                destination: destination,
                child: pw.Text(
                  _cleanPdfText(web),
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: PdfColors.blue700,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
            );
          }

          if (resume.linkedin != null && resume.linkedin!.trim().isNotEmpty) {
            final li = resume.linkedin!.trim();
            final destination = _normalizeUrl(li);
            final displayText = !li.toLowerCase().contains('linkedin') ? 'LinkedIn: $li' : li;
            contactWidgets.add(
              pw.UrlLink(
                destination: destination,
                child: pw.Text(
                  _cleanPdfText(displayText),
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: PdfColors.blue700,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
            );
          }

          if (resume.github != null && resume.github!.trim().isNotEmpty) {
            final gh = resume.github!.trim();
            final destination = _normalizeUrl(gh);
            final displayText = !gh.toLowerCase().contains('github') ? 'GitHub: $gh' : gh;
            contactWidgets.add(
              pw.UrlLink(
                destination: destination,
                child: pw.Text(
                  _cleanPdfText(displayText),
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: PdfColors.blue700,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
            );
          }

          final contactWidgetsWithSeparators = <pw.Widget>[];
          for (int i = 0; i < contactWidgets.length; i++) {
            contactWidgetsWithSeparators.add(contactWidgets[i]);
            if (i < contactWidgets.length - 1) {
              contactWidgetsWithSeparators.add(
                pw.Text('  |  ', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600)),
              );
            }
          }

          final cleanName = _cleanPdfText(resume.fullName.trim());
          final cleanTitle = resume.title != null ? _cleanPdfText(resume.title!.trim()) : '';

          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(cleanName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  if (cleanTitle.isNotEmpty)
                    pw.Text(cleanTitle, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                  if (contactWidgetsWithSeparators.isNotEmpty)
                    pw.Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: contactWidgetsWithSeparators,
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 6),
            ...pageBody,
          ];
        },
      ),
    );

    late File file;
    String locationName = 'Downloads';
    
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getDownloadsDirectory();
      }
      directory ??= await getApplicationDocumentsDirectory();

      final nameSanitized = resume.fullName.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      final standardFile = File('${directory.path}/${nameSanitized}_by_vyaas_ai.pdf');
      
      try {
        await standardFile.writeAsBytes(await pdf.save());
        file = standardFile;
        locationName = 'Downloads';
      } catch (writeError) {
        // If writing standard file fails, try appending a timestamp
        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final uniqueFile = File('${directory.path}/${nameSanitized}_by_vyaas_ai_$timestamp.pdf');
          await uniqueFile.writeAsBytes(await pdf.save());
          file = uniqueFile;
          locationName = 'Downloads';
        } catch (innerError) {
          // Fallback to app documents directory
          final fallbackDir = await getApplicationDocumentsDirectory();
          final fallbackFile = File('${fallbackDir.path}/${nameSanitized}_by_vyaas_ai.pdf');
          await fallbackFile.writeAsBytes(await pdf.save());
          file = fallbackFile;
          locationName = 'App Documents';
        }
      }
    } catch (e) {
      // General fallback
      try {
        final fallbackDir = await getApplicationDocumentsDirectory();
        final nameSanitized = resume.fullName.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        final fallbackFile = File('${fallbackDir.path}/${nameSanitized}_by_vyaas_ai.pdf');
        await fallbackFile.writeAsBytes(await pdf.save());
        file = fallbackFile;
        locationName = 'App Documents';
      } catch (fallbackError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save PDF: $fallbackError')),
        );
        return;
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Text('Resume saved to $locationName:\n${file.path}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await OpenFilex.open(file.path);
                } catch (openError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open PDF: $openError')),
                  );
                }
              },
              child: const Text('Open PDF'),
            ),
          ],
        ),
      );
  }

  List<pw.Widget> _buildPdfSkills(Map<String, List<String>> skills, pw.Font baseFont, pw.Font boldFont) {
    return skills.entries.map((entry) {
      final keyText = _cleanPdfText(entry.key.trim());
      final valueText = _cleanPdfText(entry.value.map((v) => v.trim()).where((v) => v.isNotEmpty).join(', '));
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2.5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 3.5, right: 6),
              width: 4,
              height: 4,
              decoration: const pw.BoxDecoration(
                color: PdfColors.black,
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.Expanded(
              child: pw.RichText(
                maxLines: 1,
                softWrap: false,
                overflow: pw.TextOverflow.clip,
                text: pw.TextSpan(
                  style: pw.TextStyle(font: baseFont, fontSize: 9),
                  children: [
                    pw.TextSpan(text: keyText, style: pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold)),
                    const pw.TextSpan(text: ' : '),
                    pw.TextSpan(text: valueText),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<String> _splitIntoBullets(String text) {
    if (text.trim().isEmpty) return [];
    
    // First, split by newlines or list markers
    final rawLines = text.split(RegExp(r'\n+|\r+'));
    final List<String> lines = [];
    
    for (var line in rawLines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // Check if the line has bullet characters or numbers at the start
      // e.g., '•', '-', '*', '1.', etc.
      final match = RegExp(r'^([•\-\*\u2022]|\d+\.)\s*').firstMatch(line);
      if (match != null) {
        line = line.substring(match.end).trim();
      }
      
      if (line.isNotEmpty) {
        lines.add(line);
      }
    }
    
    // If we couldn't split by newlines (got 1 big block), try splitting by sentences.
    if (lines.length <= 1) {
      final singleText = text.trim();
      final sentences = singleText.split(RegExp(r'\.\s+'));
      final List<String> sentenceLines = [];
      for (var s in sentences) {
        var trimmed = s.trim();
        if (trimmed.isEmpty) continue;
        
        // Add period back if it was stripped and it's not the end
        if (!trimmed.endsWith('.')) {
          trimmed += '.';
        }
        
        // Remove leading bullet if any
        final match = RegExp(r'^([•\-\*\u2022]|\d+\.)\s*').firstMatch(trimmed);
        if (match != null) {
          trimmed = trimmed.substring(match.end).trim();
        }
        
        if (trimmed.isNotEmpty) {
          sentenceLines.add(trimmed);
        }
      }
      if (sentenceLines.isNotEmpty) {
        return sentenceLines;
      }
    }
    
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final resume = ref.watch(resumeStateProvider);
    
    if (resume != null && _optimizedResume != null && _originalResumeLastModified != null) {
      if (resume.lastModified.isAfter(_originalResumeLastModified!)) {
        _optimizedResume = null;
        _originalResumeLastModified = null;
      }
    }
    
    // Auto-populate inputs if state is initialized
    if (resume != null && !_isInitialized) {
      _initControllers(resume);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Hub'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentIndigo,
          tabs: const [
            Tab(text: 'Builder Form', icon: Icon(Icons.edit_note_rounded)),
            Tab(text: 'JD Optimizer', icon: Icon(Icons.analytics_rounded)),
            Tab(text: 'Preview & Export', icon: Icon(Icons.print_rounded)),
          ],
        ),
      ),
      body: resume == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBuilderTab(resume),
                _buildOptimizerTab(),
                _buildPreviewTab(resume),
              ],
            ),
    );
  }

  Future<void> _generateObjective() async {
    final jdText = _jdController.text.trim();
    if (jdText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a Job Description first.')),
      );
      return;
    }

    final manager = ref.read(aiProvider.notifier);
    final activeType = manager.activeType;
    final key = await manager.getApiKey(activeType);
    if (key == null || key.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key Required'),
          content: Text('Please add your ${activeType == AIProviderType.gemini ? "Gemini" : "NVIDIA NIM"} API key in settings before generating an objective.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(appShellIndexProvider.notifier).state = 4;
              },
              child: const Text('Configure Settings'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isGeneratingObjective = true);
    try {
      final resume = ref.read(resumeStateProvider);
      if (resume == null) return;
      
      final aiService = ref.read(resumeAIServiceProvider);
      final objective = await aiService.generateObjective(jdText, resume);
      
      setState(() {
        _objectiveController.text = objective;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate objective automatically. Please try again or type it manually.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      setState(() => _isGeneratingObjective = false);
    }
  }

  String _getSectionName(String section) {
    switch (section) {
      case 'personal':
        return 'Personal Details';
      case 'experience':
        return 'Work Experience';
      case 'education':
        return 'Education';
      case 'objective':
        return 'Objective';
      case 'skills':
        return 'Skills';
      case 'projects':
        return 'Projects';
      case 'certifications':
        return 'Certifications';
      case 'achievements':
        return 'Achievements';
      default:
        return section;
    }
  }

  Widget _buildSequenceControls() {
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_vert_rounded, color: AppColors.accentIndigo),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Arrange Section Sequence',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Drag items or use arrows to change the layout sequence in the form & PDF:',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sectionOrder.length,
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                final item = _sectionOrder.removeAt(oldIndex);
                _sectionOrder.insert(newIndex, item);
                _saveSectionOrder();
              });
            },
            itemBuilder: (context, index) {
              final section = _sectionOrder[index];
              final displayName = _getSectionName(section);
              return Container(
                key: ValueKey(section),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.drag_handle_rounded, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index > 0)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                final item = _sectionOrder.removeAt(index);
                                _sectionOrder.insert(index - 1, item);
                                _saveSectionOrder();
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.arrow_upward_rounded, size: 16),
                            ),
                          ),
                        const SizedBox(width: 4),
                        if (index < _sectionOrder.length - 1)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                final item = _sectionOrder.removeAt(index);
                                _sectionOrder.insert(index + 1, item);
                                _saveSectionOrder();
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.arrow_downward_rounded, size: 16),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBuilderTab(Resume resume) {
    final List<Widget> sectionWidgets = [];

    sectionWidgets.add(_buildImportResumeCard());
    sectionWidgets.add(const SizedBox(height: 16));

    sectionWidgets.add(_buildSequenceControls());
    sectionWidgets.add(const SizedBox(height: 16));

    for (final section in _sectionOrder) {
      switch (section) {
        case 'personal':
          sectionWidgets.add(_buildPersonalDetailsAccordion());
          break;
        case 'experience':
          sectionWidgets.add(_buildExperienceAccordion());
          break;
        case 'education':
          sectionWidgets.add(_buildEducationAccordion());
          break;
        case 'objective':
          sectionWidgets.add(_buildObjectiveAccordion());
          break;
        case 'skills':
          sectionWidgets.add(_buildSkillsAccordion());
          break;
        case 'projects':
          sectionWidgets.add(_buildProjectsAccordion());
          break;
        case 'certifications':
          sectionWidgets.add(_buildCertificationsAccordion());
          break;
        case 'achievements':
          sectionWidgets.add(_buildAchievementsAccordion());
          break;
      }
      sectionWidgets.add(const SizedBox(height: 16));
    }

    if (sectionWidgets.isNotEmpty) {
      sectionWidgets.removeLast();
    }

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text('Fill out your resume information locally:', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        ...sectionWidgets,
      ],
    );
  }

  Widget _buildPersonalDetailsAccordion() {
    return _buildAccordionTile(
      title: 'Personal Details',
      icon: Icons.person_outline_rounded,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Professional Title'),
        ),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email Address'),
        ),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone Number'),
        ),
        TextField(
          controller: _websiteController,
          decoration: const InputDecoration(labelText: 'Website'),
        ),
        TextField(
          controller: _linkedinController,
          decoration: const InputDecoration(labelText: 'LinkedIn Profile URL'),
        ),
        TextField(
          controller: _githubController,
          decoration: const InputDecoration(labelText: 'GitHub Profile URL'),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () async {
              await ref.read(resumeStateProvider.notifier).updateField(
                fullName: _nameController.text,
                title: _titleController.text,
                email: _emailController.text,
                phone: _phoneController.text,
                website: _websiteController.text,
                linkedin: _linkedinController.text,
                github: _githubController.text,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Personal Details confirmed & saved!'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentIndigo,
              foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
            ),
            child: const Text('Confirm & Save Details'),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceAccordion() {
    return _buildAccordionTile(
      title: 'Work Experience',
      icon: Icons.work_outline_rounded,
      children: [
        ..._buildLocalExperiencesList(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Experience'),
              onPressed: _showAddExperienceDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slateCard,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(resumeStateProvider.notifier).updateField(
                  experience: _localExperiences,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Work Experience confirmed & saved!'),
                    backgroundColor: AppColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentIndigo,
                foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
              ),
              child: const Text('Confirm & Save Section'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildLocalExperiencesList() {
    if (_localExperiences.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('No experience items added.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        )
      ];
    }
    return List<Widget>.generate(_localExperiences.length, (index) {
      final exp = _localExperiences[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${exp.company} - ${exp.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(exp.duration, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(exp.description, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.errorRed),
              onPressed: () {
                setState(() {
                  _localExperiences.removeAt(index);
                });
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEducationAccordion() {
    return _buildAccordionTile(
      title: 'Education',
      icon: Icons.school_rounded,
      children: [
        ..._buildLocalEducationList(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Education'),
              onPressed: _showAddEducationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slateCard,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(resumeStateProvider.notifier).updateField(
                  education: _localEducation,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Education details confirmed & saved!'),
                    backgroundColor: AppColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentIndigo,
                foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
              ),
              child: const Text('Confirm & Save Section'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildLocalEducationList() {
    if (_localEducation.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('No education items added.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        )
      ];
    }
    return List<Widget>.generate(_localEducation.length, (index) {
      final edu = _localEducation[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(edu.school, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${edu.degree} (${edu.duration})', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.errorRed),
              onPressed: () {
                setState(() {
                  _localEducation.removeAt(index);
                });
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildObjectiveAccordion() {
    return _buildAccordionTile(
      title: 'Objective',
      icon: Icons.psychology_outlined,
      children: [
        TextField(
          controller: _jdController,
          minLines: 3,
          maxLines: 10,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            labelText: 'Job Description',
            hintText: 'Paste the job description here...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Tooltip(
              message: 'Uses Gemini/NVIDIA to tailor your objective to the job description',
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate AI Summary'),
                onPressed: _generateObjective,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
                ),
              ),
            ),
            if (_isGeneratingObjective) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _objectiveController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Tailored Objective',
            hintText: 'Generated or custom summary text...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () async {
              await ref.read(resumeStateProvider.notifier).updateField(
                aiObjective: _objectiveController.text,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Objective confirmed & saved!'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentIndigo,
              foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
            ),
            child: const Text('Confirm & Save Objective'),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsAccordion() {
    return _buildAccordionTile(
      title: 'Skills',
      icon: Icons.grade_outlined,
      children: [
        ..._buildLocalSkillCategories(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
              onPressed: _showAddCategoryDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slateCard,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(resumeStateProvider.notifier).updateField(
                  skills: _localSkills,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Skills confirmed & saved!'),
                    backgroundColor: AppColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentIndigo,
                foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
              ),
              child: const Text('Confirm & Save Skills'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildLocalSkillCategories() {
    if (_localSkills.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('No skill categories added.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        )
      ];
    }
    return _localSkills.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () => _showEditCategoryDialog(entry.key),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 16, color: AppColors.errorRed),
                  onPressed: () {
                    setState(() {
                      _localSkills.remove(entry.key);
                    });
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 4,
              children: entry.value.map((skill) {
                return Chip(
                  label: Text(skill),
                  onDeleted: () {
                    setState(() {
                      _localSkills[entry.key]!.remove(skill);
                      if (_localSkills[entry.key]!.isEmpty) {
                        _localSkills.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Skill'),
              onPressed: () => _showAddSkillDialog(entry.key),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g., Technical, Leadership'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  if (!_localSkills.containsKey(controller.text)) {
                    _localSkills[controller.text] = [];
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(String oldCategory) {
    final controller = TextEditingController(text: oldCategory);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty && controller.text != oldCategory) {
                setState(() {
                  if (_localSkills.containsKey(oldCategory)) {
                    final skills = _localSkills.remove(oldCategory)!;
                    _localSkills[controller.text] = skills;
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddSkillDialog(String category) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Skill to $category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g., Flutter, Project Management'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  if (_localSkills.containsKey(category)) {
                    _localSkills[category]!.add(controller.text);
                  } else {
                    _localSkills[category] = [controller.text];
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddExperienceDialog() {
    final companyC = TextEditingController();
    final titleC = TextEditingController();
    final durationC = TextEditingController();
    final descC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Experience'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: companyC, decoration: const InputDecoration(labelText: 'Company')),
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: durationC, decoration: const InputDecoration(labelText: 'Duration (e.g. 2022 - Present)')),
              TextField(controller: descC, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _localExperiences.add(WorkExperience(
                  company: companyC.text,
                  title: titleC.text,
                  duration: durationC.text,
                  description: descC.text,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddEducationDialog() {
    final schoolC = TextEditingController();
    final degreeC = TextEditingController();
    final durationC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Education'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: schoolC, decoration: const InputDecoration(labelText: 'School / College')),
            TextField(controller: degreeC, decoration: const InputDecoration(labelText: 'Degree')),
            TextField(controller: durationC, decoration: const InputDecoration(labelText: 'Duration (e.g. 2018 - 2022)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _localEducation.add(Education(
                  school: schoolC.text,
                  degree: degreeC.text,
                  duration: durationC.text,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsAccordion() {
    return _buildAccordionTile(
      title: 'Projects',
      icon: Icons.assignment_outlined,
      children: [
        ..._buildLocalProjectsList(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Project'),
              onPressed: _showAddProjectDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slateCard,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(resumeStateProvider.notifier).updateField(
                  projects: _localProjects,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Projects confirmed & saved!'),
                    backgroundColor: AppColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentIndigo,
                foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
              ),
              child: const Text('Confirm & Save Section'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildLocalProjectsList() {
    if (_localProjects.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('No project items added.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        )
      ];
    }
    return List<Widget>.generate(_localProjects.length, (index) {
      final p = _localProjects[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (p.url != null && p.url!.isNotEmpty)
                    Text(p.url!, style: TextStyle(fontSize: 11, color: AppColors.accentIndigo)),
                  Text(p.year, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(p.description, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.errorRed),
              onPressed: () {
                setState(() {
                  _localProjects.removeAt(index);
                });
              },
            ),
          ],
        ),
      );
    });
  }

  void _showAddProjectDialog() {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final urlC = TextEditingController();
    final yearC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Project Title')),
              TextField(controller: descC, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              TextField(controller: urlC, decoration: const InputDecoration(labelText: 'Project URL (Optional)')),
              TextField(controller: yearC, decoration: const InputDecoration(labelText: 'Year')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (titleC.text.isNotEmpty) {
                setState(() {
                  _localProjects.add(Project(
                    title: titleC.text,
                    description: descC.text,
                    url: urlC.text.isEmpty ? null : urlC.text,
                    year: yearC.text,
                  ));
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsAccordion() {
    return _buildAccordionTile(
      title: 'Certifications',
      icon: Icons.card_membership_outlined,
      children: [
        ..._buildLocalCertificationsList(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Certification'),
              onPressed: _showAddCertificationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slateCard,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(resumeStateProvider.notifier).updateField(
                  certifications: _localCertifications,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Certifications confirmed & saved!'),
                    backgroundColor: AppColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentIndigo,
                foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
              ),
              child: const Text('Confirm & Save Section'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildLocalCertificationsList() {
    if (_localCertifications.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('No certification items added.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        )
      ];
    }
    return List<Widget>.generate(_localCertifications.length, (index) {
      final c = _localCertifications[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(c.issuer, style: const TextStyle(fontSize: 12)),
                  if (c.url != null && c.url!.isNotEmpty)
                    Text(c.url!, style: TextStyle(fontSize: 11, color: AppColors.accentIndigo)),
                  Text(c.year, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.errorRed),
              onPressed: () {
                setState(() {
                  _localCertifications.removeAt(index);
                });
              },
            ),
          ],
        ),
      );
    });
  }

  void _showAddCertificationDialog() {
    final nameC = TextEditingController();
    final issuerC = TextEditingController();
    final urlC = TextEditingController();
    final yearC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Certification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Certification Name')),
              TextField(controller: issuerC, decoration: const InputDecoration(labelText: 'Issuer')),
              TextField(controller: urlC, decoration: const InputDecoration(labelText: 'URL (Optional)')),
              TextField(controller: yearC, decoration: const InputDecoration(labelText: 'Year')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameC.text.isNotEmpty) {
                setState(() {
                  _localCertifications.add(Certification(
                    name: nameC.text,
                    issuer: issuerC.text,
                    url: urlC.text.isEmpty ? null : urlC.text,
                    year: yearC.text,
                  ));
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsAccordion() {
    return _buildAccordionTile(
      title: 'Achievements',
      icon: Icons.emoji_events_outlined,
      children: [
        ..._buildLocalAchievementsList(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Achievement'),
              onPressed: _showAddAchievementDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slateCard,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(resumeStateProvider.notifier).updateField(
                  achievements: _localAchievements,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Achievements confirmed & saved!'),
                    backgroundColor: AppColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentIndigo,
                foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
              ),
              child: const Text('Confirm & Save Section'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildLocalAchievementsList() {
    if (_localAchievements.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('No achievements added.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        )
      ];
    }
    return List<Widget>.generate(_localAchievements.length, (index) {
      final a = _localAchievements[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(a, style: const TextStyle(fontSize: 12)),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.errorRed),
              onPressed: () {
                setState(() {
                  _localAchievements.removeAt(index);
                });
              },
            ),
          ],
        ),
      );
    });
  }

  void _showAddAchievementDialog() {
    final textC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Achievement'),
        content: TextField(
          controller: textC,
          decoration: const InputDecoration(labelText: 'Achievement Description'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (textC.text.isNotEmpty) {
                setState(() {
                  _localAchievements.add(textC.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optimize Resume for Target Job Description',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Paste the Target Job Description below. The AI will cross-reference your resume fields to extract missing keywords.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _jdController,
            minLines: 4,
            maxLines: 15,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'Paste Job Description text here...',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.slateCard,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: _isOptimizing
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Analyze and Optimize Resume'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPurple,
                      foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _optimizeResume,
                  ),
          ),
          const SizedBox(height: 32),
          Text('Key Optimizer Output Preview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warningAmber, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Missing ATS Keywords:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentIndigo.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('ATS Score: $_atsScore%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _missingKeywords.map((tag) => Chip(label: Text(tag))).toList(),
                ),
                const Divider(color: AppColors.borderTransparent, height: 24),
                const Text('AI Suggestions:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_suggestions, style: const TextStyle(fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTab(Resume resume) {
    final activeResume = (_showOptimized && _optimizedResume != null) ? _optimizedResume! : resume;

    final List<WorkExperience> experiences = (activeResume.experience ?? []).where((exp) =>
      exp.company.trim().isNotEmpty ||
      exp.title.trim().isNotEmpty ||
      exp.duration.trim().isNotEmpty ||
      exp.description.trim().isNotEmpty
    ).toList();

    final List<Education> education = activeResume.education.where((edu) =>
      edu.school.trim().isNotEmpty ||
      edu.degree.trim().isNotEmpty ||
      edu.duration.trim().isNotEmpty
    ).toList();

    final List<Project> projects = activeResume.projects.where((p) =>
      p.title.trim().isNotEmpty ||
      p.description.trim().isNotEmpty ||
      (p.url != null && p.url!.trim().isNotEmpty) ||
      p.year.trim().isNotEmpty
    ).toList();

    final List<Certification> certs = (activeResume.certifications ?? []).where((c) =>
      c.name.trim().isNotEmpty ||
      c.issuer.trim().isNotEmpty ||
      c.year.trim().isNotEmpty ||
      (c.url != null && c.url!.trim().isNotEmpty)
    ).toList();

    final List<String> achievements = (activeResume.achievements ?? []).where((a) =>
      a.trim().isNotEmpty
    ).toList();

    final Map<String, List<String>> filteredSkills = Map<String, List<String>>.fromEntries(
      activeResume.skills.entries.map((entry) {
        final key = entry.key.trim();
        final values = entry.value.map((v) => v.trim()).where((v) => v.isNotEmpty).toList();
        return MapEntry(key, values);
      }).where((entry) =>
        entry.key.isNotEmpty &&
        entry.key.toLowerCase() != 'category_name' &&
        entry.value.isNotEmpty
      )
    );

    TextStyle previewTextStyle({double? fontSize, FontWeight? fontWeight, Color? color, bool highlight = false}) {
      return TextStyle(
        fontFamily: _selectedFont,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Colors.black,
        background: highlight ? (Paint()..color = Colors.amber.withAlpha(70)) : null,
      );
    }

    final List<Widget> previewBody = [];
    
    for (final section in _sectionOrder) {
      if (section == 'objective') {
        if (activeResume.aiObjective != null && activeResume.aiObjective!.trim().isNotEmpty) {
          final isObjectiveChanged = _showOptimized && _optimizedResume != null && activeResume.aiObjective != resume.aiObjective;
          previewBody.addAll([
            Text('OBJECTIVE', style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Divider(color: Colors.black12, height: 8),
            Text(activeResume.aiObjective!.trim(), style: previewTextStyle(fontSize: 10, color: Colors.black87, highlight: isObjectiveChanged), textAlign: TextAlign.justify),
            const SizedBox(height: 12),
          ]);
        }
      } else if (section == 'skills') {
        if (filteredSkills.isNotEmpty) {
          previewBody.addAll([
            Text('SKILLS', style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Divider(color: Colors.black12, height: 8),
            ...filteredSkills.entries.map((entry) {
              final originalCategorySkills = resume.skills[entry.key]?.map((s) => s.trim().toLowerCase()).toList() ?? [];
              final List<InlineSpan> skillSpans = [];
              for (int i = 0; i < entry.value.length; i++) {
                final v = entry.value[i].trim();
                final isNewSkill = _showOptimized && _optimizedResume != null && !originalCategorySkills.contains(v.toLowerCase());
                skillSpans.add(
                  TextSpan(
                    text: v,
                    style: previewTextStyle(fontSize: 9, color: Colors.black87, highlight: isNewSkill),
                  ),
                );
                if (i < entry.value.length - 1) {
                  skillSpans.add(TextSpan(text: ', ', style: previewTextStyle(fontSize: 9)));
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: entry.key.trim(), style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
                            TextSpan(text: ' : ', style: previewTextStyle(fontSize: 9)),
                            ...skillSpans,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ]);
        }
      } else if (section == 'experience') {
        if (experiences.isNotEmpty) {
          previewBody.addAll([
            Text('WORK EXPERIENCE', style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Divider(color: Colors.black12, height: 8),
            ...experiences.asMap().entries.map((entry) {
              final idx = entry.key;
              final exp = entry.value;

              final originalExp = (resume.experience != null && idx < resume.experience!.length) ? resume.experience![idx] : null;
              final isTitleChanged = _showOptimized && _optimizedResume != null && originalExp != null && exp.title.trim() != originalExp.title.trim();
              final isCompanyChanged = _showOptimized && _optimizedResume != null && originalExp != null && exp.company.trim() != originalExp.company.trim();
              final isDescChanged = _showOptimized && _optimizedResume != null && originalExp != null && exp.description.trim() != originalExp.description.trim();

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                if (exp.company.trim().isNotEmpty)
                                  TextSpan(
                                    text: exp.company.trim(),
                                    style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 10, highlight: isCompanyChanged),
                                  ),
                                if (exp.company.trim().isNotEmpty && exp.title.trim().isNotEmpty)
                                  TextSpan(text: ' - ', style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                if (exp.title.trim().isNotEmpty)
                                  TextSpan(
                                    text: exp.title.trim(),
                                    style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 10, highlight: isTitleChanged),
                                  ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (exp.duration.trim().isNotEmpty)
                          Text(exp.duration.trim(), style: previewTextStyle(fontSize: 9, color: Colors.grey[700])),
                      ],
                    ),
                    if (exp.description.trim().isNotEmpty)
                      Text(exp.description.trim(), style: previewTextStyle(fontSize: 9, color: Colors.black87, highlight: isDescChanged), textAlign: TextAlign.justify),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ]);
        }
      } else if (section == 'education') {
        if (education.isNotEmpty) {
          previewBody.addAll([
            Text('EDUCATION', style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Divider(color: Colors.black12, height: 8),
            ...education.map((edu) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (edu.school.trim().isNotEmpty)
                            Text(
                              edu.school.trim(),
                              style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (edu.degree.trim().isNotEmpty)
                            Text(
                              edu.degree.trim(),
                              style: previewTextStyle(fontSize: 9, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (edu.duration.trim().isNotEmpty)
                      Text(edu.duration.trim(), style: previewTextStyle(fontSize: 9, color: Colors.grey[700])),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ]);
        }
      } else if (section == 'projects') {
        if (projects.isNotEmpty) {
          previewBody.addAll([
            Text('PROJECTS', style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Divider(color: Colors.black12, height: 8),
            ...projects.asMap().entries.map((entry) {
              final idx = entry.key;
              final p = entry.value;

              final originalProj = (idx < resume.projects.length) ? resume.projects[idx] : null;
              final isTitleChanged = _showOptimized && _optimizedResume != null && originalProj != null && p.title.trim() != originalProj.title.trim();
              final isDescChanged = _showOptimized && _optimizedResume != null && originalProj != null && p.description.trim() != originalProj.description.trim();

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: p.title.trim(),
                                  style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 10, highlight: isTitleChanged),
                                ),
                                if (p.url != null && p.url!.trim().isNotEmpty)
                                  TextSpan(text: ' (${p.url!.trim()})', style: previewTextStyle(fontSize: 10)),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (p.year.trim().isNotEmpty)
                          Text(p.year.trim(), style: previewTextStyle(fontSize: 9, color: Colors.grey[700])),
                      ],
                    ),
                    if (p.description.trim().isNotEmpty)
                      Text(p.description.trim(), style: previewTextStyle(fontSize: 9, color: Colors.black87, highlight: isDescChanged), textAlign: TextAlign.justify),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ]);
        }
      } else if (section == 'certifications') {
        if (certs.isNotEmpty) {
          previewBody.addAll([
            Text('CERTIFICATIONS', style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Divider(color: Colors.black12, height: 8),
            ...certs.map((c) {
              final issuerParts = [
                if (c.issuer.trim().isNotEmpty) c.issuer.trim(),
                if (c.url != null && c.url!.trim().isNotEmpty) '(${c.url!.trim()})',
              ];
              final issuerText = issuerParts.join(' ');
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (c.name.trim().isNotEmpty)
                            Text(
                              c.name.trim(),
                              style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (issuerText.isNotEmpty)
                            Text(
                              issuerText,
                              style: previewTextStyle(fontSize: 9, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (c.year.trim().isNotEmpty)
                      Text(c.year.trim(), style: previewTextStyle(fontSize: 9, color: Colors.grey[700])),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ]);
        }
      } else if (section == 'achievements') {
        if (achievements.isNotEmpty) {
          previewBody.addAll([
            Text('ACHIEVEMENTS', style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Divider(color: Colors.black12, height: 8),
            ...achievements.asMap().entries.map((entry) {
              final idx = entry.key;
              final a = entry.value;
              final originalAch = (resume.achievements != null && idx < resume.achievements!.length) ? resume.achievements![idx] : null;
              final isAchChanged = _showOptimized && _optimizedResume != null && (originalAch == null || a.trim() != originalAch.trim());

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    Expanded(
                      child: Text(a.trim(), style: previewTextStyle(fontSize: 9, color: Colors.black87, highlight: isAchChanged), textAlign: TextAlign.justify),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ]);
        }
      }
    }

    final contactInfoList = <String>[];
    if (resume.email.trim().isNotEmpty) contactInfoList.add(resume.email.trim());
    if (resume.phone.trim().isNotEmpty) contactInfoList.add(resume.phone.trim());
    if (resume.website != null && resume.website!.trim().isNotEmpty) contactInfoList.add(resume.website!.trim());
    if (resume.linkedin != null && resume.linkedin!.trim().isNotEmpty) {
      final li = resume.linkedin!.trim();
      if (!li.toLowerCase().contains('linkedin')) {
        contactInfoList.add('LinkedIn: $li');
      } else {
        contactInfoList.add(li);
      }
    }
    if (resume.github != null && resume.github!.trim().isNotEmpty) {
      final gh = resume.github!.trim();
      if (!gh.toLowerCase().contains('github')) {
        contactInfoList.add('GitHub: $gh');
      } else {
        contactInfoList.add(gh);
      }
    }
    final contactInfo = contactInfoList.join('  |  ');

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Font Style: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _selectedFont,
                    items: const [
                      DropdownMenuItem(value: 'Times New Roman', child: Text('Times New Roman', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Helvetica/Arial', child: Text('Helvetica/Arial', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Courier', child: Text('Courier', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedFont = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('One Page Rule', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Switch(
                    value: true,
                    onChanged: (_) {},
                    activeThumbColor: AppColors.accentIndigo,
                  ),
                ],
              ),
            ],
          ),
          if (_optimizedResume != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentIndigo.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentIndigo.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: AppColors.accentIndigo),
                          const SizedBox(width: 8),
                          Text(
                            _showOptimized ? 'Showing Optimized Resume (Diffs Highlighted)' : 'Showing Original Resume',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Show Optimized', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Switch(
                            value: _showOptimized,
                            onChanged: (val) {
                              setState(() {
                                _showOptimized = val;
                              });
                            },
                            activeColor: AppColors.accentIndigo,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.close_rounded, size: 14),
                        label: const Text('Reject & Re-Optimize', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorRed,
                          side: const BorderSide(color: AppColors.errorRed),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          setState(() {
                            _optimizedResume = null;
                            _showOptimized = false;
                          });
                          _optimizeResume();
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded, size: 14),
                        label: const Text('Accept & Edit Fields', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () async {
                          final opt = _optimizedResume;
                          if (opt == null) return;
                          
                          setState(() => _isOptimizing = true);
                          try {
                            await ref.read(resumeStateProvider.notifier).updateField(
                              fullName: opt.fullName,
                              title: opt.title,
                              email: opt.email,
                              phone: opt.phone,
                              website: opt.website,
                              linkedin: opt.linkedin,
                              github: opt.github,
                              aiObjective: opt.aiObjective,
                              skills: opt.skills,
                              experience: opt.experience,
                              education: opt.education,
                              projects: opt.projects,
                              certifications: opt.certifications,
                              achievements: opt.achievements,
                            );
                            
                            setState(() {
                              _optimizedResume = null;
                              _showOptimized = false;
                            });
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Optimized version accepted! Fields updated for manual editing.'),
                                  backgroundColor: AppColors.successGreen,
                                ),
                              );
                              _tabController.animateTo(1);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to accept optimized version.'),
                                  backgroundColor: AppColors.errorRed,
                                ),
                              );
                            }
                          } finally {
                            setState(() => _isOptimizing = false);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activeResume.fullName, style: previewTextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    if (activeResume.title != null && activeResume.title!.trim().isNotEmpty)
                      Text(
                        activeResume.title!.trim(),
                        style: previewTextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          highlight: _showOptimized && _optimizedResume != null && activeResume.title != resume.title,
                        ),
                      ),
                    if (contactInfo.isNotEmpty)
                      Text(contactInfo, style: previewTextStyle(fontSize: 10, color: Colors.black54)),
                    const Divider(color: Colors.black12, height: 16),
                    ...previewBody,
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Export PDF'),
                onPressed: () => _exportPdfFile(activeResume),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentIndigo,
                  foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionTile({required String title, required IconData icon, required List<Widget> children}) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: AppColors.accentIndigo),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          childrenPadding: const EdgeInsets.all(16.0),
          children: children,
        ),
      ),
    );
  }
}

class _PartialJsonParser {
  final String _input;
  int _pos = 0;

  _PartialJsonParser(this._input);

  dynamic parse() {
    _skipWhitespace();
    if (_pos >= _input.length) return null;
    return _parseValue();
  }

  void _skipWhitespace() {
    while (_pos < _input.length) {
      final c = _input[_pos];
      if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
        _pos++;
      } else {
        break;
      }
    }
  }

  dynamic _parseValue() {
    _skipWhitespace();
    if (_pos >= _input.length) return null;
    final c = _input[_pos];
    if (c == '{') {
      return _parseObject();
    } else if (c == '[') {
      return _parseArray();
    } else if (c == '"') {
      return _parseString();
    } else if (c == 't' || c == 'f') {
      return _parseBool();
    } else if (c == 'n') {
      return _parseNull();
    } else if ((c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) || c == '-') {
      return _parseNumber();
    }
    return null;
  }

  Map<String, dynamic> _parseObject() {
    final map = <String, dynamic>{};
    _pos++; // skip '{'
    while (true) {
      _skipWhitespace();
      if (_pos >= _input.length) return map;
      if (_input[_pos] == '}') {
        _pos++;
        return map;
      }
      
      if (_input[_pos] != '"') {
        return map;
      }
      final key = _parseString();
      if (key == null) return map;

      _skipWhitespace();
      if (_pos >= _input.length || _input[_pos] != ':') {
        map[key] = null;
        return map;
      }
      _pos++; // skip ':'

      _skipWhitespace();
      if (_pos >= _input.length) {
        map[key] = null;
        return map;
      }

      final val = _parseValue();
      map[key] = val;

      _skipWhitespace();
      if (_pos >= _input.length) return map;
      if (_input[_pos] == ',') {
        _pos++;
      } else if (_input[_pos] == '}') {
        _pos++;
        return map;
      } else {
        return map;
      }
    }
  }

  List<dynamic> _parseArray() {
    final list = <dynamic>[];
    _pos++; // skip '['
    while (true) {
      _skipWhitespace();
      if (_pos >= _input.length) return list;
      if (_input[_pos] == ']') {
        _pos++;
        return list;
      }

      final val = _parseValue();
      if (val != null || _pos < _input.length) {
        list.add(val);
      }

      _skipWhitespace();
      if (_pos >= _input.length) return list;
      if (_input[_pos] == ',') {
        _pos++;
      } else if (_input[_pos] == ']') {
        _pos++;
        return list;
      } else {
        return list;
      }
    }
  }

  String? _parseString() {
    if (_pos >= _input.length || _input[_pos] != '"') return null;
    _pos++; // skip opening '"'
    final sb = StringBuffer();
    bool escaped = false;
    while (_pos < _input.length) {
      final c = _input[_pos];
      if (escaped) {
        if (c == 'n') sb.write('\n');
        else if (c == 't') sb.write('\t');
        else if (c == 'r') sb.write('\r');
        else sb.write(c);
        escaped = false;
        _pos++;
        continue;
      }
      if (c == '\\') {
        escaped = true;
        _pos++;
        continue;
      }
      if (c == '"') {
        _pos++; // skip closing '"'
        return sb.toString();
      }
      sb.write(c);
      _pos++;
    }
    return sb.toString();
  }

  bool? _parseBool() {
    if (_pos >= _input.length) return null;
    if (_input.startsWith('true', _pos)) {
      _pos += 4;
      return true;
    }
    if (_input.startsWith('false', _pos)) {
      _pos += 5;
      return false;
    }
    if (_input.startsWith('tr', _pos) || _input.startsWith('tru', _pos)) {
      _pos = _input.length;
      return true;
    }
    if (_input.startsWith('fa', _pos) || _input.startsWith('fal', _pos) || _input.startsWith('fals', _pos)) {
      _pos = _input.length;
      return false;
    }
    return null;
  }

  dynamic _parseNull() {
    if (_pos >= _input.length) return null;
    if (_input.startsWith('null', _pos)) {
      _pos += 4;
    } else {
      _pos = _input.length;
    }
    return null;
  }

  num? _parseNumber() {
    final start = _pos;
    while (_pos < _input.length) {
      final c = _input[_pos];
      if ((c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) || c == '.' || c == '-' || c == '+' || c == 'e' || c == 'E') {
        _pos++;
      } else {
        break;
      }
    }
    final numStr = _input.substring(start, _pos);
    return num.tryParse(numStr);
  }
}
