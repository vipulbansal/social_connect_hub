import 'package:flutter/material.dart';

class DottedPageIndicator extends StatelessWidget {
  /// Total number of pages
  final int pageCount;

  /// Index of the current page (0-based)
  final int currentPage;

  /// Size of each dot
  final double dotSize;

  /// Color of the active dot
  final Color activeColor;

  /// Color of inactive dots
  final Color inactiveColor;

  /// Spacing between dots
  final double spacing;

  /// Shape of the dots (circle by default)
  final BoxShape dotShape;

  /// Animation duration for dot transitions
  final Duration animationDuration;

  /// Constructor
  const DottedPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.dotSize = 8.0,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.spacing = 8.0,
    this.dotShape = BoxShape.circle,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : assert(pageCount > 0, 'Page count must be greater than 0'),
        assert(currentPage >= 0 && currentPage < pageCount,
        'Current page must be between 0 and pageCount - 1');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;

        return AnimatedContainer(
          duration: animationDuration,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          height: dotSize,
          width: isActive ? dotSize * 2 : dotSize, // Elongate active dot
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: dotShape,
            borderRadius: dotShape == BoxShape.rectangle
                ? BorderRadius.circular(dotSize / 2)
                : null,
          ),
        );
      }),
    );
  }
}

/// A version of DottedPageIndicator that responds to PageController changes
class AnimatedDottedPageIndicator extends StatefulWidget {
  /// Total number of pages
  final int pageCount;

  /// PageController to track the current page
  final PageController controller;

  /// Size of each dot
  final double dotSize;

  /// Color of the active dot
  final Color activeColor;

  /// Color of inactive dots
  final Color inactiveColor;

  /// Spacing between dots
  final double spacing;

  /// Shape of the dots
  final BoxShape dotShape;

  /// Animation duration for dot transitions
  final Duration animationDuration;

  /// Constructor
  const AnimatedDottedPageIndicator({
    super.key,
    required this.pageCount,
    required this.controller,
    this.dotSize = 8.0,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.spacing = 8.0,
    this.dotShape = BoxShape.circle,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : assert(pageCount > 0, 'Page count must be greater than 0');

  @override
  State<AnimatedDottedPageIndicator> createState() => _AnimatedDottedPageIndicatorState();
}

class _AnimatedDottedPageIndicatorState extends State<AnimatedDottedPageIndicator> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.controller.initialPage;
    widget.controller.addListener(_pageListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_pageListener);
    super.dispose();
  }

  void _pageListener() {
    final newPage = widget.controller.page?.round() ?? 0;
    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DottedPageIndicator(
      pageCount: widget.pageCount,
      currentPage: _currentPage,
      dotSize: widget.dotSize,
      activeColor: widget.activeColor,
      inactiveColor: widget.inactiveColor,
      spacing: widget.spacing,
      dotShape: widget.dotShape,
      animationDuration: widget.animationDuration,
    );
  }
}