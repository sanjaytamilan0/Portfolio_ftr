import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/github_provider.dart';
import '../../models/portfolio_data.dart';

class EditorDashboard extends ConsumerWidget {
  const EditorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(portfolioDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(githubTokenProvider.notifier).setToken(null);
            },
          )
        ],
      ),
      body: asyncData.when(
        data: (data) => _EditorForm(data: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
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
  late TextEditingController _bioController;
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.name);
    _bioController = TextEditingController(text: widget.data.bio);
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
    _bioController.dispose();
    _skillController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _emailController.dispose();
    _resumeLinkController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    setState(() {
      _isSaving = true;
    });
    
    final newData = widget.data.copyWith(
      name: _nameController.text,
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
    );

    try {
      final service = ref.read(githubServiceProvider);
      await service.updateData(newData);
      
      // Invalidate the provider to fetch fresh data
      ref.invalidate(portfolioDataProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully saved to GitHub!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _addEducation() {
    setState(() {
      _education.add(CollegeDetails(institution: 'New College', degree: '', year: '', imagePath: 'assets/images/my_collage.jpg'));
    });
  }

  void _removeEducation(int index) {
    setState(() {
      _education.removeAt(index);
    });
  }

  void _addExperience() {
    setState(() {
      _experience.add(Experience(role: 'New Role', company: '', duration: '', description: ''));
    });
  }

  void _removeExperience(int index) {
    setState(() {
      _experience.removeAt(index);
    });
  }

  void _addProject() {
    setState(() {
      _projects.add(Project(title: 'New Project', description: '', url: ''));
    });
  }

  void _removeProject(int index) {
    setState(() {
      _projects.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Personal Info',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            const Text('Skills', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _skillController,
                    label: 'Add Skill',
                    icon: Icons.star,
                  ),
                ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.asMap().entries.map((entry) {
                return Chip(
                  label: Text(entry.value),
                  backgroundColor: const Color(0xFF2A2A2A),
                  labelStyle: const TextStyle(color: Colors.white),
                  deleteIconColor: Colors.redAccent,
                  onDeleted: () {
                    setState(() {
                      _skills.removeAt(entry.key);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Education', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: _addEducation,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Education'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._education.asMap().entries.map((entry) {
              final index = entry.key;
              final edu = entry.value;
              return Card(
                color: const Color(0xFF1E1E1E),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              initialValue: edu.institution,
                              label: 'Institution Name',
                              icon: Icons.school,
                              onChanged: (val) {
                                _education[index] = edu.copyWith(institution: val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _removeEducation(index),
                            tooltip: 'Delete Education',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        initialValue: edu.degree,
                        label: 'Degree',
                        icon: Icons.badge,
                        onChanged: (val) {
                          _education[index] = edu.copyWith(degree: val);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        initialValue: edu.year,
                        label: 'Year',
                        icon: Icons.calendar_today,
                        onChanged: (val) {
                          _education[index] = edu.copyWith(year: val);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        initialValue: edu.imagePath,
                        label: 'Image Path (e.g. assets/images/my_collage.jpg)',
                        icon: Icons.image,
                        onChanged: (val) {
                          _education[index] = edu.copyWith(imagePath: val);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Experience', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: _addExperience,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Experience'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._experience.asMap().entries.map((entry) {
              final index = entry.key;
              final exp = entry.value;
              return Card(
                color: const Color(0xFF1E1E1E),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              initialValue: exp.role,
                              label: 'Role / Job Title',
                              icon: Icons.work,
                              onChanged: (val) {
                                _experience[index] = exp.copyWith(role: val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _removeExperience(index),
                            tooltip: 'Delete Experience',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        initialValue: exp.company,
                        label: 'Company',
                        icon: Icons.business,
                        onChanged: (val) {
                          _experience[index] = exp.copyWith(company: val);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        initialValue: exp.duration,
                        label: 'Duration (e.g. Jan 2023 - Present)',
                        icon: Icons.calendar_today,
                        onChanged: (val) {
                          _experience[index] = exp.copyWith(duration: val);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        initialValue: exp.description,
                        label: 'Description',
                        icon: Icons.notes,
                        maxLines: 3,
                        onChanged: (val) {
                          _experience[index] = exp.copyWith(description: val);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Projects', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: _addProject,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._projects.asMap().entries.map((entry) {
              final index = entry.key;
              final project = entry.value;
              return Card(
                color: const Color(0xFF1E1E1E),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              initialValue: project.title,
                              label: 'Project Title',
                              icon: Icons.title,
                              onChanged: (val) {
                                _projects[index] = project.copyWith(title: val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _removeProject(index),
                            tooltip: 'Delete Project',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        initialValue: project.description,
                        label: 'Description',
                        icon: Icons.notes,
                        maxLines: 3,
                        onChanged: (val) {
                          _projects[index] = project.copyWith(description: val);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        initialValue: project.url,
                        label: 'Project URL',
                        icon: Icons.link,
                        onChanged: (val) {
                          _projects[index] = project.copyWith(url: val);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 40),
            const Text('Social Links & Resume', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _githubController,
              label: 'GitHub URL',
              icon: Icons.code,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _linkedinController,
              label: 'LinkedIn URL',
              icon: Icons.link,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _resumeLinkController,
              label: 'Resume URL (e.g. Google Drive Link or assets/resume.pdf)',
              icon: Icons.picture_as_pdf,
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveData,
                icon: _isSaving 
                    ? const SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save to GitHub', style: const TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String initialValue,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
