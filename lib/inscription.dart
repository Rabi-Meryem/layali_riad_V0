import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';
import 'dart:async'; // Pour TimeoutException

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _nameError;
  String? _phoneError;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Réinitialisation des erreurs
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _nameError = null;
      _phoneError = null;
    });

    // Validation du formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation de la longueur du mot de passe
    if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = "Le mot de passe doit contenir au moins 6 caractères";
      });
      return;
    }

    // Validation de la correspondance des mots de passe
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = "Les mots de passe ne correspondent pas";
        _confirmPasswordError = "Les mots de passe ne correspondent pas";
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      const url = 'http://192.168.139.187/flutter_auth/register.php';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'phone': _phoneController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        // Inscription réussie
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Gestion des erreurs serveur
        _handleServerError(responseData);
      }
    } on http.ClientException catch (e) {
      setState(() {
        _emailError = 'Erreur de réseau: ${e.message}';
      });
    } on TimeoutException {
      setState(() {
        _emailError = 'La connexion a expiré';
      });
    } catch (e) {
      setState(() {
        _emailError = 'Une erreur inattendue est survenue';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleServerError(Map<String, dynamic> responseData) {
    setState(() {
      if (responseData['error'] != null) {
        if (responseData['error'].toString().toLowerCase().contains('email')) {
          _emailError = responseData['error'].toString();
        } else if (responseData['error'].toString().toLowerCase().contains('password')) {
          _passwordError = responseData['error'].toString();
        } else {
          _emailError = responseData['error'].toString();
        }
      } else {
        _emailError = responseData['message'] ?? 'Erreur lors de l\'inscription';
      }
    });
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome to Layali Riad',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 80),
                    _buildInputField(
                      label: 'Full Name',
                      controller: _nameController,
                      errorText: _nameError,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Email',
                      controller: _emailController,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      label: 'Password',
                      controller: _passwordController,
                      errorText: _passwordError,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      errorText: _confirmPasswordError,
                      isPassword: true,
                      isConfirm: true,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Phone',
                      controller: _phoneController,
                      errorText: _phoneError,
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 60),
                    _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : _buildRoundedButton(
                            label: 'Sign Up',
                            onTap: _register,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 217, 177, 140).withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: const EdgeInsets.only(top: 8),
              hintText: label,
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              if (label.toLowerCase().contains('email') && 
                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email invalide';
              }
              if (label.toLowerCase().contains('phone') && 
                  !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                return 'Numéro invalide (10 chiffres)';
              }
              return null;
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    String? errorText,
    bool isPassword = false,
    bool isConfirm = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 217, 177, 140).withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : _obscureConfirmPassword,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: const EdgeInsets.only(top: 8),
              hintText: label,
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(Icons.lock, color: Colors.black54),
              suffixIcon: IconButton(
                icon: Icon(
                  isPassword ? _obscurePassword ? Icons.visibility : Icons.visibility_off 
                           : _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    if (isPassword) {
                      _obscurePassword = !_obscurePassword;
                    } else {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    }
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              if (isConfirm && value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildRoundedButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 24, 212, 205).withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18, 
            color: Colors.black, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}