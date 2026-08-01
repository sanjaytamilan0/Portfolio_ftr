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
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? 40 : 16, 
        vertical: screenWidth > 600 ? 80 : 40,
      ),
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
                data.bio,
                style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.white70),
              ).animate().fade(delay: 400.ms, duration: 600.ms).slideX(begin: -0.05),
              
              const SizedBox(height: 40),
              if (data.skills.isNotEmpty) ...[
                Center(
                  child: const Text(
                    'Skills',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ).animate().fade(delay: 500.ms, duration: 600.ms),
                ),
                const SizedBox(height: 20),
                _SkillMarquee(skills: data.skills).animate().fade(delay: 600.ms, duration: 600.ms),
                const SizedBox(height: 40),
              ],
              
              Center(
                child: const Text(
                  'Projects',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ).animate().fade(delay: 700.ms, duration: 600.ms),
              ),
              
              const SizedBox(height: 30),
              
              _buildProjectRows(data.projects).animate().fade(delay: 800.ms, duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),
              
              const SizedBox(height: 60),
              Center(
                child: const Text(
                  'Achievements',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ).animate().fade(delay: 900.ms, duration: 600.ms),
              ),
              const SizedBox(height: 30),
              _AchievementMarquee().animate().fade(delay: 1000.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectRows(List<Project> projects) {
    if (projects.isEmpty) return const SizedBox.shrink();
    
    final half = (projects.length / 2).ceil();
    final row1 = projects.take(half).toList();
    final row2 = projects.skip(half).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: row1.map((p) => Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 20), 
              child: _ProjectCard(project: p),
            )).toList(),
          ),
        ),
        if (row2.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: row2.map((p) => Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 20), 
                child: _ProjectCard(project: p),
              )).toList(),
            ),
          ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth > 450 ? 400 : screenWidth * 0.85,
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

class _SkillMarquee extends StatefulWidget {
  final List<String> skills;
  const _SkillMarquee({required this.skills});

  @override
  State<_SkillMarquee> createState() => _SkillMarqueeState();
}

class _SkillMarqueeState extends State<_SkillMarquee> {
  final ScrollController _controller = ScrollController();
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _startScrolling();
  }

  void _startScrolling() async {
    await Future.delayed(const Duration(milliseconds: 500));
    while (mounted) {
      if (_controller.hasClients && !_isHovering) {
        await _controller.animateTo(
          _controller.offset + 50.0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.linear,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final skill = widget.skills[index % widget.skills.length];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text(skill, style: const TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.white.withOpacity(0.1),
                labelStyle: const TextStyle(color: Colors.white),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AchievementMarquee extends StatefulWidget {
  @override
  State<_AchievementMarquee> createState() => _AchievementMarqueeState();
}

class _AchievementMarqueeState extends State<_AchievementMarquee> {
  final ScrollController _controller = ScrollController();
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _startScrolling();
  }

  void _startScrolling() async {
    await Future.delayed(const Duration(milliseconds: 500));
    while (mounted) {
      if (_controller.hasClients && !_isHovering) {
        await _controller.animateTo(
          _controller.offset + 50.0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.linear,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://raw.githubusercontent.com/sanjaytamilan0/resume-web-view/main/assets/assets/images/achivement.png',
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 300,
                    height: 250,
                    color: Colors.grey[800],
                    child: const Center(child: Icon(Icons.error, color: Colors.white54)),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
