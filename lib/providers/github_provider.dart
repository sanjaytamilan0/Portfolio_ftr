import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/portfolio_data.dart';

import 'package:shared_preferences/shared_preferences.dart';

// You will need to set these to your actual GitHub username and repository name
const String githubUsername = 'sanjaytamilan0';
const String githubRepo = 'Portfolio_ftr';
const String filePath = 'database.json'; // The file in the root of your repo

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class TokenNotifier extends Notifier<String?> {
  @override
  String? build() {
    return ref.watch(sharedPreferencesProvider).getString('github_token');
  }

  void setToken(String? token) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (token == null) {
      prefs.remove('github_token');
    } else {
      prefs.setString('github_token', token);
    }
    state = token;
  }
}

final githubTokenProvider = NotifierProvider<TokenNotifier, String?>(TokenNotifier.new);

final portfolioDataProvider = FutureProvider<PortfolioData>((ref) async {
  final service = ref.watch(githubServiceProvider);
  return await service.fetchData();
});

final githubServiceProvider = Provider((ref) {
  return GithubService(ref: ref);
});

class GithubService {
  final Ref ref;

  GithubService({required this.ref});

  String? get token => ref.read(githubTokenProvider);

  Future<PortfolioData> fetchData() async {
    final url = Uri.parse('https://raw.githubusercontent.com/$githubUsername/$githubRepo/main/$filePath');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PortfolioData.fromJson(json);
      } else {
        throw Exception();
      }
    } catch (e) {
      // If file doesn't exist or other error, return default empty portfolio
      return PortfolioData(name: 'New Portfolio', bio: 'Welcome to my portfolio!', skills: [], typewriterTexts: [], metrics: [], education: [], experience: [], projects: [], socialLinks: SocialLinks(github: '', linkedin: '', email: ''), resumeLink: '');
    }
  }

  Future<String> uploadFile(String filePathInRepo, List<int> fileBytes) async {
    if (token == null || token!.isEmpty) {
      throw Exception('GitHub token is required to upload files.');
    }

    final apiUrl = Uri.parse('https://api.github.com/repos/$githubUsername/$githubRepo/contents/$filePathInRepo');
    final getResponse = await http.get(apiUrl, headers: {
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github.v3+json',
    });

    String? sha;
    if (getResponse.statusCode == 200) {
      final json = jsonDecode(getResponse.body);
      sha = json['sha'];
    }

    final content = base64Encode(fileBytes);
    final body = {
      'message': 'Upload $filePathInRepo via editor',
      'content': content,
      if (sha != null) 'sha': sha,
    };

    final putResponse = await http.put(
      apiUrl,
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (putResponse.statusCode == 200 || putResponse.statusCode == 201) {
      return 'https://raw.githubusercontent.com/$githubUsername/$githubRepo/main/$filePathInRepo';
    } else {
      throw Exception('Failed to upload file to GitHub: ${putResponse.body}');
    }
  }

  Future<void> updateData(PortfolioData data) async {
    if (token == null || token!.isEmpty) {
      throw Exception('GitHub token is required to update data.');
    }

    // 1. Get current file sha (required for updating in GitHub API)
    final apiUrl = Uri.parse('https://api.github.com/repos/$githubUsername/$githubRepo/contents/$filePath');
    final getResponse = await http.get(apiUrl, headers: {
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github.v3+json',
    });

    String? sha;
    if (getResponse.statusCode == 200) {
      final json = jsonDecode(getResponse.body);
      sha = json['sha'];
    }

    // 2. Put new file content
    final content = base64Encode(utf8.encode(jsonEncode(data.toJson())));
    final body = {
      'message': 'Update portfolio data',
      'content': content,
      if (sha != null) 'sha': sha,
    };

    final putResponse = await http.put(
      apiUrl,
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (putResponse.statusCode != 200 && putResponse.statusCode != 201) {
      throw Exception('Failed to update portfolio data on GitHub.');
    }
  }
}
