// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for logout
import 'dashboard_page.dart';
import 'ai_analysis.dart';
import 'login_or_register_page.dart';
import 'results_page.dart';
import 'past_analyses_page.dart'; // Import the new past analyses page

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C28),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C28),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Cash Flow Generation', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
               // Sign out the user
              FirebaseAuth.instance.signOut();
              // Navigate back to the login/register page and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginOrRegisterPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Company Profile',
                style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _companyCard(),
            const SizedBox(height: 20),
            const Text('Users',
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _userCard('JJ', 'Jacob Jones', 'jacob.jones@example.com', Colors.deepPurple),
                  _userCard('KW', 'Kristin Watson', 'kristin.watson@example.com', Colors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _companyCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF252535), borderRadius: BorderRadius.circular(15)),
      child: const Row(
        children: [
          CircleAvatar(radius: 25, backgroundColor: Colors.blue, child: Text('AC', style: TextStyle(color: Colors.white))),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Acme Corporation', style: TextStyle(color: Colors.white, fontSize: 18)),
              SizedBox(height: 4),
              Text('Technology', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userCard(String initials, String name, String email, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF252535), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: color, child: Text(initials, style: const TextStyle(color: Colors.white))),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 3),
            Text(email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ]),
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
               // Already on Profile page, no navigation needed
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
               Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const PastAnalysesPage()));
            },
          ),
        ],
      ),
    );
  }
}
