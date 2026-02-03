import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/ignis_theme.dart';
import '../bloc/templates_bloc.dart';
import '../bloc/templates_event.dart';
import '../bloc/templates_state.dart';
import '../widgets/template_card.dart';
import '../../../invitation_creator/presentation/bloc/invitation_bloc.dart';
import '../../../invitation_creator/presentation/bloc/invitation_event.dart';

class TemplateGalleryScreen extends StatelessWidget {
  const TemplateGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IgnisTheme.deepMaroon,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'WEDDING TEMPLATES',
          style: GoogleFonts.cinzel(
            color: IgnisTheme.goldAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Categories
          const _CategoryList(),

          // Gallery Grid
          Expanded(
            child: BlocBuilder<TemplatesBloc, TemplatesState>(
              builder: (context, state) {
                if (state is TemplatesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: IgnisTheme.goldAccent,
                    ),
                  );
                } else if (state is TemplatesLoaded) {
                  if (state.templates.isEmpty) {
                    return Center(
                      child: Text(
                        'No templates found in this category.',
                        style: GoogleFonts.inter(color: Colors.white54),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: state.templates.length,
                    itemBuilder: (context, index) {
                      final template = state.templates[index];
                      return TemplateCard(
                        template: template,
                        onTap: () {
                          context.read<InvitationBloc>().add(
                            TemplateSelected(template),
                          );
                          Navigator.pushNamed(context, '/details_form');
                        },
                      );
                    },
                  );
                } else if (state is TemplatesError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList();

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Traditional', 'Modern', 'Minimal'];

    return BlocBuilder<TemplatesBloc, TemplatesState>(
      builder: (context, state) {
        final selectedCategory = state is TemplatesLoaded
            ? state.selectedCategory
            : 'All';

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat == selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(
                    cat.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: IgnisTheme.goldAccent,
                  backgroundColor: const Color(0xFF2E1A1A),
                  onSelected: (selected) {
                    if (selected) {
                      context.read<TemplatesBloc>().add(
                        TemplateCategoryChanged(cat),
                      );
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
