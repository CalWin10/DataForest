// lib/pages/map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart'; // Keep if you use it elsewhere
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui; // Import dart:ui for ImageFilter

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _currentLocation;
  bool _isHeatmapVisible = false;
  bool _isLoading = false;
  List<MapMarker> _markers = [];
  List<MapMarker> _filteredMarkers = [];
  MapMarker? _selectedMarker;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Comprehensive mock data for Taiwan - No backend needed!
  final List<Map<String, dynamic>> _pollutionData = [
    {
      'location': LatLng(25.0330, 121.5654), // Taipei
      'name': 'Taipei City',
      'airQuality': 75,
      'waterQuality': 85,
      'soilHealth': 65,
      'biodiversity': 90,
      'description': 'Capital city with moderate pollution levels',
      'endangeredSpecies': [
        {
          'name': 'Formosan Black Bear',
          'status': 'Critically Endangered',
          'population': '200-600',
          'extinctionRisk': 'High',
          'icon': '🐻',
          'scientificName': 'Ursus thibetanus formosanus',
          'habitat': 'Mountain forests',
          'threats': ['Habitat loss', 'Poaching', 'Human conflict']
        },
        {
          'name': 'Taiwan Blue Magpie',
          'status': 'Endangered',
          'population': '~10,000',
          'extinctionRisk': 'Medium',
          'icon': '🐦',
          'scientificName': 'Urocissa caerulea',
          'habitat': 'Forests and mountains',
          'threats': ['Deforestation', 'Pesticides']
        }
      ]
    },
    {
      'location': LatLng(24.1477, 120.6736), // Taichung
      'name': 'Taichung City',
      'airQuality': 65,
      'waterQuality': 70,
      'soilHealth': 75,
      'biodiversity': 80,
      'description': 'Industrial city with developing conservation efforts',
      'endangeredSpecies': [
        {
          'name': 'Formosan Landlocked Salmon',
          'status': 'Vulnerable',
          'population': '~5,000',
          'extinctionRisk': 'Medium',
          'icon': '🐟',
          'scientificName': 'Oncorhynchus masou formosanus',
          'habitat': 'Freshwater rivers',
          'threats': ['Water pollution', 'Dam construction']
        }
      ]
    },
    {
      'location': LatLng(22.6273, 120.3014), // Kaohsiung
      'name': 'Kaohsiung City',
      'airQuality': 60,
      'waterQuality': 75,
      'soilHealth': 70,
      'biodiversity': 75,
      'description': 'Port city with coastal conservation challenges',
      'endangeredSpecies': [
        {
          'name': 'Green Sea Turtle',
          'status': 'Endangered',
          'population': 'Declining',
          'extinctionRisk': 'High',
          'icon': '🐢',
          'scientificName': 'Chelonia mydas',
          'habitat': 'Coastal waters',
          'threats': ['Plastic pollution', 'Coastal development']
        },
        {
          'name': 'Chinese White Dolphin',
          'status': 'Critically Endangered',
          'population': '< 100',
          'extinctionRisk': 'Very High',
          'icon': '🐬',
          'scientificName': 'Sousa chinensis',
          'habitat': 'Estuaries and coastal waters',
          'threats': ['Industrial pollution', 'Ship traffic']
        }
      ]
    },
    {
      'location': LatLng(23.6978, 120.9605), // Nantou
      'name': 'Nantou County',
      'airQuality': 85,
      'waterQuality': 90,
      'soilHealth': 80,
      'biodiversity': 95,
      'description': 'Mountainous region with excellent environmental quality',
      'endangeredSpecies': [
        {
          'name': 'Mikado Pheasant',
          'status': 'Near Threatened',
          'population': '~10,000',
          'extinctionRisk': 'Low',
          'icon': '🐓',
          'scientificName': 'Syrmaticus mikado',
          'habitat': 'High altitude forests',
          'threats': ['Habitat fragmentation']
        }
      ]
    },
    {
      'location': LatLng(23.0100, 120.2000), // Tainan
      'name': 'Tainan City',
      'airQuality': 70,
      'waterQuality': 80,
      'soilHealth': 72,
      'biodiversity': 82,
      'description': 'Historic city with wetland conservation areas',
      'endangeredSpecies': [
        {
          'name': 'Black-faced Spoonbill',
          'status': 'Endangered',
          'population': '~3,000',
          'extinctionRisk': 'Medium',
          'icon': '🦩',
          'scientificName': 'Platalea minor',
          'habitat': 'Wetlands and mudflats',
          'threats': ['Wetland destruction', 'Pollution']
        }
      ]
    }
  ];

  // Heatmap data - completely local
  final List<HeatPoint> _heatPoints = [
    HeatPoint(LatLng(25.0330, 121.5654), 0.8, 'High Pollution'), // Taipei
    HeatPoint(LatLng(24.1477, 120.6736), 0.6, 'Medium Pollution'), // Taichung
    HeatPoint(LatLng(22.6273, 120.3014), 0.7, 'Medium-High Pollution'), // Kaohsiung
    HeatPoint(LatLng(23.6978, 120.9605), 0.4, 'Low Pollution'), // Nantou
    HeatPoint(LatLng(24.0869, 121.6030), 0.3, 'Very Low Pollution'), // Hualien
    HeatPoint(LatLng(23.0100, 120.2000), 0.5, 'Low-Medium Pollution'), // Tainan
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _initializeMap();
  }

  void _initializeMap() async {
    setState(() {
      _isLoading = true;
    });

    // Try to get current location, but use Taipei as fallback
    await _getCurrentLocation();

    // Initialize markers with mock data
    _markers = _pollutionData.map((data) {
      return MapMarker(
        position: data['location'],
        data: data,
        color: _getColorForPollution(data['airQuality']),
      );
    }).toList();

    _filteredMarkers = List.from(_markers);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Use Taipei as default
        setState(() {
          _currentLocation = LatLng(25.0330, 121.5654);
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Use Taipei as default
          setState(() {
            _currentLocation = LatLng(25.0330, 121.5654);
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Use Taipei as default
        setState(() {
          _currentLocation = LatLng(25.0330, 121.5654);
        });
        return;
      }

      // Get actual location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Location error: $e");
      // Default to Taipei
      setState(() {
        _currentLocation = LatLng(25.0330, 121.5654);
      });
    }
  }

  Color _getColorForPollution(int quality) {
    if (quality >= 80) return Colors.green;
    if (quality >= 60) return Colors.orange;
    return Colors.red;
  }

  void _searchLocation(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMarkers = List.from(_markers);
      });
      return;
    }

    setState(() {
      _filteredMarkers = _markers.where((marker) {
        final name = marker.data['name'].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });

    if (_filteredMarkers.isNotEmpty) {
      _mapController.move(_filteredMarkers.first.position, 12.0);
    }
  }

  void _showMarkerPopup(MapMarker marker) {
    setState(() {
      _selectedMarker = marker;
    });
    _animationController.forward();
  }

  void _hidePopup() {
    _animationController.reverse().then((_) {
      setState(() {
        _selectedMarker = null;
      });
    });
  }

  void _toggleHeatmap() {
    setState(() {
      _isHeatmapVisible = !_isHeatmapVisible;
    });
  }

  void _reportToOfficial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Environmental Issue'),
        content: Text('This feature would connect to Taiwan Environmental Protection Agency in a real app. For demo purposes, this shows how citizens can report issues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showReportConfirmation();
            },
            child: Text('Simulate Report'),
          ),
        ],
      ),
    );
  }

  void _showReportConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Environmental issue reported successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSpeciesDetails(Map<String, dynamic> species) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(species['icon'], style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Expanded(child: Text(species['name'])),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                species['scientificName'],
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              SizedBox(height: 15),
              _buildDetailRow('Conservation Status', species['status']),
              _buildDetailRow('Population Estimate', species['population']),
              _buildDetailRow('Extinction Risk', species['extinctionRisk']),
              _buildDetailRow('Primary Habitat', species['habitat']),

              SizedBox(height: 10),
              Text(
                'Major Threats:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...species['threats'].map<Widget>((threat) => Text('• $threat')).toList(),

              SizedBox(height: 10),
              Text(
                'Conservation Efforts:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Habitat protection programs'),
              Text('• Breeding and reintroduction initiatives'),
              Text('• Public awareness campaigns'),
              Text('• Legal protection enforcement'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          _buildMap(),

          // Search Bar
          _buildSearchBar(),

          // Control Buttons
          _buildControlButtons(),

          // Loading Indicator
          if (_isLoading) _buildLoadingIndicator(),

          // Popup Dialog
          if (_selectedMarker != null) _buildPopupDialog(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_currentLocation == null) {
      return Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _currentLocation!,
        zoom: 10.0,
        maxZoom: 18.0,
        minZoom: 3.0,
      ),
      children: [
        // Base Layer - OpenStreetMap
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.dataset.dataset',
        ),

        // Heatmap Layer - MODIFIED
        if (_isHeatmapVisible)
          ..._buildHeatmapLayer(), // Spread the list of layers here

        // Markers Layer
        MarkerLayer(
          markers: _filteredMarkers.map((marker) {
            return Marker(
              point: marker.position,
              width: 50,
              height: 50,
              builder: (ctx) => GestureDetector(
                onTap: () => _showMarkerPopup(marker),
                child: Container(
                  decoration: BoxDecoration(
                    color: marker.color.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black38,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // MODIFIED: This function now returns a list of CircleLayers to create the heatmap effect
  List<Widget> _buildHeatmapLayer() {
    List<CircleMarker> circles = [];
    final List<Color> heatmapColors = [
      Colors.blue.withOpacity(0.1),
      Colors.cyan.withOpacity(0.2),
      Colors.green.withOpacity(0.3),
      Colors.yellow.withOpacity(0.4),
      Colors.orange.withOpacity(0.5),
      Colors.red.withOpacity(0.6),
      Colors.red.withOpacity(0.7),
    ];

    for (var point in _heatPoints) {
      // Create multiple concentric circles for each heat point
      for (int i = 0; i < heatmapColors.length; i++) {
        final double radius = point.intensity * 30 + (i * 10); // Adjust base radius and spread
        circles.add(
          CircleMarker(
            point: point.position,
            color: heatmapColors[i], // Use a gradient color
            borderColor: Colors.transparent, // No border for a smooth blend
            borderStrokeWidth: 0,
            radius: radius,
          ),
        );
      }
    }

    return [
      // Applying a blur effect to the entire heatmap layer can also help
      // This part requires `dart:ui` as `ui.ImageFilter.blur`
      // You can wrap the CircleLayer with an ImageFiltered widget if you want
      // It might be performance intensive on some devices.
      // ImageFiltered(
      //   imageFilter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      //   child: CircleLayer(circles: circles),
      // ),
      CircleLayer(circles: circles), // Simpler version without ImageFiltered
    ];
  }


  Widget _buildSearchBar() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: Colors.black26,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search Taipei, Taichung, Kaohsiung...',
            prefixIcon: Icon(Icons.search, color: Colors.green),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _searchLocation('');
              },
            )
                : null,
          ),
          onChanged: _searchLocation,
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      top: 90,
      right: 20,
      child: Column(
        children: [
          // Heatmap Toggle
          FloatingActionButton(
            onPressed: _toggleHeatmap,
            backgroundColor: Colors.white,
            mini: true,
            tooltip: 'Toggle Pollution Heatmap',
            child: Icon(
              _isHeatmapVisible ? Icons.layers_clear : Icons.whatshot,
              color: _isHeatmapVisible ? Colors.red : Colors.orange,
            ),
          ),
          SizedBox(height: 10),
          // Location Button
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            backgroundColor: Colors.white,
            mini: true,
            tooltip: 'Current Location',
            child: Icon(Icons.my_location, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 10),
            Text('Loading Taiwan Environmental Data...'),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupDialog() {
    final marker = _selectedMarker!;
    final data = marker.data;

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 25,
                color: Colors.black38,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              data['description'],
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: _hidePopup,
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Environmental Metrics
                      Text(
                        'Environmental Quality',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildMetricRow('Air Quality', data['airQuality'], Colors.orange),
                      _buildMetricRow('Water Quality', data['waterQuality'], Colors.blue),
                      _buildMetricRow('Soil Health', data['soilHealth'], Colors.brown),
                      _buildMetricRow('Biodiversity', data['biodiversity'], Colors.green),

                      SizedBox(height: 20),

                      // Endangered Species
                      Text(
                        'Endangered Species in Area',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      ..._buildSpeciesList(data['endangeredSpecies']),

                      SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _reportToOfficial,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.report),
                                  SizedBox(width: 8),
                                  Text('Report Issue'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Share functionality
                                _showShareOptions();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.share),
                                  SizedBox(width: 8),
                                  Text('Share Data'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showShareOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Environmental Data'),
        content: Text('This would allow sharing environmental data with community and authorities in a real app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📊 Data shared successfully!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: Text('Simulate Share'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, int value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$value%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpeciesList(List species) {
    if (species.isEmpty) {
      return [
        Text(
          'No endangered species data available for this area.',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ];
    }

    return species.map<Widget>((species) {
      Color riskColor = Colors.green;
      if (species['extinctionRisk'] == 'High') riskColor = Colors.red;
      if (species['extinctionRisk'] == 'Medium') riskColor = Colors.orange;
      if (species['extinctionRisk'] == 'Very High') riskColor = Colors.purple;

      return Card(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Text(
            species['icon'],
            style: TextStyle(fontSize: 24),
          ),
          title: Text(species['name']),
          subtitle: Text('${species['status']} • ${species['population']}'),
          trailing: Chip(
            label: Text(
              species['extinctionRisk'],
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
            backgroundColor: riskColor,
          ),
          onTap: () => _showSpeciesDetails(species),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class MapMarker {
  final LatLng position;
  final Map<String, dynamic> data;
  final Color color;

  MapMarker({
    required this.position,
    required this.data,
    required this.color,
  });
}

class HeatPoint {
  final LatLng position;
  final double intensity;
  final String description;

  HeatPoint(this.position, this.intensity, this.description);
}