// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for logout
import 'profile_page.dart';
import 'ai_analysis.dart';
import 'login_or_register_page.dart';
import 'results_page.dart';
import 'past_analyses_page.dart'; // Import the new past analyses page

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard',
                style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoCard('Sales', '\$12,500', Icons.show_chart, Colors.blue),
                _infoCard('Revenue', '\$8,750', Icons.attach_money, Colors.blueAccent),
              ],
            ),
            const SizedBox(height: 20),
            Expanded( // Wrap the cash flow container with Expanded
               child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252535),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cash Flow', style: TextStyle(color: Colors.grey)),
                      const Text('+33,450',
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                      Expanded( // Wrap the chart with Expanded
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5)],
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF252535), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
               // Already on Dashboard page, no navigation needed
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
               Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const PastAnalysesPage()));
            },
          ),
        ],
      ),
    );
  }
}
