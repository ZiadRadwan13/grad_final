// lib/pages/ai_analysis.dart
// For json.decode
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'login_or_register_page.dart';
import 'results_page.dart';
import 'past_analyses_page.dart'; // Import the new past analyses page


class AiAnalysisPage extends StatefulWidget {
  const AiAnalysisPage({super.key});

  @override
  _AiAnalysisPageState createState() => _AiAnalysisPageState();
}

class _AiAnalysisPageState extends State<AiAnalysisPage> {
  // State variables to control which section is visible
  bool _showInitialContent = true;
  bool _showInputSection = false;
  bool _showProgressBar = false;
  bool _showResultsButton = false;

  // State for progress bar
  double _progress = 0.0;
  Timer? _timer;
  int _timeRemaining = 15; // For the 15-second simulation

  // State for dynamic inputs
  final List<TextEditingController> _featureControllers = [];
  final List<TextEditingController> _productControllers = [];

  // Variable to store the ID of the newly created analysis in Firestore
  String? _currentAnalysisId;

  // Get the current user's UID
  final String? userId = FirebaseAuth.instance.currentUser?.uid;


  @override
  void dispose() {
    _timer?.cancel();
    // Dispose controllers
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    for (var controller in _productControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Methods for managing inputs
  void _addFeatureField() {
    setState(() {
      _featureControllers.add(TextEditingController());
    });
  }

  void _removeFeatureField(int index) {
    setState(() {
      _featureControllers[index].dispose();
      _featureControllers.removeAt(index);
    });
  }

  void _addProductField() {
    setState(() {
      _productControllers.add(TextEditingController());
    });
  }

  void _removeProductField(int index) {
    setState(() {
      _productControllers[index].dispose();
      _productControllers.removeAt(index);
    });
  }

  // Validation for feature/product names (single name with underscores)
  bool _isValidName(String name) {
    // Allow alphanumeric characters and underscores
    return RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name);
  }

  // Method called when the initial Generate button is pressed
  void _onGenerateButtonPressed() {
     // Ensure user is logged in before allowing input
     if (userId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to generate analysis.'),
          backgroundColor: Colors.redAccent,
        ),
      );
       return;
     }

