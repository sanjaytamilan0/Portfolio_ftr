import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/github_provider.dart';
import '../../models/portfolio_data.dart';
import '../../config.dart';
import '../../main.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioData = ref.watch(portfolioDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: enableWebEditor
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditorEntry()),
                );
              },
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
      body: portfolioData.when(
        data: (data) => _PortfolioContent(data: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}

class _PortfolioContent extends StatelessWidget {
  final PortfolioData data;

  const _PortfolioContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, I'm",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
              ).animate().fade(duration: 500.ms).slideY(begin: -0.2),
              
              Text(
                data.name.isEmpty ? 'Your Name' : data.name,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 20),
              
              Text(
                data.bio.isEmpty ? 'A passionate developer building amazing things.' : data.bio,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white60, height: 1.5),
              ).animate().fade(delay: 400.ms, duration: 600.ms),
              
              const SizedBox(height: 60),
              
              Text(
                'My Projects',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fade(delay: 600.ms).slideX(begin: -0.1),
              
              const SizedBox(height: 30),
              
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: data.projects.map((project) => _ProjectCard(project: project)).toList(),
              ).animate().fade(delay: 800.ms, duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            project.description,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          if (project.url.isNotEmpty)
            InkWell(
              onTap: () async {
                final url = Uri.parse(project.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: const Text(
                'View Project →',
                style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .shimmer(delay: 3000.ms, duration: 2000.ms, color: Colors.white10);
  }
}
