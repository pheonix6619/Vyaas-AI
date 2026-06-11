import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resume.dart';
import '../database/providers.dart';
import '../repositories/resume_repository.dart';

final resumeStateProvider = StateNotifierProvider<ResumeNotifier, Resume?>((ref) {
  final repo = ref.watch(resumeRepositoryProvider);
  return ResumeNotifier(repo);
});

class ResumeNotifier extends StateNotifier<Resume?> {
  final ResumeRepository _repo;

  ResumeNotifier(this._repo) : super(null) {
    _loadResume();
  }

  Future<void> _loadResume() async {
    final resume = await _repo.getFirstResume();
    if (resume != null) {
      state = resume;
    } else {
      // Initialize a default empty resume
      final now = DateTime.now();
      final defaultResume = Resume(
        fullName: 'John Doe',
        email: 'johndoe@email.com',
        phone: '+1234567890',
        education: [
          Education(school: 'University', degree: 'Computer Science', duration: '2020-2024'),
        ],
        skills: {'Technical': ['Flutter', 'Dart']},
        projects: [],
        lastModified: now,
      );
      state = defaultResume;
      await _repo.insertResume(defaultResume);
    }
  }

  Future<void> updateField({
    String? fullName,
    String? title,
    String? email,
    String? phone,
    String? website,
    String? linkedin,
    String? github,
    String? aiObjective,
    Map<String, List<String>>? skills,
    List<WorkExperience>? experience,
    List<Education>? education,
    List<Project>? projects,
    List<Certification>? certifications,
    List<String>? achievements,
  }) async {
    final current = state;
    if (current == null) return;

    final updated = Resume(
      id: current.id,
      fullName: fullName ?? current.fullName,
      email: email ?? current.email,
      phone: phone ?? current.phone,
      website: website ?? current.website,
      linkedin: linkedin ?? current.linkedin,
      github: github ?? current.github,
      title: title ?? current.title,
      aiObjective: aiObjective ?? current.aiObjective,
      education: education ?? current.education,
      skills: skills ?? current.skills,
      projects: projects ?? current.projects,
      experience: experience ?? current.experience,
      certifications: certifications ?? current.certifications,
      achievements: achievements ?? current.achievements,
      lastModified: DateTime.now(),
    );

    state = updated;
    await _repo.updateResume(updated);
  }

  Future<void> addSkillCategory(String category) async {
    final current = state;
    if (current == null) return;

    final updatedSkills = Map<String, List<String>>.from(current.skills);
    if (!updatedSkills.containsKey(category)) {
      updatedSkills[category] = [];
    }

    final updated = current.copyWith(
      skills: updatedSkills,
      lastModified: DateTime.now(),
    );

    state = updated;
    await _repo.updateResume(updated);
  }

  Future<void> removeSkillCategory(String category) async {
    final current = state;
    if (current == null) return;

    final updatedSkills = Map<String, List<String>>.from(current.skills);
    updatedSkills.remove(category);

    final updated = current.copyWith(
      skills: updatedSkills,
      lastModified: DateTime.now(),
    );

    state = updated;
    await _repo.updateResume(updated);
  }

  Future<void> addSkill(String category, String skill) async {
    final current = state;
    if (current == null) return;

    final updatedSkills = Map<String, List<String>>.from(current.skills);
    if (updatedSkills.containsKey(category)) {
      updatedSkills[category] = [...updatedSkills[category]!, skill];
    } else {
      updatedSkills[category] = [skill];
    }

    final updated = current.copyWith(
      skills: updatedSkills,
      lastModified: DateTime.now(),
    );

    state = updated;
    await _repo.updateResume(updated);
  }

  Future<void> removeSkill(String category, String skill) async {
    final current = state;
    if (current == null) return;

    final updatedSkills = Map<String, List<String>>.from(current.skills);
    if (updatedSkills.containsKey(category)) {
      updatedSkills[category] = updatedSkills[category]!.where((s) => s != skill).toList();
      if (updatedSkills[category]!.isEmpty) {
        updatedSkills.remove(category);
      }
    }

    final updated = current.copyWith(
      skills: updatedSkills,
      lastModified: DateTime.now(),
    );

    state = updated;
    await _repo.updateResume(updated);
  }

  Future<void> renameSkillCategory(String oldCategory, String newCategory) async {
    final current = state;
    if (current == null) return;

    final updatedSkills = Map<String, List<String>>.from(current.skills);
    if (updatedSkills.containsKey(oldCategory)) {
      final skills = updatedSkills.remove(oldCategory)!;
      updatedSkills[newCategory] = skills;
    }

    final updated = current.copyWith(
      skills: updatedSkills,
      lastModified: DateTime.now(),
    );

    state = updated;
    await _repo.updateResume(updated);
  }



  // Existing methods for experience/education remain unchanged...
  Future<void> addExperience(WorkExperience experience) async {
    final current = state;
    if (current == null) return;

    final updated = current.copyWith(
      experience: [...current.experience ?? [], experience],
      lastModified: DateTime.now(),
    );

    state = updated;
    await _repo.updateResume(updated);
  }

  Future<void> removeExperience(int index) async {
    final current = state;
    if (current == null || current.experience == null) return;

    final updatedExperience = [...current.experience!];
    updatedExperience.removeAt(index);

    final updated = current.copyWith(
      experience: updatedExperience,
      lastModified: DateTime.now(),
    );

    state = updated;
    await _repo.updateResume(updated);
  }

  Future<void> addEducation(Education edu) async {
    final current = state;
    if (current == null) return;

    final updated = current.copyWith(
      education: [...current.education, edu],
      lastModified: DateTime.now(),
    );

    state = updated;
    await _repo.updateResume(updated);
  }

  Future<void> removeEducation(int index) async {
    final current = state;
    if (current == null) return;

    final updatedEducation = [...current.education];
    updatedEducation.removeAt(index);

    final updated = current.copyWith(
      education: updatedEducation,
      lastModified: DateTime.now(),
    );

    state = updated;
    await _repo.updateResume(updated);
  }
}