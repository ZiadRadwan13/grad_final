// lib/pages/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart'; // Import the ProfilePage

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Function to get the user's email from Firebase
  Future<String> _getUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.email ?? "No Email"; // If email is null return "No Email" instead of null
    } else {
      throw Exception('User not logged in'); // Handle the case where there is no user.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<String>(
            future: _getUserEmail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show loading while fetching email
              } else if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}', // Show error message
                  style: const TextStyle(color: Colors.red),
                );
              } else if (snapshot.hasData) {
                final email = snapshot.data!;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Welcome, $email',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        ); // Navigate to the ProfilePage
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      child: const Text('Go to Profile'), // Button text
                    ),
                  ],
                );
              } else {
                return const Text('Welcome, User'); // Show this if snapshot.data is null
              }
            },
          ),
        ),
      ),
    );
  }
}