import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/portfolio_data.dart';

class ExperienceCard extends StatelessWidget {
  final Experience exp;
  const ExperienceCard({super.key, required this.exp});

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
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
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
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 0.5),
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  exp.description,
                  style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.6),
                ),
                if (exp.imagePath.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: exp.imagePath,
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
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 0.5),
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
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        exp.description,
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.8),
                      ),
                      if (exp.imagePath.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: exp.imagePath,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(
                              height: 300,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => const SizedBox.shrink(),
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
