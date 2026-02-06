import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/auth.dart';
import '../../../templates/presentation/bloc/templates_bloc.dart';
import '../../../templates/presentation/bloc/templates_state.dart';
import '../../../invitation_creator/presentation/bloc/invitation_bloc.dart';
import '../../../invitation_creator/presentation/bloc/invitation_event.dart';
import '../../../templates/domain/models/template.dart';
import '../bloc/home_bloc.dart';
import 'home_top_bar.dart';
import 'hero_template_carousel.dart';
import 'template_rail.dart';

class HomeDashboard extends StatelessWidget {
  final AppColorPalette palette;
  final HomeState homeState;

  const HomeDashboard({
    super.key,
    required this.palette,
    required this.homeState,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = (authState is Authenticated) ? authState.user : null;

        return BlocBuilder<TemplatesBloc, TemplatesState>(
          builder: (context, templatesState) {
            final List<Template> templates = (templatesState is TemplatesLoaded)
                ? templatesState.templates
                : [];
            final featuredTemplates = templates.take(3).toList();
            final trendingTemplates = templates.length > 3
                ? templates.sublist(3, templates.length.clamp(3, 8))
                : templates;
            final modernTemplates = templates
                .where((t) => t.category == 'Modern')
                .toList();
            final traditionalTemplates = templates
                .where((t) => t.category == 'Traditional')
                .toList();

            return CustomScrollView(
              slivers: [
                // 1. Home Branding & Greeting (Pinned Header)
                SliverToBoxAdapter(
                  child: HomeTopBar(
                    user: user,
                    palette: palette,
                    systemStatus: homeState.systemStatus,
                    greeting: homeState.greeting,
                  ),
                ),

                // 2. Hero Carousel
                if (featuredTemplates.isNotEmpty)
                  SliverToBoxAdapter(
                    child: HeroTemplateCarousel(
                      featuredTemplates: featuredTemplates,
                      onCreatePressed: (template) {
                        context.read<InvitationBloc>().add(
                          TemplateSelected(template),
                        );
                        Navigator.pushNamed(context, '/details_form');
                      },
                      onPlayPressed: (template) {
                        // 1. Switch to Shorts Tab (Index 2)
                        context.read<HomeBloc>().add(
                          const HomeBottomNavTapped(2),
                        );

                        // 2. Play this specific video (Future: Add PlaySpecificShort event)
                        // For now, it just opens the feed, which is acceptable for v1
                        // context.read<ShortsBloc>().add(PlaySpecificShort(template.id));
                      },
                    ),
                  ),

                // 3. Horizontal Rails
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (trendingTemplates.isNotEmpty)
                        TemplateRail(
                          title: 'Trending Now',
                          templates: trendingTemplates,
                          onTemplateTap: (template) {
                            context.read<InvitationBloc>().add(
                              TemplateSelected(template),
                            );
                            Navigator.pushNamed(context, '/details_form');
                          },
                          onViewAllTap: () {
                            context.read<HomeBloc>().add(
                              const HomeBottomNavTapped(1),
                            );
                          },
                        ),
                      if (traditionalTemplates.isNotEmpty)
                        TemplateRail(
                          title: 'Royal Heritage',
                          templates: traditionalTemplates,
                          onTemplateTap: (template) {
                            context.read<InvitationBloc>().add(
                              TemplateSelected(template),
                            );
                            Navigator.pushNamed(context, '/details_form');
                          },
                        ),
                      if (modernTemplates.isNotEmpty)
                        TemplateRail(
                          title: 'Modern & Minimal',
                          templates: modernTemplates,
                          onTemplateTap: (template) {
                            context.read<InvitationBloc>().add(
                              TemplateSelected(template),
                            );
                            Navigator.pushNamed(context, '/details_form');
                          },
                        ),

                      // Bottom Spacing
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
