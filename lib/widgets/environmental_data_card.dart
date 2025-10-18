import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import '../models/species_model.dart'; // Assuming this is where your Species model is
import '../pages/species_detail_page.dart'; // Assuming this is where your SpeciesDetailPage is

// Helper for gas metrics (if not already in home_page.dart or a separate file)
class GasMetric {
  final String label;
  final double value; // Concentration in μg/m³
  final Color color;
  final IconData icon;

  const GasMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
}

// Helper for the custom modal route (if not already defined)
class ModalSheetRoute<T> extends PageRoute<T> {
  ModalSheetRoute({required this.builder, RouteSettings? settings})
      : super(settings: settings);

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Modal Bottom Sheet';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}


class EnvironmentalDataCard extends StatefulWidget {
  final String cityName;
  final double latitude;
  final double longitude;
  final VoidCallback? onClose; // Callback for closing the card

  const EnvironmentalDataCard({
    Key? key,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    this.onClose,
  }) : super(key: key);

  @override
  _EnvironmentalDataCardState createState() => _EnvironmentalDataCardState();
}

class _EnvironmentalDataCardState extends State<EnvironmentalDataCard> {
  bool _isLoading = true;
  List<GasMetric> _gasMetrics = [];
  int _aqi = 0;
  String _pollutionLevel = 'Unknown';
  Color _pollutionColor = Colors.grey;

  // Dummy species list for now, to be made dynamic later
  final List<Species> _speciesList = const [
    Species(
      name: 'Formosan Black Bear',
      status: 'Critically Endangered',
      info: 'Only 200-600 remaining in the wild.',
      icon: Icons.pets,
    ),
    Species(
      name: 'Taiwan Blue Magpie',
      status: 'Endangered',
      info: 'A vivid, social bird found in the mountains.',
      icon: Icons.flutter_dash,
    ),
    Species(
      name: 'Formosan Landlocked Salmon',
      status: 'Vulnerable',
      info: 'A unique freshwater salmon species.',
      icon: Icons.waves,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchAirPollutionData();
  }

  // Refetch data if location changes
  @override
  void didUpdateWidget(covariant EnvironmentalDataCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != oldWidget.latitude || widget.longitude != oldWidget.longitude) {
      _fetchAirPollutionData();
    }
  }

  Future<void> _fetchAirPollutionData() async {
    setState(() {
      _isLoading = true;
    });

    const apiKey = "YOUR_OPENWEATHER_API_KEY"; // <<< IMPORTANT: Replace with your actual API key
    final url =
        'http://api.openweathermap.org/data/2.5/air_pollution?lat=${widget.latitude}&lon=${widget.longitude}&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final components = data['list'][0]['components'];
        final fetchedAqi = data['list'][0]['main']['aqi'];

        final List<GasMetric> fetchedMetrics = [
          GasMetric(label: 'CO', value: components['co'].toDouble(), color: Colors.grey, icon: Icons.cloud_queue),
          GasMetric(label: 'NO₂', value: components['no2'].toDouble(), color: Colors.orange, icon: Icons.grain),
          GasMetric(label: 'O₃', value: components['o3'].toDouble(), color: Colors.blueAccent, icon: Icons.public),
          GasMetric(label: 'SO₂', value: components['so2'].toDouble(), color: Colors.red, icon: Icons.whatshot),
          GasMetric(label: 'PM₂.₅', value: components['pm2_5'].toDouble(), color: Colors.brown, icon: Icons.blur_on),
          GasMetric(label: 'PM₁₀', value: components['pm10'].toDouble(), color: Colors.deepPurple, icon: Icons.scatter_plot),
        ];

        String pollutionLevel;
        Color pollutionColor;
        switch (fetchedAqi) {
          case 1: pollutionLevel = 'Good'; pollutionColor = Colors.green; break;
          case 2: pollutionLevel = 'Fair'; pollutionColor = Colors.lightGreen; break;
          case 3: pollutionLevel = 'Moderate'; pollutionColor = Colors.orange; break;
          case 4: pollutionLevel = 'Poor'; pollutionColor = Colors.red; break;
          case 5: pollutionLevel = 'Very Poor'; pollutionColor = Colors.redAccent; break;
          default: pollutionLevel = 'Unknown'; pollutionColor = Colors.grey; break;
        }

        setState(() {
          _gasMetrics = fetchedMetrics;
          _aqi = fetchedAqi;
          _pollutionLevel = pollutionLevel;
          _pollutionColor = pollutionColor;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        print('Failed to load air pollution data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching air pollution data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: 200, // Fixed height for loading state
        child: const Center(child: CircularProgressIndicator()),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _pollutionColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cityName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'AQI: $_aqi ($_pollutionLevel)',
                        style: TextStyle(
                          fontSize: 14,
                          color: _pollutionColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          Divider(indent: 16, endIndent: 16, height: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
          Flexible( // Use Flexible to allow the ListView to take available height without overflowing
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harmful Gas Levels (μg/m³)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._gasMetrics.map((metric) => _buildGasMetricRow(context, metric, isDarkMode)).toList(),
                  const SizedBox(height: 20),
                  Text(
                    'Endangered Species in Area',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Loop through a dummy species list for now
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.report_problem, color: Colors.white),
                          label: const Text('Report Issue', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text('Share Data', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGasMetricRow(BuildContext context, GasMetric metric, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(metric.icon, color: metric.color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              metric.label,
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Text(
            '${metric.value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: metric.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesCard(BuildContext context, {required Species species, required VoidCallback onTap}) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: Theme.of(context).cardColor,
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            // Display only the first word or two for brevity in the chip
            species.status.split(' ').first,
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
        onTap: onTap,
      ),
    );
  }
}