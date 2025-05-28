// login_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';

  void signUserIn() async {
    setState(() {
      errorMessage = ''; // Clear previous errors on new attempt
    });

    // Initial check for empty fields
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Attempt to sign in with Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Dismiss loading indicator
      Navigator.pop(context);
      // Navigate on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Dismiss loading indicator
      Navigator.pop(context);
      // Handle specific Firebase Authentication errors
      switch (e.code) {
        case 'user-not-found':
          setState(() {
            errorMessage =
            'No account attached to email. please sign up using a new email';
          });
          break;
        case 'wrong-password': // <-- Handles incorrect password
          setState(() {
            errorMessage = 'Incorrect password. Please check your password.';
          });
          break;
        case 'invalid-email': // <-- Handles invalid email format
          setState(() {
            errorMessage = 'Invalid email format.';
          });
          break;
        case 'user-disabled': // <-- Handles disabled accounts
          setState(() {
            errorMessage = 'This account has been disabled.';
          });
          break;
        default: // <-- Handles any other FirebaseAuthException
          setState(() {
            errorMessage = 'Firebase Authentication Error: ${e.message}'; // More specific error for debugging
          });
          print('FirebaseAuthException: ${e.code} - ${e.message}'); // Log for debugging
          break;
      }
    } catch (e) {
      // Dismiss loading indicator for non-FirebaseAuth errors
      Navigator.pop(context);
      // Handle any other unexpected errors
      print('An unexpected error occurred: $e'); // Log for debugging
      setState(() {
        errorMessage = 'An unexpected error occurred.'; // Generic error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C28), // Dark background color
      body: SafeArea( // Ensures content is not behind system UI
        child: Center( // Centers the content vertically and horizontally
          child: SingleChildScrollView( // Allows scrolling if content overflows
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30), // Horizontal padding
              child: Column( // Column to arrange widgets vertically
                mainAxisAlignment: MainAxisAlignment.center, // Center column content
                children: [
                  // Lock Icon
                  const Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Icon(Icons.lock, size: 50, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30), // Vertical spacing

                  // Title
                  const Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30), // Vertical spacing

                  // Email TextField
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF252535), // Darker field color
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon:
                      const Icon(Icons.email_outlined, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                        borderSide: BorderSide.none, // No visible border line
                      ),
                    ),
                    style: const TextStyle(color: Colors.white), // White text color
                  ),
                  const SizedBox(height: 15), // Vertical spacing

                  // Password TextField
                  TextField(
                    controller: passwordController,
                    obscureText: true, // Hides password text
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF252535), // Darker field color
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                        borderSide: BorderSide.none, // No visible border line
                      ),
                    ),
                    style: const TextStyle(color: Colors.white), // White text color
                  ),
                  const SizedBox(height: 30), // Vertical spacing

                  // Log In Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Button color
                      minimumSize: const Size(double.infinity, 50), // Full width, fixed height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded button corners
                      ),
                    ),
                    onPressed: signUserIn, // Calls the signUserIn function
                    child: const Text(
                      'Log In',
                      style: TextStyle(fontSize: 18, color: Colors.white), // Button text style
                    ),
                  ),
                  const SizedBox(height: 10), // Vertical spacing

                  // Error Message Text
                  if (errorMessage.isNotEmpty) // <-- Conditionally shows the error message
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        errorMessage, // Displays the current error message
                        style: const TextStyle(color: Colors.red), // Red text for errors
                      ),
                    ),
                  const SizedBox(height: 20), // Vertical spacing

                  // Forgot Password Button
                  TextButton(
                    onPressed: () {
                      Navigator.push( // Navigate to forgot password page
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blueAccent), // Button text style
                    ),
                  ),

                  // Sign Up Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center row content
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey), // Text style
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement( // Navigate to signup page
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.blueAccent), // Button text style
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}