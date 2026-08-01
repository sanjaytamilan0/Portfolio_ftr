import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/portfolio_data.dart';

// You will need to set these to your actual GitHub username and repository name
const String githubUsername = 'sanjaytamilan0';
const String githubRepo = 'Portfolio_ftr';
const String filePath = 'database.json'; // The file in the root of your repo

class TokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setToken(String? token) => state = token;
}

final githubTokenProvider = NotifierProvider<TokenNotifier, String?>(TokenNotifier.new);

final portfolioDataProvider = FutureProvider<PortfolioData>((ref) async {
  final service = ref.watch(githubServiceProvider);
  return await service.fetchData();
});

final githubServiceProvider = Provider((ref) {
  final token = ref.watch(githubTokenProvider);
  return GithubService(token: token);
});

class GithubService {
  final String? token;

  GithubService({this.token});

  Future<PortfolioData> fetchData() async {
    final url = Uri.parse('https://raw.githubusercontent.com/$githubUsername/$githubRepo/main/$filePath');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PortfolioData.fromJson(json);
    } else {
      // Return a default empty portfolio if not found
      return PortfolioData(name: 'New Portfolio', bio: 'Welcome to my portfolio!', projects: []);
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
