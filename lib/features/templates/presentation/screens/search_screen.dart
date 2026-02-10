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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IgnisTheme.deepMaroon,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search templates (e.g., Royal, Sangeet)',
                  hintStyle: GoogleFonts.inter(color: Colors.white38),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: IgnisTheme.goldAccent,
                  ),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onChanged: (query) {
                  context.read<TemplatesBloc>().add(SearchTemplates(query));
                },
              ),
            ),

            // Category Chips
            const _CategoryList(),

            // Results Grid
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No templates found',
                              style: GoogleFonts.inter(color: Colors.white54),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        // No locking logic based on premium anymore

                        return TemplateCard(
                          template: template,
                          onUnlock: () {
                            // No-op
                          },
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
          height: 50,
          margin: const EdgeInsets.only(bottom: 8),
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
                    cat,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: IgnisTheme.goldAccent,
                  backgroundColor: Colors.white10,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
