class PortfolioData {
  final String name;
  final String title;
  final String bio;
  final List<String> skills;
  final List<String> typewriterTexts;
  final List<MetricData> metrics;
  final List<CollegeDetails> education;
  final List<Experience> experience;
  final List<Project> projects;
  final SocialLinks socialLinks;
  final String resumeLink;
  final String profileImage;

  PortfolioData({
    required this.name,
    this.title = 'Mobile & Web Developer',
    required this.bio,
    required this.skills,
    required this.typewriterTexts,
    required this.metrics,
    required this.education,
    required this.experience,
    required this.projects,
    required this.socialLinks,
    required this.resumeLink,
    this.profileImage = '',
  });

  factory PortfolioData.fromJson(Map<String, dynamic> json) {
    return PortfolioData(
      name: json['name'] ?? '',
      title: json['title'] ?? 'Mobile & Web Developer',
      bio: json['bio'] ?? '',
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      typewriterTexts: json['typewriterTexts'] != null ? List<String>.from(json['typewriterTexts']) : [],
      metrics: (json['metrics'] as List<dynamic>?)
              ?.map((e) => MetricData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      education: (json['education'] as List<dynamic>?)
              ?.map((e) => CollegeDetails.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      experience: (json['experience'] as List<dynamic>?)
              ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      socialLinks: json['socialLinks'] != null ? SocialLinks.fromJson(json['socialLinks']) : SocialLinks(github: '', linkedin: '', email: ''),
      resumeLink: json['resumeLink'] ?? '',
      profileImage: json['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'bio': bio,
      'skills': skills,
      'typewriterTexts': typewriterTexts,
      'metrics': metrics.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'experience': experience.map((e) => e.toJson()).toList(),
      'projects': projects.map((e) => e.toJson()).toList(),
      'socialLinks': socialLinks.toJson(),
      'resumeLink': resumeLink,
      'profileImage': profileImage,
    };
  }

  PortfolioData copyWith({
    String? name,
    String? title,
    String? bio,
    List<String>? skills,
    List<String>? typewriterTexts,
    List<MetricData>? metrics,
    List<CollegeDetails>? education,
    List<Experience>? experience,
    List<Project>? projects,
    SocialLinks? socialLinks,
    String? resumeLink,
    String? profileImage,
  }) {
    return PortfolioData(
      name: name ?? this.name,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      typewriterTexts: typewriterTexts ?? this.typewriterTexts,
      metrics: metrics ?? this.metrics,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      socialLinks: socialLinks ?? this.socialLinks,
      resumeLink: resumeLink ?? this.resumeLink,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}

class Project {
  final String title;
  final String description;
  final String url;
  final String companyName;
  final String role;
  final String imagePath;

  Project({
    required this.title,
    required this.description,
    required this.url,
    this.companyName = '',
    this.role = '',
    this.imagePath = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      companyName: json['companyName'] ?? '',
      role: json['role'] ?? '',
      imagePath: json['imagePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'companyName': companyName,
      'role': role,
      'imagePath': imagePath,
    };
  }

  Project copyWith({
    String? title,
    String? description,
    String? url,
    String? companyName,
    String? role,
    String? imagePath,
  }) {
    return Project(
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      companyName: companyName ?? this.companyName,
      role: role ?? this.role,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class CollegeDetails {
  final String institution;
  final String degree;
  final String year;
  final String imagePath;

  CollegeDetails({
    required this.institution,
    required this.degree,
    required this.year,
    required this.imagePath,
  });

  factory CollegeDetails.fromJson(Map<String, dynamic> json) {
    return CollegeDetails(
      institution: json['institution'] ?? '',
      degree: json['degree'] ?? '',
      year: json['year'] ?? '',
      imagePath: json['imagePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'degree': degree,
      'year': year,
      'imagePath': imagePath,
    };
  }

  CollegeDetails copyWith({
    String? institution,
    String? degree,
    String? year,
    String? imagePath,
  }) {
    return CollegeDetails(
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      year: year ?? this.year,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class Experience {
  final String role;
  final String company;
  final String duration;
  final String description;
  final String imagePath;

  Experience({
    required this.role,
    required this.company,
    required this.duration,
    required this.description,
    this.imagePath = '',
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      role: json['role'] ?? '',
      company: json['company'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['imagePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'company': company,
      'duration': duration,
      'description': description,
      'imagePath': imagePath,
    };
  }

  Experience copyWith({
    String? role,
    String? company,
    String? duration,
    String? description,
    String? imagePath,
  }) {
    return Experience(
      role: role ?? this.role,
      company: company ?? this.company,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class SocialLinks {
  final String github;
  final String linkedin;
  final String email;

  SocialLinks({
    required this.github,
    required this.linkedin,
    required this.email,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      github: json['github'] ?? '',
      linkedin: json['linkedin'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'github': github,
      'linkedin': linkedin,
      'email': email,
    };
  }

  SocialLinks copyWith({
    String? github,
    String? linkedin,
    String? email,
  }) {
    return SocialLinks(
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      email: email ?? this.email,
    );
  }
}

class MetricData {
  final String value;
  final String label;

  MetricData({
    required this.value,
    required this.label,
  });

  factory MetricData.fromJson(Map<String, dynamic> json) {
    return MetricData(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }

  MetricData copyWith({
    String? value,
    String? label,
  }) {
    return MetricData(
      value: value ?? this.value,
      label: label ?? this.label,
    );
  }
}
