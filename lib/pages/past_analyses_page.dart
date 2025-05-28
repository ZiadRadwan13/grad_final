// lib/pages/past_analyses_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'ai_analysis.dart';
import 'results_page.dart';
import 'login_or_register_page.dart';
import 'package:intl/intl.dart'; // For formatting dates

class PastAnalysesPage extends StatelessWidget {
  const PastAnalysesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userId = user?.uid;

    // If user is not logged in, show an error or redirect
    if (userId == null) {
      // This case should be handled by your authentication flow,
      // but adding a fallback here.
      return const Scaffold(
         backgroundColor: Color(0xFF1C1C28),
         appBar: null, // Or a simple app bar
         body: Center(child: Text('User not logged in', style: TextStyle(color: Colors.white))),
      );
    }

    // Stream to listen for changes in the user's analyses subcollection
    // Orders by timestamp in descending order (most recent first)
    final Stream<QuerySnapshot> analysesStream = FirebaseFirestore.instance
        .collection('users') // Top-level collection for users
        .doc(userId) // Document for the current user
        .collection('analyses') // Subcollection for this user's analyses
        .orderBy('timestamp', descending: true) // Order by the timestamp field
        .snapshots(); // Get a stream of snapshots

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C28),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Past Analyses',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: analysesStream, // The stream of analysis documents
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Handle potential errors
          if (snapshot.hasError) {
            return Center(child: Text('Error loading analyses: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          // Show a loading indicator while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there's no data or the list is empty, show a message
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No past analyses found.',
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
            );
          }

          // If data is available, display the list of analyses
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              // Cast the document data to a Map
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              // Get the unique ID of the analysis document
              String analysisId = document.id;
              // Get the timestamp and format it
              // Check if timestamp is not null before casting
              Timestamp? timestamp = data['timestamp'] as Timestamp?;
              String formattedDate = timestamp != null ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate()) : 'N/A';


              // Get features and products for display (optional summary)
              List<dynamic> features = data['features'] ?? [];
              List<dynamic> products = data['products'] ?? [];

              return Card(
                color: const Color(0xFF252535), // Card background color
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0, // Add a little shadow
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
                child: ListTile(
                  title: Text('Analysis on $formattedDate', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Features: ${features.length}, Products: ${products.length}', style: const TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                  onTap: () {
                    // Navigate to the ResultsPage, passing the analysis ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultsPage(analysisId: analysisId),
                      ),
                    );
                  },
                ),
              );
            }).toList(), // Convert the map result to a list of Widgets
          );
        },
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
               Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const ResultsPage()));
            },
          ),
           ListTile( // Add this ListTile
            leading: const Icon(Icons.history, color: Colors.white),
            title: const Text('Past Analyses', style: TextStyle(color: Colors.white)),
            onTap: () {
               Navigator.pop(context); // Close the drawer
               // Already on Past Analyses page, no navigation needed
            },
          ),
        ],
      ),
    );
  }
}
