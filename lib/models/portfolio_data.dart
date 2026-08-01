class PortfolioData {
  final String name;
  final String bio;
  final List<String> skills;
  final CollegeDetails? collegeDetails;
  final List<Project> projects;

  PortfolioData({
    required this.name,
    required this.bio,
    required this.skills,
    this.collegeDetails,
    required this.projects,
  });

  factory PortfolioData.fromJson(Map<String, dynamic> json) {
    return PortfolioData(
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      collegeDetails: json['collegeDetails'] != null ? CollegeDetails.fromJson(json['collegeDetails']) : null,
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'skills': skills,
      'collegeDetails': collegeDetails?.toJson(),
      'projects': projects.map((e) => e.toJson()).toList(),
    };
  }

  PortfolioData copyWith({
    String? name,
    String? bio,
    List<String>? skills,
    CollegeDetails? collegeDetails,
    List<Project>? projects,
  }) {
    return PortfolioData(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      collegeDetails: collegeDetails ?? this.collegeDetails,
      projects: projects ?? this.projects,
    );
  }
}

class Project {
  final String title;
  final String description;
  final String url;

  Project({
    required this.title,
    required this.description,
    required this.url,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
    };
  }

  Project copyWith({
    String? title,
    String? description,
    String? url,
  }) {
    return Project(
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
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
