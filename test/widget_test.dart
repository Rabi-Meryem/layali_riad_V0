// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layali_riad/main.dart';

void main() {
  testWidgets('Test d\'affichage de l\'écran initial', (WidgetTester tester) async {
    // 1. Initialisez Firebase pour les tests (si nécessaire)
    // TestWidgetsFlutterBinding.ensureInitialized();
    // await Firebase.initializeApp(); // Décommentez si vous utilisez Firebase dans vos tests

    // 2. Chargez votre app réelle
    await tester.pumpWidget(const MyApp());

    // 3. Vérifiez des éléments spécifiques de VOTRE UI
    expect(find.byType(MaterialApp), findsOneWidget); // Vérifie que l'app principale est chargée
    
    // Exemple : vérifiez si votre écran de login/splash est présent
    expect(find.byKey(const Key('login-screen')), findsOneWidget); // Utilisez des keys spécifiques
    
    // OU vérifiez un texte spécifique de votre app
    expect(find.text('Bienvenue sur Layali Riad'), findsOneWidget);
  });
}