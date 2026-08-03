import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/portfolio_data.dart';

class EducationCard extends StatelessWidget {
  final CollegeDetails edu;
  const EducationCard({super.key, required this.edu});

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
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
                            child: Icon(Icons.school_outlined, size: 28, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
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
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 0.5),
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 14),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
                        child: Icon(Icons.school_outlined, size: 40, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
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
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 0.5),
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
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 14),
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
