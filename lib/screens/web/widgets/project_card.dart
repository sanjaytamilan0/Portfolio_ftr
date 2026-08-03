import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/portfolio_data.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  final bool isDesktop;

  const ProjectCard({super.key, required this.project, required this.isDesktop});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.folder_open, size: 40, color: Colors.deepPurpleAccent),
          const SizedBox(height: 20),
          Text(
            widget.project.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
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
            final span = TextSpan(text: widget.project.description, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5));
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
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
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
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
              );
            }
          }),
          if (widget.project.imagePath.isNotEmpty) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.project.imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
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
