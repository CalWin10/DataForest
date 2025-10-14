// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'dart:math';

// Import the separated model and detail page
import '../models/species_model.dart';
import 'SpeciesDetailPage.dart';


// (The PollutionMetric class can also be moved to its own model file if you wish)
class PollutionMetric {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const PollutionMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selectedMetricIndex;

  final List<PollutionMetric> _metrics = const [
    PollutionMetric(label: 'Air Quality', value: 75, color: Colors.orange, icon: Icons.air),
    PollutionMetric(label: 'Water Quality', value: 85, color: Colors.blue, icon: Icons.water_drop),
    PollutionMetric(label: 'Soil Health', value: 65, color: Colors.brown, icon: Icons.grass),
    PollutionMetric(label: 'Biodiversity', value: 90, color: Colors.green, icon: Icons.eco),
  ];

  final List<Species> _speciesList = const [
    Species(
      name: 'Formosan Black Bear',
      status: 'Critically Endangered',
      info: 'Only 200-600 remaining in the wild. A symbol of Taiwan\'s wilderness, recognized by the V-shaped white mark on its chest.',
      icon: Icons.pets,
    ),
    Species(
      name: 'Taiwan Blue Magpie',
      status: 'Endangered',
      info: 'A vivid, social bird found in the mountains, known for its long tail and cooperative breeding habits.',
      icon: Icons.flutter_dash,
    ),
    Species(
      name: 'Formosan Landlocked Salmon',
      status: 'Vulnerable',
      info: 'A unique freshwater salmon species, a relic from the last ice age, facing threats from climate change.',
      icon: Icons.waves,
    ),
  ];

  double get _overallScore => _metrics.map((m) => m.value).reduce((a, b) => a + b) / _metrics.length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context),
          SizedBox(height: 24),
          _buildPollutionSection(context),
          SizedBox(height: 20),
          _buildSpeciesSection(context),
          SizedBox(height: 20),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to DataForest! 🌳',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore environmental data and forest analytics',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.forest, size: 50, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildPollutionSection(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final overallScore = _overallScore;

    final displayedValue = _selectedMetricIndex == null
        ? overallScore
        : _metrics[_selectedMetricIndex!].value.toDouble();

    final displayedColor = _selectedMetricIndex == null
        ? Colors.green
        : _metrics[_selectedMetricIndex!].color;

    final displayedLabel = _selectedMetricIndex == null
        ? 'Overall'
        : _metrics[_selectedMetricIndex!].label;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Environmental Health Score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMetricIndex = null;
                      });
                    },
                    child: SizedBox(
                      height: 120,
                      width: 120,
                      child: PieChartWidget(
                        value: displayedValue,
                        color: displayedColor,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: Column(
                              key: ValueKey<String>(displayedLabel),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${displayedValue.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: displayedColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayedLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: List.generate(_metrics.length, (index) {
                      return _buildMetricItem(context, index);
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, int index) {
    final metric = _metrics[index];
    final isSelected = _selectedMetricIndex == index;
    final isOverall = _selectedMetricIndex == null;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetricIndex = isSelected ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? metric.color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Opacity(
          opacity: isOverall || isSelected ? 1.0 : 0.5,
          child: Row(
            children: [
              Icon(metric.icon, color: metric.color, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  metric.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: metric.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${metric.value}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: metric.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeciesSection(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_circle_outlined, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Endangered Species in Taiwan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ..._speciesList.asMap().entries.map((entry) {
              int index = entry.key;
              Species species = entry.value;
              return _buildSpeciesCard(
                context,
                species: species,
                onTap: () {
                  Navigator.push(
                    context,
                    ModalSheetRoute(
                      builder: (context) => SpeciesDetailPage(
                        speciesList: _speciesList,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesCard(BuildContext context, {required Species species, required VoidCallback onTap}) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: Theme.of(context).cardColor,
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(species.icon, color: Colors.green, size: 20),
        ),
        title: Text(
          species.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          species.info,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Chip(
          label: Text(
            species.status,
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(context, Icons.report_problem_outlined, 'Report Issue', Colors.orange),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(context, Icons.volunteer_activism_outlined, 'Volunteer', Colors.purple),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(context, Icons.school_outlined, 'Learn', Colors.blue),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(context, Icons.share_outlined, 'Share', Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, Color color) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final double value;
  final Color color;
  final Widget? child;

  const PieChartWidget({
    Key? key,
    required this.value,
    required this.color,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value / 100),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      builder: (context, animatedValue, _) {
        return CustomPaint(
          painter: _PieChartPainter(
            percentage: animatedValue,
            progressColor: color,
            backgroundColor: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
          child: child,
        );
      },
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;

  _PieChartPainter({
    required this.percentage,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 12.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}