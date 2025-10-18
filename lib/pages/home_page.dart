import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import the separated model and the new detail page with the custom route
import '../models/species_model.dart';
import 'SpeciesDetailPage.dart';

// New data model for harmful gases
class GasMetric {
  final String label;
  final double value;
  // Concentration in μg/m³
  final Color color;
  final IconData icon;
  final String description;

  const GasMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.description,
  });
}

// Extinct animal model
class ExtinctAnimal {
  final String name;
  final String extinctionYear;
  final String extinctionRate;
  final String causes;
  final String history;
  final String imageUrl; // <-- ADDED: Image URL for the carousel

  const ExtinctAnimal({
    required this.name,
    required this.extinctionYear,
    required this.extinctionRate,
    required this.causes,
    required this.history,
    required this.imageUrl, // <-- ADDED: Image URL for the carousel
  });
}

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({Key? key, required this.userName}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int? _selectedMetricIndex;
  bool _isLoading = true;
  int _currentCarouselIndex = 0;
  late PageController _pageController;

  // State variables for API data
  List<GasMetric> _gasMetrics = [];
  int _aqi = 0;
  String _aqiLevel = 'Level 0';

  // AQI level descriptions
  String getAqiDescription(int aqi) {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  Color getAqiColor(int aqi) {
    switch (aqi) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Enhanced welcome message based on AQI
  String getWelcomeMessage(int aqi, String userName) {
    if (aqi <= 2) return "The air is clear today, $userName! 🌤️ A great day for Taiwan's nature.";
    if (aqi == 3) return "Moderate air quality, $userName. 🌿 Let's keep Taiwan green!";
    if (aqi >= 4) return "Pollution is high today, $userName. 😷 Let's see what we can do.";
    return "Welcome, $userName! 🌳 Explore environmental data.";
  }

  // Extinct animals data
  // MODIFIED: Expanded list to 7 animals and added image URLs
  final List<ExtinctAnimal> _extinctAnimals = const [
    ExtinctAnimal(
      name: 'Formosan Clouded Leopard',
      extinctionYear: '1983',
      extinctionRate: '100%',
      causes: 'Habitat destruction, poaching, human encroachment',
      history: 'Once roamed the mountainous forests of Taiwan, this beautiful leopard was last officially sighted in 1983. It was an apex predator crucial for ecosystem balance.',
      imageUrl: 'https://images.unsplash.com/photo-1557053910-d9eadeed1c58?w=500&q=80',
    ),
    ExtinctAnimal(
      name: 'Taiwan Otter',
      extinctionYear: '1970s',
      extinctionRate: '100%',
      causes: 'Water pollution, habitat loss, hunting',
      history: 'Native to Taiwanese rivers and wetlands, these playful creatures disappeared due to industrial pollution and dam construction.',
      imageUrl: 'https://images.unsplash.com/photo-1593184623299-0a6ef9985933?w=500&q=80',
    ),
    ExtinctAnimal(
      name: 'Ryukyu Flying Fox',
      extinctionYear: '1960s',
      extinctionRate: '100%',
      causes: 'Deforestation, hunting, typhoons',
      history: 'This large fruit bat was endemic to Taiwan and played a vital role in seed dispersal and forest regeneration.',
      imageUrl: 'https://images.unsplash.com/photo-1581389835846-175510b656a8?w=500&q=80',
    ),
    ExtinctAnimal(
      name: 'Japanese Sea Lion',
      extinctionYear: '1974',
      extinctionRate: '100%',
      causes: 'Hunting, commercial fishing',
      history: 'Found in the Sea of Japan, this marine mammal was hunted to extinction for its oil and use in circuses.',
      imageUrl: 'https://images.unsplash.com/photo-1560275317-60f42b032e5b?w=500&q=80',
    ),
    ExtinctAnimal(
      name: 'Sivatherium',
      extinctionYear: '8,000 years ago',
      extinctionRate: '100%',
      causes: 'Climate change, human hunting',
      history: 'A prehistoric relative of the giraffe, Sivatherium was a massive herbivore that roamed across Africa and Asia.',
      imageUrl: 'https://images.unsplash.com/photo-1614027164847-1b28acc1df1f?w=500&q=80',
    ),
    ExtinctAnimal(
      name: 'Stegodon',
      extinctionYear: '12,000 years ago',
      extinctionRate: '100%',
      causes: 'Climate change, volcanic activity',
      history: 'An ancient relative of the elephant, fossils of this large proboscidean have been found across Asia, including Taiwan.',
      imageUrl: 'https://images.unsplash.com/photo-1557053908-4793c4e803c5?w=500&q=80',
    ),
    ExtinctAnimal(
      name: 'Megaloceros',
      extinctionYear: '7,700 years ago',
      extinctionRate: '100%',
      causes: 'Habitat loss, climate change',
      history: 'Known as the "Irish Elk," this giant deer had the largest antlers of any known deer species and lived across Eurasia.',
      imageUrl: 'https://images.unsplash.com/photo-1507146426996-321327aa0ac5?w=500&q=80',
    ),
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

  @override
  void initState() {
    super.initState();
    _fetchAirPollutionData();
    _pageController = PageController(viewportFraction: 0.8);
    // Auto-animate carousel
    _startCarouselAutoPlay();
  }

  void _startCarouselAutoPlay() {
    // This function automatically rotates the carousel every 5 seconds.
    // It was already in your code and works correctly.
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && _pageController.hasClients) {
        _currentCarouselIndex = (_currentCarouselIndex + 1) % _extinctAnimals.length;
        _pageController.animateToPage(
          _currentCarouselIndex,
          duration: Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
        _startCarouselAutoPlay(); // Loop
      }
    });
  }

  Future<void> _fetchAirPollutionData() async {
    const apiKey = "1d64f7fd7d09c7981f9354a449a433c8";
    // Your new API key
    const lat = "25.0330";
    // Taipei coordinates
    const lon = "121.5654";
    final url = Uri.parse('http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final components = data['list'][0]['components'];
        final main = data['list'][0]['main'];

        // Create gas metrics with descriptions
        final List<GasMetric> fetchedMetrics = [
          GasMetric(
              label: 'CO',
              value: components['co'].toDouble(),
              color: Colors.grey,
              icon: Icons.cloud_queue,
              description: 'Carbon Monoxide - from vehicle emissions and industrial processes'
          ),
          GasMetric(
              label: 'NO₂',
              value: components['no2'].toDouble(),
              color: Colors.orange,
              icon: Icons.grain,
              description: 'Nitrogen Dioxide - from burning fossil fuels'
          ),
          GasMetric(
              label: 'O₃',
              value: components['o3'].toDouble(),
              color: Colors.blueAccent,
              icon: Icons.public,
              description: 'Ozone - formed by chemical reactions in sunlight'
          ),
          GasMetric(
              label: 'SO₂',
              value: components['so2'].toDouble(),
              color: Colors.red,
              icon: Icons.whatshot,
              description: 'Sulfur Dioxide - from burning coal and oil'
          ),
          GasMetric(
              label: 'PM₂.₅',
              value: components['pm2_5'].toDouble(),
              color: Colors.brown,
              icon: Icons.blur_on,
              description: 'Fine Particulate Matter - tiny particles that penetrate lungs'
          ),
          GasMetric(
              label: 'PM₁₀',
              value: components['pm10'].toDouble(),
              color: Colors.deepPurple,
              icon: Icons.scatter_plot,
              description: 'Coarse Particulate Matter - dust, pollen, mold'
          ),
        ];

        setState(() {
          _gasMetrics = fetchedMetrics;
          _aqi = main['aqi'];
          _aqiLevel = 'Level $_aqi';
          _isLoading = false;
        });
      } else {
        // Fallback data if API fails
        _setFallbackData();
        print('Failed to load air pollution data: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback data if network error
      _setFallbackData();
      print('Error fetching air pollution data: $e');
    }
  }

  void _setFallbackData() {
    setState(() {
      _gasMetrics = [
        GasMetric(
            label: 'CO',
            value: 250.0,
            color: Colors.grey,
            icon: Icons.cloud_queue,
            description: 'Carbon Monoxide'
        ),
        GasMetric(
            label: 'NO₂',
            value: 15.0,
            color: Colors.orange,
            icon: Icons.grain,
            description: 'Nitrogen Dioxide'
        ),
        GasMetric(
            label: 'O₃',
            value: 45.0,
            color: Colors.blueAccent,
            icon: Icons.public,
            description: 'Ozone'
        ),
        GasMetric(
            label: 'SO₂',
            value: 5.0,
            color: Colors.red,
            icon: Icons.whatshot,
            description: 'Sulfur Dioxide'
        ),
        GasMetric(
            label: 'PM₂.₅',
            value: 12.0,
            color: Colors.brown,
            icon: Icons.blur_on,
            description: 'Fine Particulate Matter'
        ),
        GasMetric(
            label: 'PM₁₀',
            value: 20.0,
            color: Colors.deepPurple,
            icon: Icons.scatter_plot,
            description: 'Coarse Particulate Matter'
        ),
      ];
      _aqi = 2;
      _aqiLevel = 'Level 2';
      _isLoading = false;
    });
  }

  void _showExtinctAnimalDetails(ExtinctAnimal animal) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: 'Close',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.pets, size: 50, color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        animal.name,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 15),
                    _buildDetailRow('Extinction Year:', animal.extinctionYear),
                    _buildDetailRow('Extinction Rate:', animal.extinctionRate),
                    SizedBox(height: 10),
                    Text('Primary Causes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(animal.causes, style: TextStyle(fontSize: 14)),
                    SizedBox(height: 10),
                    Text('Historical Significance:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(animal.history, style: TextStyle(fontSize: 14)),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(Icons.arrow_back),
                        label: Text('Back to Carousel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showReportIssueForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Report Environmental Issue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder()
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder()
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder()
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder()
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Describe the Issue',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.photo),
                            label: Text('Add Photos'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              side: BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.videocam),
                            label: Text('Add Video'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              side: BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              side: BorderSide(color: Colors.grey),
                            ),
                            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text('Submit Report'),
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
      ),
    );
  }

  void _showVolunteerOpportunities(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Volunteer Opportunities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildVolunteerItem('🌳 Forest Cleanup', 'Join us every Saturday for forest conservation activities', 'Taipei Mountains'),
                  _buildVolunteerItem('🏖️ Beach Cleanup', 'Help clean coastal areas and protect marine life', 'Kenting National Park'),
                  _buildVolunteerItem('🐾 Wildlife Monitoring', 'Assist in tracking and monitoring endangered species', 'Yushan National Park'),
                  _buildVolunteerItem('🌱 Tree Planting', 'Participate in reforestation efforts', 'All Taiwan Regions'),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Volunteer interest registered! We\'ll contact you soon.'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Register Interest'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerItem(String title, String description, String location) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.volunteer_activism, color: Colors.purple),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            SizedBox(height: 4),
            Text('📍 $location', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _showLearningResources(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Learning Resources', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildLearningItem('📚 Endangered Species Guide', 'Complete guide to Taiwan\'s protected wildlife', 'Read'),
                  _buildLearningItem('🌍 Climate Change Impact', 'Understand how climate affects Taiwan\'s ecosystem', 'Watch Video'),
                  _buildLearningItem('♻️ Sustainable Living', 'Tips for eco-friendly daily practices', 'Explore'),
                  _buildLearningItem('🔬 Environmental Science', 'Learn about pollution monitoring and analysis', 'Study'),
                  _buildLearningItem('🏞️ National Parks', 'Virtual tours of Taiwan\'s protected areas', 'Tour'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningItem(String title, String description, String action) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.school, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening $title...'), backgroundColor: Colors.blue),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(action, style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share Environmental Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _buildShareOption(Icons.share, 'Share on Social Media', 'Spread awareness about Taiwan\'s environment'),
            _buildShareOption(Icons.email, 'Email Report', 'Send detailed environmental data via email'),
            _buildShareOption(Icons.file_copy, 'Generate PDF Report', 'Create a comprehensive environmental report'),
            _buildShareOption(Icons.group, 'Share with Community', 'Post in local environmental groups'),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String title, String description) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title feature activated!'), backgroundColor: Colors.green),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context),
          SizedBox(height: 24),
          _buildExtinctAnimalsCarousel(context),
          SizedBox(height: 24),
          _buildPollutionSection(context),
          SizedBox(height: 24),
          _buildSpeciesSection(context),
          SizedBox(height: 24),
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
                    getWelcomeMessage(_aqi, widget.userName),
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

  // #######################################################################
  // ##              MODIFIED CAROUSEL WIDGET STARTS HERE                 ##
  // #######################################################################
  Widget _buildExtinctAnimalsCarousel(BuildContext context) {
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
                Icon(Icons.history, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Extinct Animals of Taiwan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _extinctAnimals.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final animal = _extinctAnimals[index];
                  return GestureDetector(
                    onTap: () => _showExtinctAnimalDetails(animal),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect( // Used to round the image corners
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Display the image from the URL
                            Image.network(
                              animal.imageUrl,
                              fit: BoxFit.cover,
                              // Show a loading indicator
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(child: CircularProgressIndicator());
                              },
                              // Show an error icon if the image fails to load
                              errorBuilder: (context, error, stackTrace) {
                                return Center(child: Icon(Icons.error, color: Colors.red));
                              },
                            ),
                            // Add a dark gradient overlay for text readability
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                ),
                              ),
                            ),
                            // Position the animal's name at the bottom
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Text(
                                animal.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                  shadows: [Shadow(blurRadius: 2, color: Colors.black87)],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Position the "EXTINCT" tag at the top right
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'EXTINCT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            // Indicator dots at the bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_extinctAnimals.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentCarouselIndex == index ? Colors.green : Colors.grey,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  // #######################################################################
  // ##               MODIFIED CAROUSEL WIDGET ENDS HERE                  ##
  // #######################################################################

  Widget _buildPollutionSection(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    double displayedValue;
    Color displayedColor;
    String displayedLabel;
    String displayedUnit;

    if (_selectedMetricIndex == null) {
      // Show AQI when no specific gas is selected
      displayedValue = (_aqi / 5.0) * 100;
      // Convert AQI 1-5 to percentage
      displayedColor = getAqiColor(_aqi);
      displayedLabel = 'AQI';
      displayedUnit = _aqiLevel;
    } else {
      // Show specific gas concentration
      final selectedGas = _gasMetrics[_selectedMetricIndex!];
      displayedValue = selectedGas.value;
      displayedColor = selectedGas.color;
      displayedLabel = selectedGas.label;
      displayedUnit = 'μg/m³';
    }

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
                  'Air Pollution Analysis',
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
                                  _selectedMetricIndex == null ? _aqiLevel : '${displayedValue.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: _selectedMetricIndex == null ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: displayedColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayedLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                if (_selectedMetricIndex == null)
                                  Text(
                                    getAqiDescription(_aqi),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: displayedColor,
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
                    children: List.generate(_gasMetrics.length, (index) {
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
    final metric = _gasMetrics[index];
    final isSelected = _selectedMetricIndex == index;
    final isOverall = _selectedMetricIndex == null;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetricIndex = isSelected ? null : index;
        });
      },
      onLongPress: () {
        // Show gas description on long press
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(metric.description),
            duration: Duration(seconds: 3),
          ),
        );
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
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black, // Kept black for visibility on light backgrounds
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
                  '${metric.value.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 14,
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
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: Colors.red[400],
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
              child: _buildActionCard(context, Icons.report_problem_outlined, 'Report Issue', Colors.orange, onTap: () => _showReportIssueForm(context)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(context, Icons.volunteer_activism_outlined, 'Volunteer', Colors.purple, onTap: () => _showVolunteerOpportunities(context)),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(context, Icons.school_outlined, 'Learn', Colors.blue, onTap: () => _showLearningResources(context)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(context, Icons.share_outlined, 'Share', Colors.green, onTap: () => _showShareOptions(context)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, Color color, {VoidCallback? onTap}) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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