// lib/pages/species_detail_page.dart

import 'package:flutter/material.dart';
import 'dart:ui'; // Required for BackdropFilter and ImageFilter.blur
import '../models/species_model.dart';

// --- This is the new custom PageRoute that creates the "modal" effect ---
class ModalSheetRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  ModalSheetRoute({required this.builder, RouteSettings? settings})
      : super(settings: settings, fullscreenDialog: false);

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.6);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false; // This is key for the transparent background

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Animate the page sliding up from the bottom
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }
}

// --- The SpeciesDetailPage is now designed as a pop-up sheet ---
class SpeciesDetailPage extends StatefulWidget {
  final List<Species> speciesList;
  final int initialIndex;

  const SpeciesDetailPage({
    Key? key,
    required this.speciesList,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _SpeciesDetailPageState createState() => _SpeciesDetailPageState();
}

class _SpeciesDetailPageState extends State<SpeciesDetailPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 0.85, // Shows a glimpse of the next/previous cards
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use a transparent scaffold to see the page behind
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Add a gesture detector to pop the route when tapping the background
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: BackdropFilter(
          // This blurs the underlying HomePage
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7, // Sheet starts at 70% of screen height
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              // The main content container
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Title that updates with the carousel
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Text(
                          widget.speciesList[_currentIndex].name,
                          key: ValueKey<String>(widget.speciesList[_currentIndex].name),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // The Carousel PageView
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.speciesList.length,
                        onPageChanged: (int index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final species = widget.speciesList[index];
                          // Use AnimatedScale for a nice growing effect as cards come into view
                          return AnimatedScale(
                            duration: const Duration(milliseconds: 400),
                            scale: index == _currentIndex ? 1.0 : 0.9,
                            child: _buildSpeciesPageCard(species, scrollController),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // This card is now the content for each item in the carousel INSIDE the sheet
  Widget _buildSpeciesPageCard(Species species, ScrollController controller) {
    return Card(
      elevation: 0, // No shadow needed as it's inside the main sheet
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        // Use a ListView to make the card content itself scrollable
        child: ListView(
          // Important: Use the controller from the DraggableScrollableSheet
          controller: controller,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(species.icon, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 24),
            Chip(
              label: Text(
                species.status,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            const Divider(height: 40),
            Text(
              'About ${species.name}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              species.info,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}