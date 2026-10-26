import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'inscription.dart';
//import 'package:layali_riad/signinpage.dart'as signin; // N'oublie pas d'importer cette page
import 'signinpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: '279652645524-3covnb8p9pel8itfh68c40vbmnc2runp.apps.googleusercontent.com', 
    serverClientId: '279652645524-sec8su6opceesit5hamsh92f6clkblb8.apps.googleusercontent.com', 
  );

  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      debugPrint('ID Token: ${googleAuth.idToken}');
      debugPrint('Access Token: ${googleAuth.accessToken}');

      final response = await http.post(
        Uri.parse('http://192.168.139.187/auth/google.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': googleUser.id,
          'email': googleUser.email,
          'name': googleUser.displayName ?? '',
          'photo': googleUser.photoUrl ?? '',
          'token': googleAuth.idToken ?? '',
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw Exception('Erreur backend: ${response.body}');
      }
    } catch (error) {
      debugPrint('Erreur Google Sign-In: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la connexion Google: ${error.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) return;

      final userData = await _facebookAuth.getUserData();
      final accessToken = result.accessToken?.tokenString ?? '';

      final response = await http.post(
        Uri.parse('http://192.168.139.187/auth/facebook.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': userData['id'] ?? '',
          'email': userData['email'] ?? '',
          'name': userData['name'] ?? '',
          'photo': userData['picture']?['data']?['url'] ?? '',
          'token': accessToken,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw Exception('Erreur backend: ${response.body}');
      }
    } catch (error) {
      debugPrint('Erreur Facebook Login: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la connexion Facebook: ${error.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/asset/img/login_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Enjoy your stay',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'YourCustomFont',
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Color.fromARGB(255, 217, 177, 140),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => _signInWithGoogle(context),
                  icon: const Icon(Icons.account_circle),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Color.fromARGB(255, 35, 9, 1),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _signInWithFacebook(context),
                  icon: const Icon(Icons.facebook),
                  label: const Text('Continue with Facebook'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SigninPage()),
                        );
                      },
                      child: const Text(
                        "SIGN IN",
                        style: TextStyle(
                          color: Color.fromARGB(255, 231, 190, 149),
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                      },
                      child: const Text(
                        "SIGN UP",
                        style: TextStyle(
                          color: Color.fromARGB(255, 231, 190, 149),
                          decoration: TextDecoration.underline,
                          fontSize: 18,
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
    );
  }
}
