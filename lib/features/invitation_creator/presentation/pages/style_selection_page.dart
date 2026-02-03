import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class StyleSelectionPage extends StatefulWidget {
  const StyleSelectionPage({super.key});

  @override
  State<StyleSelectionPage> createState() => _StyleSelectionPageState();
}

class _StyleSelectionPageState extends State<StyleSelectionPage> {
  String? _selectedStyleId;

  final List<Map<String, dynamic>> _styles = [
    {
      'id': 'royal_indian',
      'title': 'Royal Indian',
      'subtitle': 'Gold & Maroon Accents',
      'color': Color(0xFFC41E3A),
      'isPopular': true,
    },
    {
      'id': 'traditional',
      'title': 'Traditional Hindu',
      'subtitle': 'Vermillion & Turmeric',
      'color': Color(0xFFFF9800),
      'isPopular': false,
    },
    {
      'id': 'cinematic',
      'title': 'Cinematic Modern',
      'subtitle': 'Sleek Photography',
      'color': Color(0xFF424242),
      'isPopular': false,
    },
    {
      'id': 'pastel',
      'title': 'Minimal Elegant',
      'subtitle': 'Soft Pastels',
      'color': Color(0xFFF8BBD0),
      'isPopular': false,
    },
    {
      'id': 'vintage',
      'title': 'Vintage Bollywood',
      'subtitle': 'Retro 70s Glamour',
      'color': Color(0xFFD84315),
      'isNew': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.getPalette(AppThemeMode.royal);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(
          'Style Selection',
          style: TextStyle(color: palette.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: palette.textPrimary),
        actions: [
          TextButton(
            onPressed: () {
              // Skip logic
            },
            child: Text('Skip', style: TextStyle(color: palette.textTertiary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: 0.4,
            backgroundColor: palette.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(palette.primary),
            minHeight: 4,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 2 of 5',
                    style: TextStyle(color: palette.textTertiary, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your aesthetic',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select the visual style that best matches your wedding theme.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _styles.length,
                      itemBuilder: (context, index) {
                        final style = _styles[index];
                        final isSelected = _selectedStyleId == style['id'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStyleId = style['id'];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: palette.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? palette.primary
                                    : palette.divider,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: palette.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Stack(
                              children: [
                                // Color Placeholder (Replace with Image later)
                                Container(
                                  decoration: BoxDecoration(
                                    color: (style['color'] as Color).withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        (style['color'] as Color).withValues(
                                          alpha: 0.4,
                                        ),
                                        (style['color'] as Color).withValues(
                                          alpha: 0.1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Content
                                Positioned(
                                  left: 12,
                                  right: 12,
                                  bottom: 12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (style['isPopular'] == true)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'MOST POPULAR',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                      Text(
                                        style['title'],
                                        style: TextStyle(
                                          color: palette.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        style['subtitle'],
                                        style: TextStyle(
                                          color: palette.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Selection Checkmark
                                if (isSelected)
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: palette.primary,
                                      child: const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Continue Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedStyleId == null
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/details_form');
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  disabledBackgroundColor: palette.surfaceLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
