import 'dart:convert';

class WorkExperience {
  final String company;
  final String title;
  final String duration;
  final String description;

  WorkExperience({
    required this.company,
    required this.title,
    required this.duration,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'company': company,
    'title': title,
    'duration': duration,
    'description': description,
  };

  factory WorkExperience.fromJson(Map<String, dynamic> json) => WorkExperience(
    company: json['company'] ?? '',
    title: json['title'] ?? '',
    duration: json['duration'] ?? '',
    description: json['description'] ?? '',
  );
}

class Education {
  final String school;
  final String degree;
  final String duration;

  Education({
    required this.school,
    required this.degree,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
    'school': school,
    'degree': degree,
    'duration': duration,
  };

  factory Education.fromJson(Map<String, dynamic> json) => Education(
    school: json['school'] ?? '',
    degree: json['degree'] ?? '',
    duration: json['duration'] ?? '',
  );
}

class Project {
  final String title;
  final String description;
  final String? url;
  final String year;

  Project({
    required this.title,
    required this.description,
    this.url,
    required this.year,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'url': url,
    'year': year,
  };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    url: json['url'],
    year: json['year'] ?? '',
  );
}

class Certification {
  final String name;
  final String issuer;
  final String year;
  final String? url;

  Certification({
    required this.name,
    required this.issuer,
    required this.year,
    this.url,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'issuer': issuer,
    'year': year,
    'url': url,
  };

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
    name: json['name'] ?? '',
    issuer: json['issuer'] ?? '',
    year: json['year'] ?? '',
    url: json['url'],
  );
}

class Resume {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String? website;
  final String? linkedin;
  final String? github;
  final String? title;
  final String? objective;
  final String? aiObjective;
  final String? jdText;
  final List<Education> education;
  final Map<String, List<String>> skills;
  final List<Project> projects;
  final List<WorkExperience>? experience;
  final List<Certification>? certifications;
  final List<String>? achievements;
  final DateTime lastModified;

  Resume({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.website,
    this.linkedin,
    this.github,
    this.title,
    this.objective,
    this.aiObjective,
    this.jdText,
    required this.education,
    required this.skills,
    required this.projects,
    this.experience,
    this.certifications,
    this.achievements,
    required this.lastModified,
  });

  Resume copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? website,
    String? linkedin,
    String? github,
    String? title,
    String? objective,
    String? aiObjective,
    String? jdText,
    List<Education>? education,
    Map<String, List<String>>? skills,
    List<Project>? projects,
    List<WorkExperience>? experience,
    List<Certification>? certifications,
    List<String>? achievements,
    DateTime? lastModified,
  }) {
    return Resume(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      title: title ?? this.title,
      objective: objective ?? this.objective,
      aiObjective: aiObjective ?? this.aiObjective,
      jdText: jdText ?? this.jdText,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      experience: experience ?? this.experience,
      certifications: certifications ?? this.certifications,
      achievements: achievements ?? this.achievements,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'website': website,
    'linkedin': linkedin,
    'github': github,
    'objective': objective,
    'aiObjective': aiObjective,
    'jdText': jdText,
    'education': education.map((e) => e.toJson()).toList(),
    'skills': skills,
    'projects': projects.map((p) => p.toJson()).toList(),
    'experience': experience?.map((e) => e.toJson()).toList(),
    'certifications': certifications?.map((c) => c.toJson()).toList(),
    'achievements': achievements,
    'lastModified': lastModified.toIso8601String(),
  };

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'],
      linkedin: json['linkedin'],
      github: json['github'],
      objective: json['objective'],
      aiObjective: json['aiObjective'],
      jdText: json['jdText'],
      education: (json['education'] as List? ?? [])
          .map((e) => Education.fromJson(e))
          .toList(),
      skills: Map<String, List<String>>.from(
        (json['skills'] as Map? ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      projects: (json['projects'] as List? ?? [])
          .map((p) => Project.fromJson(p))
          .toList(),
      experience: (json['experience'] as List? ?? [])
          .map((e) => WorkExperience.fromJson(e))
          .toList(),
      certifications: (json['certifications'] as List? ?? [])
          .map((c) => Certification.fromJson(c))
          .toList(),
      achievements: json['achievements'] != null
          ? List<String>.from(json['achievements'])
          : null,
      lastModified: DateTime.parse(json['lastModified'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Helper to convert Resume to Drift-compatible JSON strings
String resumeToJson(Resume resume) => jsonEncode(resume.toJson());

Resume resumeFromJson(String jsonStr) => Resume.fromJson(jsonDecode(jsonStr));