import textwrap

code = """
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/github_provider.dart';
import '../../models/portfolio_data.dart';

class EditorDashboard extends ConsumerWidget {
  const EditorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(portfolioDataProvider);

    return asyncData.when(
      data: (data) => _EditorForm(data: data),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}

class _EditorForm extends ConsumerStatefulWidget {
  final PortfolioData data;

  const _EditorForm({required this.data});

  @override
  ConsumerState<_EditorForm> createState() => _EditorFormState();
}

class _EditorFormState extends ConsumerState<_EditorForm> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _typewriterController;
  late TextEditingController _metricsController;
  late TextEditingController _bioController;
  late TextEditingController _profileImageController;
  late TextEditingController _skillController;
  late List<CollegeDetails> _education;
  late List<Experience> _experience;
  late List<String> _skills;
  late List<Project> _projects;
  late TextEditingController _githubController;
  late TextEditingController _linkedinController;
  late TextEditingController _emailController;
  late TextEditingController _resumeLinkController;
  bool _isSaving = false;
  bool _isUploadingPdf = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.name);
    _titleController = TextEditingController(text: widget.data.title);
    _typewriterController = TextEditingController(text: widget.data.typewriterTexts.join(', '));
    _metricsController = TextEditingController(text: widget.data.metrics.map((m) => '${m.value}|${m.label.replaceAll('\\n', '\\\\n')}').join('\\n'));
    _bioController = TextEditingController(text: widget.data.bio);
    _profileImageController = TextEditingController(text: widget.data.profileImage);
    _skillController = TextEditingController();
    _education = List.from(widget.data.education);
    _experience = List.from(widget.data.experience);
    _skills = List.from(widget.data.skills);
    _projects = List.from(widget.data.projects);
    _githubController = TextEditingController(text: widget.data.socialLinks.github);
    _linkedinController = TextEditingController(text: widget.data.socialLinks.linkedin);
    _emailController = TextEditingController(text: widget.data.socialLinks.email);
    _resumeLinkController = TextEditingController(text: widget.data.resumeLink);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _typewriterController.dispose();
    _metricsController.dispose();
    _bioController.dispose();
    _profileImageController.dispose();
    _skillController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _emailController.dispose();
    _resumeLinkController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final newData = widget.data.copyWith(
      name: _nameController.text,
      title: _titleController.text,
      typewriterTexts: _typewriterController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      metrics: _metricsController.text.split('\\n').map((line) {
        final parts = line.split('|');
        if (parts.length == 2) return MetricData(value: parts[0].trim(), label: parts[1].replaceAll('\\\\n', '\\n').trim());
        return null;
      }).whereType<MetricData>().toList(),
      bio: _bioController.text,
      skills: _skills,
      education: _education,
      experience: _experience,
      projects: _projects,
      socialLinks: SocialLinks(
        github: _githubController.text,
        linkedin: _linkedinController.text,
        email: _emailController.text,
      ),
      resumeLink: _resumeLinkController.text,
      profileImage: _profileImageController.text,
    );

    try {
      final service = ref.read(githubServiceProvider);
      await service.updateData(newData);
      ref.invalidate(portfolioDataProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to GitHub!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _uploadPdf() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
      if (result != null && result.files.isNotEmpty && result.files.first.bytes != null) {
        setState(() => _isUploadingPdf = true);
        final service = ref.read(githubServiceProvider);
        final uploadedUrl = await service.uploadFile('assets/resume.pdf', result.files.first.bytes!);
        setState(() => _resumeLinkController.text = uploadedUrl);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF uploaded!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingPdf = false);
    }
  }

  Future<void> _pickAndUploadImage(Function(String) onUploaded) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image);
      if (result != null && result.files.first.bytes != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading image...')));
        final service = ref.read(githubServiceProvider);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = result.files.first.name.replaceAll(' ', '_');
        final uploadedUrl = await service.uploadFile('assets/images/upload_${timestamp}_${fileName}', result.files.first.bytes!);
        onUploaded(uploadedUrl);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editor Dashboard'),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              label: const Text('Exit Editor', style: TextStyle(color: Colors.white)),
              onPressed: () => ref.read(githubTokenProvider.notifier).setToken(null),
            ),
            const SizedBox(width: 16),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile & Socials'),
              Tab(icon: Icon(Icons.work), text: 'Experience & Edu'),
              Tab(icon: Icon(Icons.code), text: 'Projects'),
              Tab(icon: Icon(Icons.star), text: 'Skills & Resume'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProfileTab(),
            _buildExperienceTab(),
            _buildProjectsTab(),
            _buildSkillsResumeTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isSaving ? null : _saveData,
          icon: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
          label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionHeader('Personal Info'),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(width: 350, child: _buildTextField(controller: _nameController, label: 'Name', icon: Icons.person)),
            SizedBox(width: 350, child: _buildTextField(controller: _titleController, label: 'Title', icon: Icons.work)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(controller: _typewriterController, label: 'Typewriter Titles (comma separated)', icon: Icons.text_fields),
        const SizedBox(height: 16),
        _buildTextField(controller: _metricsController, label: 'Metrics (value|label per line)', icon: Icons.bar_chart, maxLines: 3),
        const SizedBox(height: 16),
        _buildTextField(controller: _bioController, label: 'Bio', icon: Icons.description, maxLines: 4),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _profileImageController,
          label: 'Profile Image URL',
          icon: Icons.image,
          suffixIcon: Icons.upload_file,
          onSuffixTap: () => _pickAndUploadImage((url) => setState(() => _profileImageController.text = url)),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Social Links'),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(width: 350, child: _buildTextField(controller: _githubController, label: 'GitHub URL', icon: Icons.code)),
            SizedBox(width: 350, child: _buildTextField(controller: _linkedinController, label: 'LinkedIn URL', icon: Icons.link)),
            SizedBox(width: 350, child: _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email)),
          ],
        ),
      ],
    );
  }

  Widget _buildExperienceTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Experience'),
            ElevatedButton.icon(onPressed: () => setState(() => _experience.add(Experience(role: '', company: '', duration: '', description: ''))), icon: const Icon(Icons.add), label: const Text('Add')),
          ],
        ),
        ..._experience.asMap().entries.map((e) => _buildExperienceCard(e.key, e.value)).toList(),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Education'),
            ElevatedButton.icon(onPressed: () => setState(() => _education.add(CollegeDetails(institution: '', degree: '', year: '', imagePath: ''))), icon: const Icon(Icons.add), label: const Text('Add')),
          ],
        ),
        ..._education.asMap().entries.map((e) => _buildEducationCard(e.key, e.value)).toList(),
      ],
    );
  }

  Widget _buildProjectsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Projects'),
            ElevatedButton.icon(onPressed: () => setState(() => _projects.add(Project(title: '', description: '', url: ''))), icon: const Icon(Icons.add), label: const Text('Add Project')),
          ],
        ),
        ..._projects.asMap().entries.map((e) => _buildProjectCard(e.key, e.value)).toList(),
      ],
    );
  }

  Widget _buildSkillsResumeTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionHeader('Resume'),
        Row(
          children: [
            Expanded(child: _buildTextField(controller: _resumeLinkController, label: 'Resume URL', icon: Icons.picture_as_pdf)),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _isUploadingPdf ? null : _uploadPdf,
              icon: _isUploadingPdf ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : const Icon(Icons.upload_file),
              label: const Text('Upload PDF'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16)),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSectionHeader('Skills'),
        Row(
          children: [
            Expanded(child: _buildTextField(controller: _skillController, label: 'Add Skill', icon: Icons.star)),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                if (_skillController.text.trim().isNotEmpty) {
                  setState(() {
                    _skills.add(_skillController.text.trim());
                    _skillController.clear();
                  });
                }
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.asMap().entries.map((e) => Chip(
            label: Text(e.value),
            onDeleted: () => setState(() => _skills.removeAt(e.key)),
            deleteIconColor: Colors.redAccent,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, int maxLines = 1, IconData? suffixIcon, VoidCallback? onSuffixTap}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon != null ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixTap) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }

  Widget _buildTextFormField({required String initialValue, required String label, required IconData icon, required Function(String) onChanged, int maxLines = 1, IconData? suffixIcon, VoidCallback? onSuffixTap}) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon != null ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixTap) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }

  Widget _buildExperienceCard(int index, Experience exp) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(exp.role.isEmpty ? 'New Experience' : exp.role),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _buildTextFormField(initialValue: exp.role, label: 'Role', icon: Icons.work, onChanged: (v) => _experience[index] = exp.copyWith(role: v))),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _experience.removeAt(index))),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextFormField(initialValue: exp.company, label: 'Company', icon: Icons.business, onChanged: (v) => _experience[index] = exp.copyWith(company: v)),
          const SizedBox(height: 16),
          _buildTextFormField(initialValue: exp.duration, label: 'Duration', icon: Icons.timer, onChanged: (v) => _experience[index] = exp.copyWith(duration: v)),
          const SizedBox(height: 16),
          _buildTextFormField(initialValue: exp.description, label: 'Description', icon: Icons.notes, maxLines: 3, onChanged: (v) => _experience[index] = exp.copyWith(description: v)),
          const SizedBox(height: 16),
          _buildTextFormField(
            initialValue: exp.imagePath,
            label: 'Image URL',
            icon: Icons.image,
            suffixIcon: Icons.upload_file,
            onSuffixTap: () => _pickAndUploadImage((url) => setState(() => _experience[index] = exp.copyWith(imagePath: url))),
            onChanged: (v) => _experience[index] = exp.copyWith(imagePath: v),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(int index, CollegeDetails edu) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(edu.institution.isEmpty ? 'New Education' : edu.institution),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _buildTextFormField(initialValue: edu.institution, label: 'Institution', icon: Icons.school, onChanged: (v) => _education[index] = edu.copyWith(institution: v))),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _education.removeAt(index))),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextFormField(initialValue: edu.degree, label: 'Degree', icon: Icons.badge, onChanged: (v) => _education[index] = edu.copyWith(degree: v)),
          const SizedBox(height: 16),
          _buildTextFormField(initialValue: edu.year, label: 'Year', icon: Icons.calendar_today, onChanged: (v) => _education[index] = edu.copyWith(year: v)),
          const SizedBox(height: 16),
          _buildTextFormField(initialValue: edu.imagePath, label: 'Image Path', icon: Icons.image, onChanged: (v) => _education[index] = edu.copyWith(imagePath: v)),
        ],
      ),
    );
  }

  Widget _buildProjectCard(int index, Project project) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(project.title.isEmpty ? 'New Project' : project.title),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _buildTextFormField(initialValue: project.title, label: 'Project Title', icon: Icons.title, onChanged: (v) => _projects[index] = project.copyWith(title: v))),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _projects.removeAt(index))),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextFormField(initialValue: project.companyName, label: 'Company Name', icon: Icons.business, onChanged: (v) => _projects[index] = project.copyWith(companyName: v)),
          const SizedBox(height: 16),
          _buildTextFormField(initialValue: project.role, label: 'Role', icon: Icons.person, onChanged: (v) => _projects[index] = project.copyWith(role: v)),
          const SizedBox(height: 16),
          _buildTextFormField(initialValue: project.description, label: 'Description', icon: Icons.notes, maxLines: 3, onChanged: (v) => _projects[index] = project.copyWith(description: v)),
          const SizedBox(height: 16),
          _buildTextFormField(initialValue: project.url, label: 'Project URL', icon: Icons.link, onChanged: (v) => _projects[index] = project.copyWith(url: v)),
          const SizedBox(height: 16),
          _buildTextFormField(
            initialValue: project.imagePath,
            label: 'Image URL',
            icon: Icons.image,
            suffixIcon: Icons.upload_file,
            onSuffixTap: () => _pickAndUploadImage((url) => setState(() => _projects[index] = project.copyWith(imagePath: url))),
            onChanged: (v) => _projects[index] = project.copyWith(imagePath: v),
          ),
        ],
      ),
    );
  }
}
"""

with open('lib/screens/android/editor_dashboard.dart', 'w') as f:
    f.write(code)
