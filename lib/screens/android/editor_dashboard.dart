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
  late List<Project> _projects;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.name);
    _bioController = TextEditingController(text: widget.data.bio);
    _projects = List.from(widget.data.projects);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    setState(() {
      _isSaving = true;
    });
    
    final newData = widget.data.copyWith(
      name: _nameController.text,
      bio: _bioController.text,
      projects: _projects,
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bioController,
          decoration: const InputDecoration(labelText: 'Bio'),
          maxLines: 3,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Projects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(onPressed: _addProject, icon: const Icon(Icons.add_circle)),
          ],
        ),
        ..._projects.asMap().entries.map((entry) {
          final index = entry.key;
          final project = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: project.title,
                          decoration: const InputDecoration(labelText: 'Title'),
                          onChanged: (val) {
                            _projects[index] = project.copyWith(title: val);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeProject(index),
                      ),
                    ],
                  ),
                  TextFormField(
                    initialValue: project.description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (val) {
                      _projects[index] = project.copyWith(description: val);
                    },
                  ),
                  TextFormField(
                    initialValue: project.url,
                    decoration: const InputDecoration(labelText: 'URL'),
                    onChanged: (val) {
                      _projects[index] = project.copyWith(url: val);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveData,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Save to GitHub', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
