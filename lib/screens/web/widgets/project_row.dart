import 'package:flutter/material.dart';
import '../../../models/portfolio_data.dart';
import 'project_card.dart';

class ProjectRow extends StatefulWidget {
  final List<Project> projects;
  final bool isDesktop;

  const ProjectRow({super.key, required this.projects, required this.isDesktop});

  @override
  State<ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<ProjectRow> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
    });
  }

  void _updateScrollButtons() {
    if (_scrollController.hasClients) {
      final canScrollLeft = _scrollController.offset > 0;
      final canScrollRight = _scrollController.offset < _scrollController.position.maxScrollExtent;
      
      if (_canScrollLeft != canScrollLeft || _canScrollRight != canScrollRight) {
        setState(() {
          _canScrollLeft = canScrollLeft;
          _canScrollRight = canScrollRight;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll(double offset) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        (_scrollController.offset + offset).clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.isDesktop ? 400.0 : MediaQuery.of(context).size.width * 0.85;

    return Stack(
      alignment: Alignment.center,
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.projects.map((p) => Padding(
              padding: const EdgeInsets.only(right: 30),
              child: SizedBox(
                width: cardWidth,
                child: ProjectCard(project: p, isDesktop: widget.isDesktop),
              ),
            )).toList(),
          ),
        ),
        if (_canScrollLeft)
          Positioned(
            left: 0,
            child: _buildNavButton(Icons.chevron_left, () => _scroll(-cardWidth), context),
          ),
        if (_canScrollRight)
          Positioned(
            right: 0,
            child: _buildNavButton(Icons.chevron_right, () => _scroll(cardWidth), context),
          ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.deepPurpleAccent),
        onPressed: onPressed,
      ),
    );
  }
}
