// lib/pages/results_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Assuming you're using fl_chart
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'dashboard_page.dart'; // Assuming these exist for drawer navigation
import 'profile_page.dart';
import 'ai_analysis.dart';
import 'login_or_register_page.dart'; // Assuming this exists
import 'past_analyses_page.dart'; // Import the new past analyses page
import 'dart:math'; // Import for placeholder data


class ResultsPage extends StatefulWidget {
  // Accept an optional analysis ID
  final String? analysisId;
  // Direct data parameters are less relevant now that we load from Firebase
  // based on analysisId, but kept for potential alternative flows or testing.
  final List<String>? productNames;
  final List<FlSpot>? revenueSpots;
  final List<Map<String, dynamic>>? productImportanceData;


  const ResultsPage({
    Key? key,
    this.analysisId,
    this.productNames,
    this.revenueSpots,
    this.productImportanceData,
  }) : super(key: key);


  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  Map<String, dynamic>? _analysisData; // To store fetched data
  bool _isLoading = true;
  String? _errorMessage;

  // Data to display (either fetched or generated as placeholder)
  List<String> _displayedProductNames = [];
  List<FlSpot> _displayedRevenueSpots = [];
  List<Map<String, dynamic>> _displayedProductImportanceData = [];


  @override
  void initState() {
    super.initState();
    if (widget.analysisId != null) {
      _fetchAnalysisData();
    } else {
      // If no analysisId, use direct data or generate placeholders
      _displayedProductNames = widget.productNames ?? [];
      _displayedRevenueSpots = widget.revenueSpots ?? _generatePlaceholderRevenueSpots(); // Use placeholders if none provided
      _displayedProductImportanceData = widget.productImportanceData ?? _generatePlaceholderImportanceData(_displayedProductNames); // Use placeholders
      setState(() {
        _isLoading = false;
      });
    }
  }

   // Function to fetch analysis data from Firestore
   Future<void> _fetchAnalysisData() async {
       final User? user = FirebaseAuth.instance.currentUser;
       final String? userId = user?.uid;

       if (userId == null || widget.analysisId == null) {
           setState(() {
               _errorMessage = 'User not logged in or analysis ID missing.';
               _isLoading = false;
           });
           return;
       }

       try {
           DocumentSnapshot doc = await FirebaseFirestore.instance
               .collection('users')
               .doc(userId)
               .collection('analyses')
               .doc(widget.analysisId)
               .get();

           if (doc.exists) {
               _analysisData = doc.data() as Map<String, dynamic>;
               List<dynamic> fetchedProducts = _analysisData?['products'] ?? [];
               _displayedProductNames = List<String>.from(fetchedProducts);


               // --- IMPORTANT: Replace with parsing actual saved results data ---
               // You will need to parse the actual saved 'results' structure here
               // For now, generating placeholders based on loaded product names and features
               List<dynamic> fetchedFeatures = _analysisData?['features'] ?? [];


               // Example placeholder generation based on fetched data
               _displayedRevenueSpots = _generatePlaceholderRevenueSpots(fetchedFeatures.length); // Adjust placeholder based on features count
               _displayedProductImportanceData = _generatePlaceholderImportanceData(_displayedProductNames); // Generate based on fetched products
               // -----------------------------------------------------------------


           } else {
               _errorMessage = 'Analysis not found.';
           }
       } catch (e) {
           _errorMessage = 'Error fetching analysis: $e';
           print('Error fetching analysis: $e');
       } finally {
           setState(() {
               _isLoading = false;
           });
       }
   }

   // Placeholder function to generate revenue spots (for when data isn't fetched or parsed)
   // Adjusted to take number of features as a hint for data points
   List<FlSpot> _generatePlaceholderRevenueSpots([int numberOfFeatures = 5]) {
       final random = Random();
       List<FlSpot> spots = [];
       // Generate spots based on number of features, up to a reasonable limit
       int numSpots = min(numberOfFeatures + 2, 10); // Max 10 spots for example
       for(int i = 0; i < numSpots; i++) {
           // Generate random Y values between 100 and 30000
           double yValue = 100 + random.nextDouble() * (30000 - 100);
           spots.add(FlSpot(i.toDouble(), yValue));
       }
       return spots;
   }

  // Placeholder function to generate importance and duration (for when data isn't fetched or parsed)
  List<Map<String, dynamic>> _generatePlaceholderImportanceData(List<String> productNames) {
    final random = Random();
    final importanceLevels = ['High Importance', 'Medium Importance', 'Low Importance'];
    final durations = ['Next 1 Month', 'Next 3 Months', 'Next 6 Months', 'Next 1 Year'];

    final List<Map<String, dynamic>> importanceData = [];
    for (final productName in productNames) {
      final importance = importanceLevels[random.nextInt(importanceLevels.length)];
      final duration = durations[random.nextInt(durations.length)];
      importanceData.add({
        'name': productName,
        'importance': importance,
        'duration': duration,
      });
    }
    return importanceData;
  }


