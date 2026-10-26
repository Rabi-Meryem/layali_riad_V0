package com.example.layali_riad
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine // Ajoutez cette ligne

class MainActivity: FlutterActivity() {
    // Si vous utilisez Facebook, ajoutez ceci :
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Initialisation Facebook si nécessaire
    }
}