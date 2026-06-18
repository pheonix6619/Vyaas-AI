
class PdfFontScaler {
  static const double _minFontSize = 8.0;
  static const double _maxFontSize = 12.0;

  static double calculateScaleFactor({
    required int contentHeightEstimate,
    required int availableHeight,
  }) {
    if (contentHeightEstimate <= availableHeight) {
      return 1.0;
    }
    return availableHeight / contentHeightEstimate;
  }

  static double scaleFontSize(double baseSize, double scaleFactor) {
    final scaled = baseSize * scaleFactor;
    return scaled.clamp(_minFontSize, _maxFontSize);
  }

  static Map<String, double> getScaledFontSizes({
    required bool onePageRule,
    required int estimatedLines,
    required int maxLinesPerPage,
  }) {
    if (!onePageRule) {
      return _getBaseFontSizes();
    }

    final scaleFactor = calculateScaleFactor(
      contentHeightEstimate: estimatedLines,
      availableHeight: maxLinesPerPage,
    );

    final baseSizes = _getBaseFontSizes();
    final scaled = <String, double>{};
    
    baseSizes.forEach((key, value) {
      scaled[key] = scaleFontSize(value, scaleFactor);
    });

    return scaled;
  }

  static Map<String, double> _getBaseFontSizes() {
    return {
      'heading': 11.0,
      'subHeading': 9.5,
      'body': 9.0,
      'small': 8.5,
      'tiny': 8.0,
    };
  }

  static int estimateContentLines({
    required ResumeContent resume,
    required double scaleFactor,
  }) {
    int lines = 0;
    
    if (resume.objective?.isNotEmpty == true) {
      lines += 3 + (resume.objective!.length / 80).ceil();
    }
    
    if (resume.skills.isNotEmpty) {
      lines += 2;
      resume.skills.forEach((category, skills) {
        lines += 1 + (skills.length * 0.5).ceil();
      });
    }
    
    if (resume.experiences.isNotEmpty) {
      lines += 2;
      for (final exp in resume.experiences) {
        lines += 2 + (exp.description.length / 70).ceil();
      }
    }
    
    if (resume.education.isNotEmpty) {
      lines += 2;
      lines += resume.education.length * 1.5.ceil();
    }
    
    if (resume.projects.isNotEmpty) {
      lines += 2;
      for (final proj in resume.projects) {
        lines += 1 + (proj.description.length / 70).ceil();
      }
    }
    
    if (resume.certifications.isNotEmpty) {
      lines += 2;
      lines += resume.certifications.length;
    }
    
    if (resume.achievements.isNotEmpty) {
      lines += 2;
      lines += resume.achievements.length;
    }

    return (lines * scaleFactor).round();
  }
}

class ResumeContent {
  final String? objective;
  final Map<String, List<String>> skills;
  final List<ExperienceContent> experiences;
  final List<EducationContent> education;
  final List<ProjectContent> projects;
  final List<CertificationContent> certifications;
  final List<String> achievements;

  ResumeContent({
    this.objective,
    required this.skills,
    required this.experiences,
    required this.education,
    required this.projects,
    required this.certifications,
    required this.achievements,
  });
}

class ExperienceContent {
  final String company;
  final String title;
  final String duration;
  final String description;

  ExperienceContent({
    required this.company,
    required this.title,
    required this.duration,
    required this.description,
  });
}

class EducationContent {
  final String school;
  final String degree;
  final String duration;

  EducationContent({
    required this.school,
    required this.degree,
    required this.duration,
  });
}

class ProjectContent {
  final String title;
  final String description;
  final String year;

  ProjectContent({
    required this.title,
    required this.description,
    required this.year,
  });
}

class CertificationContent {
  final String name;
  final String issuer;
  final String year;

  CertificationContent({
    required this.name,
    required this.issuer,
    required this.year,
  });
}