  @override
  Widget build(BuildContext context) {
     // Show loading indicator while fetching data
     if (_isLoading) {
       return const Scaffold(
         backgroundColor: Color(0xFF1C1C28),
          appBar: null, // Or a simple app bar
         body: Center(child: CircularProgressIndicator()),
       );
     }

     // Show error message if fetching failed
     if (_errorMessage != null) {
       return Scaffold(
          backgroundColor: const Color(0xFF1C1C28),
           appBar: null, // Or a simple app bar
          body: Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.redAccent))),
       );
     }

     // Build the results UI once data is loaded or available
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C28),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Analysis Results',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
               // Sign out the user
              FirebaseAuth.instance.signOut();
              // Navigate back to the login/register page and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginOrRegisterPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context), // Add the drawer for navigation
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Expected Revenue Prediction:', // Updated text
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              // Area for the revenue graph
              Container(
                height: 250, // Slightly increased height for labels
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF252535),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 1.70,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return const FlLine(
                              color: Color(0xff37434d),
                              strokeWidth: 0.5,
                            );
                          }),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                               String text = '';
                               // You might want to base these labels on your actual time data
                               // For placeholder, using simple numbering or months
                               switch (value.toInt()) {
                                 case 0: text = '1 month'; break;
                                 case 1: text = '2 months'; break;
                                 case 2: text = '3 months'; break;
                                 case 3: text = '4 months'; break;
                                 case 4: text = '5 months'; break;
                                 case 5: text = '6 months'; break;
                                 case 6: text = '7 months'; break;
                                 case 7: text = '8 months'; break;
                                 case 8: text = '9 months'; break;
                                 case 9: text = '10 months'; break;
                               }
                               return SideTitleWidget(
                                 axisSide: meta.axisSide,
                                 space: 8.0,
                                 child: Text(text, style: const TextStyle(color: Color(0xff67727d), fontSize: 12)),
                               );
                            },
                            interval: 1,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                             getTitlesWidget: (value, meta) {
                               String text;
                               if (value >= 30000) {
                                 text = '\$30k';
                               } else if (value >= 20000) {
                                 text = '\$20k';
                               } else if (value >= 10000) {
                                 text = '\$10k';
                               } else if (value >= 100) {
                                 text = '\$${value.toInt()}';
                               }
                                else {
                                 return Container(); // Don't show labels for other values
                               }
                               return Text(text, style: const TextStyle(color: Color(0xff67727d), fontSize: 12), textAlign: TextAlign.left);
                            },
                            interval: 10000, // Adjust interval to show labels at desired points
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      // Use displayed revenue spots
                      lineBarsData: [
                        LineChartBarData(
                          spots: _displayedRevenueSpots,
                          isCurved: true,
                          color: Colors.blueAccent,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.3)),
                        ),
                      ],
                       minY: 0, // Start Y axis at 0 for better visualization
                       maxY: 32000, // Set max slightly above 30k
                       minX: 0,
                       maxX: (_displayedRevenueSpots.length > 1 ? _displayedRevenueSpots.length - 1 : 0).toDouble(), // Adjust max X based on number of data points
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Product Importance:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              // Area for product importance list - Now built dynamically
              Container(
                 padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF252535),
                  borderRadius: BorderRadius.circular(12),
                ),
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _displayedProductImportanceData.isEmpty
                        ? [ // Show a message if no products were entered or data wasn't loaded
                            const Text(
                              'No product importance data available.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ]
                        : _displayedProductImportanceData.map((productData) {
                             final productName = productData['name'] ?? 'Unnamed Product';
                             final importance = productData['importance'] ?? 'N/A';
                             final duration = productData['duration'] ?? 'N/A';
                             return _buildProductImportanceItem(productName, importance, duration);
                          }).toList(), // Map product data to importance items
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImportanceItem(String productName, String importance, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text('Importance: $importance', style: const TextStyle(color: Colors.grey)),
          Text('Duration: $duration', style: const TextStyle(color: Colors.grey)),
          const Divider(color: Colors.grey), // Add a divider between items
        ],
      ),
    );
  }

   Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1C1C28),
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF252535)),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.white),
            title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
            onTap: () {
               Navigator.pop(context); // Close the drawer
               Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const DashboardPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
               Navigator.pop(context); // Close the drawer
               Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.white),
            title: const Text('AI Analysis', style: TextStyle(color: Colors.white)),
            onTap: () {
               Navigator.pop(context); // Close the drawer
               Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const AiAnalysisPage()));
            },
          ),
           ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.white),
            title: const Text('Results', style: TextStyle(color: Colors.white)),
            onTap: () {
               Navigator.pop(context); // Close the drawer
               // Already on results page if accessed from Past Analyses, otherwise navigate
               // A simple check to avoid unnecessary navigation if already on the page
               if (ModalRoute.of(context)?.settings.name != '/results') {
                 Navigator.pushReplacement(
                   context, MaterialPageRoute(builder: (_) => const ResultsPage()));
               }
            },
          ),
           ListTile(
            leading: const Icon(Icons.history, color: Colors.white),
            title: const Text('Past Analyses', style: TextStyle(color: Colors.white)),
            onTap: () {
               Navigator.pop(context); // Close the drawer
               Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const PastAnalysesPage()));
            },
          ),
        ],
      ),
    );
  }
}
