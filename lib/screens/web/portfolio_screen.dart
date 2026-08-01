import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/github_provider.dart';
import '../../models/portfolio_data.dart';
import '../../config.dart';
import '../../main.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  final ScrollController _scrollController = ScrollController();
  
  final _homeKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _experienceKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _contactKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final portfolioData = ref.watch(portfolioDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      floatingActionButton: enableWebEditor
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorEntry())),
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
      body: portfolioData.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildContent(PortfolioData data) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const SizedBox(height: 100), // Space for nav bar
              
              // HOME SECTION
              Container(
                key: _homeKey,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 80),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 40,
                  runSpacing: 40,
                  children: [
                    SizedBox(
                      width: isDesktop ? 500 : screenWidth * 0.9,
                      child: Column(
                        crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          Text("Hello, I am", style: TextStyle(fontSize: 24, color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600)).animate().fade(duration: 500.ms).slideY(begin: 0.2),
                          const SizedBox(height: 12),
                          Text(
                            data.name.isEmpty ? 'Your Name' : data.name,
                            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                          ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                          const SizedBox(height: 16),
                          Text(
                            "Mobile & Web Developer",
                            style: TextStyle(fontSize: 28, color: Colors.white70, fontWeight: FontWeight.w500),
                            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                          ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => _scrollTo(_contactKey),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text("Hire Me", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 16),
                              if (data.resumeLink.isNotEmpty)
                                OutlinedButton(
                                  onPressed: () => _launchURL(data.resumeLink),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: const Text("Resume", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ).animate().fade(delay: 600.ms).slideY(begin: 0.2),
                        ],
                      ),
                    ),
                    Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.deepPurpleAccent.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)],
                        border: Border.all(color: Colors.deepPurpleAccent, width: 4),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/my_info.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).moveY(begin: -10, end: 10, duration: 2.seconds),
                  ],
                ),
              ),

              // ABOUT SECTION
              Container(
                key: _aboutKey,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 120 : 24, vertical: 60),
                color: const Color(0xFF15151A),
                child: Column(
                  children: [
                    _sectionTitle('About Me'),
                    const SizedBox(height: 40),
                    Text(
                      data.bio,
                      style: const TextStyle(fontSize: 18, height: 1.8, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // SKILLS SECTION
              Container(
                key: _skillsKey,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    _sectionTitle('My Skills'),
                    const SizedBox(height: 40),
                    if (data.skills.isNotEmpty) _SkillMarquee(skills: data.skills),
                  ],
                ),
              ),

              // EXPERIENCE SECTION
              if (data.experience.isNotEmpty)
                Container(
                  key: _experienceKey,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 120 : 24, vertical: 60),
                  color: const Color(0xFF15151A),
                  child: Column(
                    children: [
                      _sectionTitle('Experience'),
                      const SizedBox(height: 40),
                      ...data.experience.map((exp) => _ExperienceCard(exp: exp)).toList(),
                    ],
                  ),
                ),

              // EDUCATION SECTION
              if (data.education.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 120 : 24, vertical: 60),
                  child: Column(
                    children: [
                      _sectionTitle('Education'),
                      const SizedBox(height: 40),
                      ...data.education.map((edu) => _EducationCard(edu: edu)).toList(),
                    ],
                  ),
                ),

              // PROJECTS SECTION
              Container(
                key: _projectsKey,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 60),
                color: const Color(0xFF15151A),
                child: Column(
                  children: [
                    _sectionTitle('Projects'),
                    const SizedBox(height: 40),
                    _buildProjectGrid(data.projects, isDesktop),
                  ],
                ),
              ),

              // ACHIEVEMENTS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    _sectionTitle('Achievements'),
                    const SizedBox(height: 40),
                    _AchievementMarquee(),
                  ],
                ),
              ),

              // CONTACT SECTION
              Container(
                key: _contactKey,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 120 : 24, vertical: 80),
                color: const Color(0xFF15151A),
                child: Column(
                  children: [
                    _sectionTitle('Get In Touch'),
                    const SizedBox(height: 20),
                    const Text(
                      "Feel free to reach out for collaborations or just a friendly hello!",
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (data.socialLinks.github.isNotEmpty) _socialButton(Icons.code, data.socialLinks.github),
                        const SizedBox(width: 20),
                        if (data.socialLinks.linkedin.isNotEmpty) _socialButton(Icons.link, data.socialLinks.linkedin),
                        const SizedBox(width: 20),
                        if (data.socialLinks.email.isNotEmpty) _socialButton(Icons.email, "mailto:${data.socialLinks.email}"),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text("© 2026. Built with Flutter Web.", style: TextStyle(color: Colors.white38)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // TOP NAVIGATION BAR
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                color: Colors.black.withOpacity(0.4),
                child: Row(
                  mainAxisAlignment: isDesktop ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                  children: [
                    if (isDesktop)
                      const Text(
                        "Portfolio.",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _navItem("Home", _homeKey),
                          _navItem("About", _aboutKey),
                          _navItem("Skills", _skillsKey),
                          _navItem("Experience", _experienceKey),
                          _navItem("Projects", _projectsKey),
                          if (data.resumeLink.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: TextButton(
                                onPressed: () => _launchURL(data.resumeLink),
                                child: const Text("Resume", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          _navItem("Contact", _contactKey),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
    ).animate().fade(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _navItem(String title, GlobalKey key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () => _scrollTo(key),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5)),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    ).animate(onHover: true).scale(end: const Offset(1.1, 1.1));
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildProjectGrid(List<Project> projects, bool isDesktop) {
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      alignment: WrapAlignment.center,
      children: projects.map((p) => _ProjectCard(project: p, isDesktop: isDesktop)).toList(),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final Experience exp;
  const _ExperienceCard({required this.exp});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  exp.role,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  exp.duration,
                  style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exp.company,
            style: const TextStyle(fontSize: 18, color: Colors.white54, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Text(
            exp.description,
            style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.6),
          ),
        ],
      ),
    ).animate().fade().slideX();
  }
}

class _EducationCard extends StatelessWidget {
  final CollegeDetails edu;
  const _EducationCard({required this.edu});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              edu.imagePath,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 120,
                color: Colors.white10,
                child: const Icon(Icons.school, size: 60, color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu.institution,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  edu.degree,
                  style: const TextStyle(fontSize: 18, color: Colors.deepPurpleAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  edu.year,
                  style: const TextStyle(fontSize: 16, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade().slideX();
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final bool isDesktop;

  const _ProjectCard({required this.project, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDesktop ? 400 : double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.folder_open, size: 40, color: Colors.deepPurpleAccent),
          const SizedBox(height: 20),
          Text(
            project.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            project.description,
            style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 24),
          if (project.url.isNotEmpty)
            InkWell(
              onTap: () async {
                final url = Uri.parse(project.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('View Project', style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.deepPurpleAccent, size: 16),
                ],
              ),
            ),
        ],
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .shimmer(delay: 4000.ms, duration: 2000.ms, color: Colors.white10);
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
        height: 60,
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final skill = widget.skills[index % widget.skills.length];
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(skill, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
                ),
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
        height: 300,
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://raw.githubusercontent.com/sanjaytamilan0/resume-web-view/main/assets/assets/images/achivement.png',
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 400,
                    height: 300,
                    color: const Color(0xFF1E1E24),
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
