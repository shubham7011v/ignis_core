import 'dart:async';
import 'package:flutter/material.dart';
import 'intro_mood_page.dart';
import 'intro_hint_page.dart';
import 'intro_management_page.dart';
import 'intro_entry_page.dart';

class IntroScreen extends StatefulWidget {
  final int initialPage;
  const IntroScreen({super.key, this.initialPage = 0});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final PageController _pageController;
  Timer? _autoAdvanceTimer;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
    if (_currentPage < 3) {
      _startAutoAdvance();
    }
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(milliseconds: 4000), () {
      if (_currentPage < 3) {
        // Advance from page 0, 1, and 2
        _pageController.nextPage(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          if (index < 3) {
            // Only auto-advance if not on the last page (index 3)
            _startAutoAdvance();
          } else {
            _autoAdvanceTimer?.cancel();
          }
        },
        children: const [
          IntroMoodPage(),
          IntroHintPage(),
          IntroManagementPage(),
          IntroEntryPage(),
        ],
      ),
    );
  }
}
