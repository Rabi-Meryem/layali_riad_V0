import 'package:flutter/material.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 94, 40, 6), Color(0xFF6a3e32)], // Couleurs marron pour l'arrière-plan
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Le logo est maintenant au-dessus du nom de l'application
            Image.asset(
              'lib/asset/img/logop2.png', // Le logo de l'application (assure-toi de placer le fichier logo dans les assets)
              height: 120,
            ),
            const SizedBox(height: 20), // Espacement entre le logo et le texte du nom
            const Text(
              'Layali Riad', // Nom de l'application
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Texte blanc
              ),
            ),
            const SizedBox(height: 20),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login'); // Naviguer vers la page de connexion
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 24, 212, 205), // Bouton marron
                    foregroundColor: Color.fromARGB(255, 255, 252, 250), // Texte du bouton en couleur blanche
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            /*const Text(
              'Explorez les merveilles du Maroc, un riad à la fois.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),*/
          ],
        ),
      ),
    );
  }
}
