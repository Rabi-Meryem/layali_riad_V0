  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'firebase_options.dart'; // Fichier généré par flutterfire configure
  import 'page_entrer.dart';
  import 'login1.dart';
  import 'wishlist_provider.dart';
  import 'homepage.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialisation de Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      ChangeNotifierProvider(
        create: (_) => WishlistProvider(),
        child: const Layali_Riad(),
      ),
    );
  }

  class Layali_Riad extends StatelessWidget {
    const Layali_Riad({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'RiadGetaway',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
        },
      );
    }
  }