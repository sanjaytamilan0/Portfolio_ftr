import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../providers/github_provider.dart';
import '../../models/portfolio_data.dart';
import '../../config.dart';

import 'widgets/experience_card.dart';
import 'widgets/education_card.dart';
import 'widgets/project_row.dart';

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
      
        endDrawer: Drawer(
        
        child: portfolioData.when(
          data: (data) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              Text("Navigation", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 40),
              ListTile(title: Text("Home", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)), onTap: () { Navigator.pop(context); _scrollTo(_homeKey); }),
              ListTile(title: Text("About", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)), onTap: () { Navigator.pop(context); _scrollTo(_aboutKey); }),
              ListTile(title: Text("Skills", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)), onTap: () { Navigator.pop(context); _scrollTo(_skillsKey); }),
              ListTile(title: Text("Experience", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)), onTap: () { Navigator.pop(context); _scrollTo(_experienceKey); }),
              ListTile(title: Text("Projects", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)), onTap: () { Navigator.pop(context); _scrollTo(_projectsKey); }),
              ListTile(title: Text("Contact", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)), onTap: () { Navigator.pop(context); _scrollTo(_contactKey); }),
              Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
              ListTile(
                title: Text("Download CV", style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  if (data.resumeLink.trim().isNotEmpty) {
                    _launchURL(data.resumeLink);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No CV uploaded yet!')));
                  }
                },
              ),
              ListTile(
                title: Text("Toggle Theme", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                trailing: Icon(
                  Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onTap: () {
                  final current = ref.read(themeModeProvider);
                  ref.read(themeModeProvider.notifier).state =
                      current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const SizedBox(),
        ),
      ),
      floatingActionButton: (!kIsWeb && enableWebEditor)
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorEntry())),
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
      body: portfolioData.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error', style: TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildContent(PortfolioData data) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
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
                            style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, height: 1.1),
                            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                          ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: isDesktop ? 40 : 80,
                            child: DefaultTextStyle(
                              style: TextStyle(fontSize: isDesktop ? 28 : 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                              child: AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: data.typewriterTexts.isNotEmpty
                                    ? data.typewriterTexts.map((text) => TypewriterAnimatedText(text)).toList()
                                    : [
                                        TypewriterAnimatedText(data.title.isEmpty ? "Mobile & Web Developer" : data.title),
                                        TypewriterAnimatedText("Building beautiful mobile experiences"),
                                        TypewriterAnimatedText("Architecting scalable Flutter apps"),
                                        TypewriterAnimatedText("Turning ideas into reality"),
                                      ],
                              ),
                            ),
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
                                child: Text("Hire Me", style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
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
                                  side: BorderSide(color: Colors.deepPurpleAccent, width: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: Text("Download CV", style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                              ),
                              if (data.socialLinks.github.isNotEmpty)
                                IconButton(
                                  icon: FaIcon(FontAwesomeIcons.github, size: 32, color: Theme.of(context).colorScheme.onSurface),
                                  onPressed: () => _launchURL(data.socialLinks.github),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                ),
                              if (data.socialLinks.linkedin.isNotEmpty)
                                IconButton(
                                  icon: FaIcon(FontAwesomeIcons.linkedinIn, size: 32, color: Theme.of(context).colorScheme.onSurface),
                                  onPressed: () => _launchURL(data.socialLinks.linkedin),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                ),
                            ].where((e) => e != null).cast<Widget>().toList(),
                          ).animate().fade(delay: 600.ms).slideY(begin: 0.2),
                          const SizedBox(height: 48),
                          // PROOF OF WORK METRICS
                          Wrap(
                            spacing: 32,
                            runSpacing: 16,
                            alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
                            children: data.metrics.isNotEmpty
                                ? data.metrics.map((m) => _buildMetricItem(m.value, m.label)).toList()
                                : [
                                    _buildMetricItem("3+", "Years\nExperience"),
                                    _buildMetricItem("10+", "Apps\nDeployed"),
                                    _buildMetricItem("100%", "Client\nSatisfaction"),
                                  ],
                          ).animate().fade(delay: 800.ms).slideY(begin: 0.2),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      height: 400,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 320,
                            height: 320,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.deepPurpleAccent.withOpacity(0.4), blurRadius: 60, spreadRadius: 10)],
                              border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5), width: 2),
                              image: data.profileImage.isNotEmpty ? DecorationImage(
                                image: NetworkImage(data.profileImage),
                                fit: BoxFit.cover,
                              ) : null,
                            ),
                            child: data.profileImage.isEmpty
                                ? const FlutterLogo(size: 120)
                                : null,
                          ),
                          Positioned(
                            top: 40,
                            left: 0,
                            child: _buildGlassBadge("Flutter SDE"),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 2.5.seconds),
                          Positioned(
                            bottom: 60,
                            right: 0,
                            child: _buildGlassBadge("Available for Hire", isAccent: true),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 5, end: -5, duration: 3.seconds),
                        ],
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
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                child: Column(
                  children: [
                    _sectionTitle('About Me'),
                    const SizedBox(height: 40),
                    Text(
                      data.bio,
                      style: TextStyle(fontSize: 18, height: 1.8, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
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
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                  child: Column(
                    children: [
                      _sectionTitle('Experience'),
                      const SizedBox(height: 40),
                      ...data.experience.map((exp) => ExperienceCard(exp: exp)).toList(),
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
                      ...data.education.map((edu) => EducationCard(edu: edu)).toList(),
                    ],
                  ),
                ),

              // PROJECTS SECTION
              Container(
                key: _projectsKey,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 60),
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
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
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                child: Column(
                  children: [
                    _sectionTitle("Let's Connect"),
                    const SizedBox(height: 20),
                    Text(
                      "I'm always open to discussing new projects, creative ideas or opportunities.",
                      style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
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
                    Text("© 2026. Built with Flutter Web.", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38))),
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
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        data.profileImage.isNotEmpty
                            ? CircleAvatar(backgroundImage: NetworkImage(data.profileImage), radius: 18)
                            : const FlutterLogo(size: 32),
                        const SizedBox(width: 12),
                        Text(
                          data.name.isEmpty ? "FlutterDev" : data.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
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
                              child: Text("Download CV", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          _navItem("Contact", _contactKey),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: IconButton(
                              icon: Icon(
                                Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () {
                                final current = ref.read(themeModeProvider);
                                ref.read(themeModeProvider.notifier).state =
                                    current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface, size: 28),
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
    });
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.2),
    ).animate().fade(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _navItem(String title, GlobalKey key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () => _scrollTo(key),
        child: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w600),
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5)),
        ),
        child: FaIcon(icon, color: Theme.of(context).colorScheme.onSurface, size: 28),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectRow(projects: firstHalf, isDesktop: isDesktop),
        if (secondHalf.isNotEmpty) ...[
          const SizedBox(height: 30),
          ProjectRow(projects: secondHalf, isDesktop: isDesktop),
        ],
      ],
    );
  }

  Widget _buildGlassBadge(String text, {bool isAccent = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isAccent ? Colors.deepPurpleAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isAccent ? Colors.deepPurpleAccent.withOpacity(0.5) : Colors.white.withOpacity(0.2)),
            boxShadow: [
              if (isAccent) BoxShadow(color: Colors.deepPurpleAccent.withOpacity(0.3), blurRadius: 20)
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAccent) Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
              if (isAccent) const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.2)),
      ],
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(skill, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
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
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Center(child: Icon(Icons.error, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
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