    setState(() {
      _showInitialContent = false;
      _showInputSection = true;
      _showProgressBar = false;
      _showResultsButton = false;
      // Initialize with a few fields or let the user add
      if (_featureControllers.isEmpty) _addFeatureField();
      if (_productControllers.isEmpty) _addProductField();
    });
  }

  // Method to save the user's inputs to Firebase
  Future<void> _saveAnalysisInputs() async {
     if (userId == null) return; // Should not happen if _onGenerateButtonPressed checked

     try {
       final featureNames = _featureControllers.map((c) => c.text.trim()).toList();
       final productNames = _productControllers.map((c) => c.text.trim()).toList();

       // Add a new document to the 'analyses' subcollection under the user's document
       DocumentReference docRef = await FirebaseFirestore.instance
           .collection('users') // Collection for all users
           .doc(userId) // Document for the current user
           .collection('analyses') // Subcollection for this user's analyses
           .add({
         'timestamp': FieldValue.serverTimestamp(), // Use server timestamp for consistency
         'features': featureNames,
         'products': productNames,
         // Results will be added later, or can be placeholders initially
         // In a real app, you'd save your analysis results structure here
         'results': {
            // Placeholder structure for results
            // You'll need to define the actual structure based on your AI output
            'revenue_data': [], // e.g., List of maps {'x': value, 'y': value}
            'product_importance_data': [], // e.g., List of maps {'name': 'Product A', 'importance': 'High', 'duration': '6 Months'}
         },
       });

       // Store the ID of the newly created document
       _currentAnalysisId = docRef.id;

       print('Analysis inputs saved with ID: $_currentAnalysisId');

     } catch (e) {
       print('Error saving analysis inputs: $e');
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving analysis inputs: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
       // Optionally revert UI or show error state if saving fails
       setState(() {
          _showInputSection = true; // Stay on input page if saving fails
          _showProgressBar = false;
       });
     }
  }


  // Method called when the Start Analysis button in the input section is pressed
  void _startAnalysis() async { // Make this async to await saving inputs
    // Basic validation
    bool isValid = true;
    if (_featureControllers.isEmpty && _productControllers.isEmpty) {
        isValid = false;
    } else {
        for (var controller in _featureControllers) {
          if (controller.text.trim().isEmpty || !_isValidName(controller.text.trim())) {
            isValid = false;
            break;
          }
        }
         if (isValid) {
            for (var controller in _productControllers) {
               if (controller.text.trim().isEmpty || !_isValidName(controller.text.trim())) {
                  isValid = false;
                  break;
               }
            }
         }
    }


    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one feature or product and ensure all names are valid (alphanumeric and underscores only).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Stop if validation fails
    }

    // Save inputs to Firebase before starting simulation
    await _saveAnalysisInputs();

    // Only start the simulation if inputs were saved successfully
    if (_currentAnalysisId != null) {
        setState(() {
          _showInputSection = false;
          _showProgressBar = true;
          _showResultsButton = false;
          _progress = 0.0;
          _timeRemaining = 15;
        });

        const int totalSeconds = 15;
        const int updateIntervalMilliseconds = 1000; // Update every second
        int elapsedSeconds = 0;

        _timer = Timer.periodic(const Duration(milliseconds: updateIntervalMilliseconds), (timer) {
          setState(() {
            elapsedSeconds++;
            _timeRemaining = totalSeconds - elapsedSeconds;
            _progress = elapsedSeconds / totalSeconds;

            if (elapsedSeconds >= totalSeconds) {
              _timer?.cancel();
              _showProgressBar = false;
              _showResultsButton = true;
              _progress = 1.0; // Ensure it reaches 100%
              _timeRemaining = 0;
               // --- Placeholder for saving actual analysis results ---
               // In a real app, once the analysis process (simulated here)
               // is complete, you would get the actual results (graph data,
               // product importance) and save them to the Firestore document
               // identified by _currentAnalysisId.
               // Example:
               // final actualResults = _performAnalysis(); // Your analysis logic
               // _saveAnalysisResults(_currentAnalysisId!, actualResults);
               // -------------------------------------------------------
            }
          });
        });
    }
  }

  // --- Placeholder method for saving results ---
  // Future<void> _saveAnalysisResults(String analysisId, Map<String, dynamic> resultsData) async {
  //   if (userId == null) return;
  //    try {
  //      await FirebaseFirestore.instance
  //          .collection('users')
  //          .doc(userId)
  //          .collection('analyses')
  //          .doc(analysisId)
  //          .update({
  //        'results': resultsData, // Save the actual analysis results structure
  //      });
  //      print('Analysis results saved for ID: $analysisId');
  //    } catch (e) {
  //      print('Error saving analysis results: $e');
  //      // Handle error
  //    }
  // }
  // ---------------------------------------------


  void _goToResultsPage() {
     // Navigate to the ResultsPage, passing the ID of the current analysis
     // The ResultsPage will then load the saved data using this ID.
    if (_currentAnalysisId != null) {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => ResultsPage(analysisId: _currentAnalysisId!),
         ),
       );
    } else {
       // This case should ideally not happen if analysis started successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis ID is missing.'),
            backgroundColor: Colors.redAccent,
          ),
        );
    }
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
               // Already on AI Analysis page, no navigation needed
            },
          ),
           ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.white),
            title: const Text('Results', style: TextStyle(color: Colors.white)),
             // Navigating to Results page without an ID will show placeholders or require logic to handle
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const ResultsPage()));
            }
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


  @override
  Widget build(BuildContext context) {
    // Ensure user is logged in before building the page content that needs user ID
     // This check might be better handled by a wrapper widget outside this page
     // or within your authentication flow.
     if (userId == null) {
       return const Scaffold(
         backgroundColor: Color(0xFF1C1C28),
         appBar: null, // Or a simple app bar
         body: Center(child: Text('User not logged in', style: TextStyle(color: Colors.white))),
       );
     }

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C28),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Cash Flow Generation',
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
      drawer: _buildDrawer(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               const Text(
                'AI Prediction',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                   decoration: BoxDecoration(
                    color: const Color(0xFF252535),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(30),
                  child: _buildBodyContent(), // Use a helper to build content
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the main content based on the current state
  Widget _buildBodyContent() {
    if (_showInitialContent) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.memory, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 20),
          const Text(
            'Analysis',
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _onGenerateButtonPressed, // Call the new method
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(
                  horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Generate',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
               // TODO: Add your upload logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                  horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Upload',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      );
    } else if (_showInputSection) {
       return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Add Features:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addFeatureField,
             style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
            ),
            child: const Text('Add Feature', style: TextStyle(color: Colors.white)),
          ),
           const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _featureControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _featureControllers[index],
                           decoration: InputDecoration(
                             labelText: 'Feature ${index + 1}',
                             hintText: 'e.g., monthly_sales',
                             errorText: _featureControllers[index].text.isNotEmpty && !_isValidName(_featureControllers[index].text) ? 'Invalid name' : null,
                           ),
                           style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                        onPressed: () => _removeFeatureField(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text('Add Products:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
           const SizedBox(height: 10),
           ElevatedButton(
            onPressed: _addProductField,
             style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
            ),
            child: const Text('Add Product', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Expanded(
             child: ListView.builder(
              itemCount: _productControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                   padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _productControllers[index],
                           decoration: InputDecoration(
                             labelText: 'Product ${index + 1}',
                              hintText: 'e.g., product_a',
                              errorText: _productControllers[index].text.isNotEmpty && !_isValidName(_productControllers[index].text) ? 'Invalid name' : null,
                           ),
                           style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                        onPressed: () => _removeProductField(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startAnalysis,
             style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(
                  horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Analysis', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
       );
    } else if (_showProgressBar) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Generating Analysis: ${(_progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
           const SizedBox(height: 10),
           Text(
             'Time Remaining: $_timeRemaining seconds',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
           ),
          const SizedBox(height: 20),
          LinearPercentIndicator(
            percent: _progress,
            lineHeight: 25.0,
            backgroundColor: Colors.grey[700],
            progressColor: Colors.blueAccent,
            barRadius: const Radius.circular(12),
            animation: false, // Animation handled by the timer
          ),
           const SizedBox(height: 20),
           Text(
             'The expected results generation time is usually 24-48 hours. More than ${_featureControllers.length} features will result in a longer time. Your information is now being processed by our Cash Flow Analysis specialists.',
             style: const TextStyle(fontSize: 14, color: Colors.grey),
             textAlign: TextAlign.center,
           )
        ],
      );
    } else if (_showResultsButton) {
       return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           const Icon(Icons.check_circle_outline, size: 80, color: Colors.greenAccent),
            const SizedBox(height: 20),
            const Text(
            'Analysis Complete!',
             style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
           ),
           const SizedBox(height: 20),
           ElevatedButton(
            onPressed: _goToResultsPage,
             style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(
                  horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View Results', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
       );
    } else {
      // Fallback, perhaps show initial content again
      return _buildBodyContent();
    }
  }
}
