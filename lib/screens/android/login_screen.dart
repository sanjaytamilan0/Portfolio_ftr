import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../providers/github_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        ref.read(githubTokenProvider.notifier).setToken(token);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid GitHub Token!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(FontAwesomeIcons.github, size: 80, color: Colors.white)
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 20),
              const Text(
                'GitHub Login',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ).animate().fade(delay: 200.ms),
              const SizedBox(height: 10),
              const Text(
                'Enter your GitHub Personal Access Token to edit your portfolio.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ).animate().fade(delay: 300.ms),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () async {
                  final url = Uri.parse('https://github.com/settings/tokens/new?scopes=repo&description=Portfolio+Editor');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Generate Token Here'),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurpleAccent),
              ).animate().fade(delay: 350.ms),
              const SizedBox(height: 20),
              TextField(
                controller: _tokenController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'GitHub Token',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}
