import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../../../../core/widgets/ignis_network_image.dart';
import '../../../templates/domain/models/template.dart';

class TemplateRail extends StatelessWidget {
  final String title;
  final List<Template> templates;
  final Function(Template) onTemplateTap;
  final VoidCallback? onViewAllTap;

  const TemplateRail({
    super.key,
    required this.title,
    required this.templates,
    required this.onTemplateTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onViewAllTap != null)
                  TextButton(
                    onPressed: onViewAllTap,
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        color: IgnisTheme.goldAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _TemplatePoster(
                  template: template,
                  onTap: () => onTemplateTap(template),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplatePoster extends StatelessWidget {
  final Template template;
  final VoidCallback onTap;

  const _TemplatePoster({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    IgnisNetworkImage(
                      imageUrl: template.thumbnailUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    if (template.cost > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: IgnisTheme.goldAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '₹${template.cost.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              template.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              template.category,
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
