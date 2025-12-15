import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:aptcoder/core/models/course.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;

  const CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                course.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                AppText.interLarger(course.title, weight: FontWeight.w800),

                const SizedBox(height: 8),

                
                AppText.interMedium(
                  course.description,
                  
                  
                  color: Colors.black87,
                ),

                if (course.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),

                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: course.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText.interSmall(
                          tag,
                          color: primaryColor,
                          weight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
