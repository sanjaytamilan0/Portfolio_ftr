class PortfolioData {
  final String name;
  final String bio;
  final List<Project> projects;

  PortfolioData({
    required this.name,
    required this.bio,
    required this.projects,
  });

  factory PortfolioData.fromJson(Map<String, dynamic> json) {
    return PortfolioData(
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
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
      'projects': projects.map((e) => e.toJson()).toList(),
    };
  }

  PortfolioData copyWith({
    String? name,
    String? bio,
    List<Project>? projects,
  }) {
    return PortfolioData(
      name: name ?? this.name,
      bio: bio ?? this.bio,
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
