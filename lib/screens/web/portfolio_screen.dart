import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      endDrawer: Drawer(
        backgroundColor: const Color(0xFF15151A),
        child: portfolioData.when(
          data: (data) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              const Text("Navigation", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 40),
              ListTile(title: const Text("Home", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _scrollTo(_homeKey); }),
              ListTile(title: const Text("About", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _scrollTo(_aboutKey); }),
              ListTile(title: const Text("Skills", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _scrollTo(_skillsKey); }),
              ListTile(title: const Text("Experience", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _scrollTo(_experienceKey); }),
              ListTile(title: const Text("Projects", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _scrollTo(_projectsKey); }),
              ListTile(title: const Text("Contact", style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _scrollTo(_contactKey); }),
              const Divider(color: Colors.white24),
              ListTile(
                title: const Text("Download CV", style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  if (data.resumeLink.trim().isNotEmpty) {
                    _launchURL(data.resumeLink);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No CV uploaded yet!')));
                  }
                },
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const SizedBox(),
        ),
      ),
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
                            data.title.isEmpty ? "Mobile & Web Developer" : data.title,
                            style: TextStyle(fontSize: 28, color: Colors.white70, fontWeight: FontWeight.w500),
                            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                          ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
                          const SizedBox(height: 32),
                          Wrap(
                            alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 16,
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
                              OutlinedButton(
                                onPressed: () {
                                  if (data.resumeLink.trim().isNotEmpty) {
                                    _launchURL(data.resumeLink);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No CV uploaded yet!')),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text("Download CV", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              if (data.socialLinks.github.isNotEmpty)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.github, size: 32, color: Colors.white),
                                  onPressed: () => _launchURL(data.socialLinks.github),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                ),
                              if (data.socialLinks.linkedin.isNotEmpty)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.linkedinIn, size: 32, color: Colors.white),
                                  onPressed: () => _launchURL(data.socialLinks.linkedin),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                        image: DecorationImage(
                          image: data.profileImage.isNotEmpty
                              ? NetworkImage(data.profileImage) as ImageProvider
                              : const AssetImage('assets/images/my_info.jpeg'),
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
                    if (data.skills.isNotEmpty) ...[
                      _SkillMarquee(skills: data.skills),
                      const SizedBox(height: 20),
                      _SkillMarquee(
                        skills: data.skills.length > 1 
                            ? [...data.skills.sublist(data.skills.length ~/ 2), ...data.skills.sublist(0, data.skills.length ~/ 2)]
                            : data.skills, 
                        reverse: true
                      ),
                    ],
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
                    _buildProjectGrid(data.projects, isDesktop, context),
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
                    _sectionTitle("Let's Connect"),
                    const SizedBox(height: 20),
                    const Text(
                      "I'm always open to discussing new projects, creative ideas or opportunities.",
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        if (data.socialLinks.github.isNotEmpty) _socialButton(FontAwesomeIcons.github, data.socialLinks.github),
                        if (data.socialLinks.linkedin.isNotEmpty) _socialButton(FontAwesomeIcons.linkedinIn, data.socialLinks.linkedin),
                        if (data.socialLinks.email.isNotEmpty) _socialButton(FontAwesomeIcons.solidEnvelope, "mailto:${data.socialLinks.email}"),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "FlutterDev",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                    ),
                    if (isDesktop)
                      Row(
                        children: [
                          _navItem("Home", _homeKey),
                          _navItem("About", _aboutKey),
                          _navItem("Skills", _skillsKey),
                          _navItem("Experience", _experienceKey),
                          _navItem("Projects", _projectsKey),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextButton(
                              onPressed: () {
                                if (data.resumeLink.trim().isNotEmpty) {
                                  _launchURL(data.resumeLink);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No CV uploaded yet!')),
                                  );
                                }
                              },
                              child: const Text("Download CV", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          _navItem("Contact", _contactKey),
                        ],
                      )
                    else
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                          onPressed: () => Scaffold.of(ctx).openEndDrawer(),
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

  Widget _socialButton(dynamic icon, String url) {
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
        child: FaIcon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildProjectGrid(List<Project> projects, bool isDesktop, BuildContext context) {
    final firstHalf = projects.sublist(0, (projects.length / 2).ceil());
    final secondHalf = projects.sublist((projects.length / 2).ceil());

    Widget buildRow(List<Project> rowProjects) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowProjects.map((p) => Padding(
            padding: const EdgeInsets.only(right: 30),
            child: SizedBox(
              width: isDesktop ? 400 : MediaQuery.of(context).size.width * 0.85,
              child: _ProjectCard(project: p, isDesktop: isDesktop),
            ),
          )).toList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRow(firstHalf),
        if (secondHalf.isNotEmpty) ...[
          const SizedBox(height: 30),
          buildRow(secondHalf),
        ],
      ],
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final Experience exp;
  const _ExperienceCard({required this.exp});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isMobile 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.work_outline, color: Colors.deepPurpleAccent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp.role,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exp.company,
                            style: const TextStyle(fontSize: 16, color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    exp.duration,
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  exp.description,
                  style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.6),
                ),
                if (exp.imagePath.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      exp.imagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.work_outline, color: Colors.deepPurpleAccent, size: 32),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exp.role,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  exp.company,
                                  style: const TextStyle(fontSize: 18, color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Text(
                              exp.duration,
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        exp.description,
                        style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.8),
                      ),
                      if (exp.imagePath.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            exp.imagePath,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    ).animate().fade().slideX(begin: 0.1);
  }
}

class _EducationCard extends StatelessWidget {
  final CollegeDetails edu;
  const _EducationCard({required this.edu});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          edu.imagePath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.white10,
                            child: const Icon(Icons.school_outlined, size: 28, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            edu.institution,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            edu.degree,
                            style: const TextStyle(fontSize: 16, color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    edu.year,
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      edu.imagePath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.white10,
                        child: const Icon(Icons.school_outlined, size: 40, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              edu.institution,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              edu.degree,
                              style: const TextStyle(fontSize: 18, color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          edu.year,
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    ).animate().fade().slideX(begin: 0.1);
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final bool isDesktop;

  const _ProjectCard({required this.project, required this.isDesktop});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            widget.project.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (widget.project.role.isNotEmpty || widget.project.companyName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              [if (widget.project.role.isNotEmpty) widget.project.role, if (widget.project.companyName.isNotEmpty) widget.project.companyName].join(' at '),
              style: const TextStyle(fontSize: 16, color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, size) {
            final span = TextSpan(text: widget.project.description, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5));
            final tp = TextPainter(text: span, maxLines: 7, textDirection: TextDirection.ltr);
            tp.layout(maxWidth: size.maxWidth);
            
            if (tp.didExceedMaxLines) {
              return AnimatedSize(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.description,
                      style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                      maxLines: _isExpanded ? null : 7,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Text(
                        _isExpanded ? "View Less" : "View More",
                        style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Text(
                widget.project.description,
                style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
              );
            }
          }),
          if (widget.project.imagePath.isNotEmpty) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.project.imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (widget.project.url.isNotEmpty)
            InkWell(
              onTap: () async {
                final url = Uri.parse(widget.project.url);
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
    );
  }
}

class _SkillMarquee extends StatefulWidget {
  final List<String> skills;
  final bool reverse;
  const _SkillMarquee({required this.skills, this.reverse = false});

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
          reverse: widget.reverse,
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
