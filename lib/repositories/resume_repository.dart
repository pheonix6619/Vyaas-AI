import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/resume.dart';

class ResumeRepository {
  final AppDatabase _db;
  ResumeRepository(this._db);

  Resume _mapToDomain(ResumeEntry entry) {
    return Resume(
      id: entry.id,
      fullName: entry.fullName,
      title: entry.title,
      email: entry.email,
      phone: entry.phone,
      website: entry.website,
      linkedin: entry.linkedin,
      github: entry.github,
      objective: entry.objective,
      aiObjective: entry.aiObjective,
      jdText: entry.jdText,
      education: (jsonDecode(entry.education) as List? ?? [])
          .map((e) => Education.fromJson(e))
          .toList(),
      skills: Map<String, List<String>>.from(
        (jsonDecode(entry.skills) as Map? ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      projects: (jsonDecode(entry.projects) as List? ?? [])
          .map((p) => Project.fromJson(p))
          .toList(),
      experience: entry.experience != null
          ? (jsonDecode(entry.experience!) as List? ?? [])
              .map((e) => WorkExperience.fromJson(e))
              .toList()
          : [],
      certifications: entry.certifications != null
          ? (jsonDecode(entry.certifications!) as List? ?? [])
              .map((c) => Certification.fromJson(c))
              .toList()
          : null,
      achievements: entry.achievements != null
          ? List<String>.from(jsonDecode(entry.achievements!))
          : null,
      lastModified: entry.lastModified,
    );
  }

  ResumesCompanion _mapToCompanion(Resume domain) {
    return ResumesCompanion(
      id: domain.id != null ? Value(domain.id!) : const Value.absent(),
      fullName: Value(domain.fullName),
      title: Value(domain.title),
      email: Value(domain.email),
      phone: Value(domain.phone),
      website: Value(domain.website),
      linkedin: Value(domain.linkedin),
      github: Value(domain.github),
      objective: Value(domain.objective),
      aiObjective: Value(domain.aiObjective),
      jdText: Value(domain.jdText),
      education: Value(jsonEncode(domain.education.map((e) => e.toJson()).toList())),
      skills: Value(jsonEncode(domain.skills)),
      projects: Value(jsonEncode(domain.projects.map((p) => p.toJson()).toList())),
      experience: Value(domain.experience != null
          ? jsonEncode(domain.experience!.map((e) => e.toJson()).toList())
          : null),
      certifications: Value(domain.certifications != null
          ? jsonEncode(domain.certifications!.map((c) => c.toJson()).toList())
          : null),
      achievements: Value(domain.achievements != null
          ? jsonEncode(domain.achievements)
          : null),
      lastModified: Value(domain.lastModified),
    );
  }

  Stream<List<Resume>> watchAllResumes() =>
      _db.select(_db.resumes).watch().map((list) => list.map(_mapToDomain).toList());

  Future<Resume?> getFirstResume() async {
    final list = await _db.select(_db.resumes).get();
    return list.isEmpty ? null : _mapToDomain(list.first);
  }

  Future<int> insertResume(Resume domain) =>
      _db.into(_db.resumes).insert(_mapToCompanion(domain));

  Future<void> updateResume(Resume domain) =>
      _db.update(_db.resumes).replace(_mapToCompanion(domain));

  Future<int> deleteResume(int id) =>
      (_db.delete(_db.resumes)..where((t) => t.id.equals(id))).go();
}
