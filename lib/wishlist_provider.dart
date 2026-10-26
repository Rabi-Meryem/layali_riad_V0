import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _favoriteRiads = [];

  /// Retourne une copie non modifiable de la liste des favoris
  List<Map<String, dynamic>> get favoriteRiads => List.unmodifiable(_favoriteRiads);

  /// Retourne le nombre de favoris
  int get count => _favoriteRiads.length;

  /// Ajoute un riad à la wishlist s'il n'existe pas déjà
  void addToWishlist(Map<String, dynamic> riad) {
    try {
      if (riad['id'] == null) throw Exception("Le riad doit avoir un id");
      
      if (!_favoriteRiads.any((item) => item['id'] == riad['id'])) {
        _favoriteRiads.add(Map<String, dynamic>.from(riad));
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur lors de l'ajout à la wishlist: $e");
    }
  }

  /// Supprime un riad par son id
  void removeFromWishlistById(String id) {
    final initialCount = _favoriteRiads.length;
    _favoriteRiads.removeWhere((item) => item['id'] == id);
    if (_favoriteRiads.length != initialCount) {
      notifyListeners();
    }
  }

  /// Supprime un riad par son index
  void removeFromWishlistAt(int index) {
    if (index >= 0 && index < _favoriteRiads.length) {
      _favoriteRiads.removeAt(index);
      notifyListeners();
    }
  }

  /// Vérifie si un riad est dans la wishlist
  bool isInWishlist(Map<String, dynamic> riad) {
    try {
      return riad['id'] != null && 
             _favoriteRiads.any((item) => item['id'] == riad['id']);
    } catch (e) {
      debugPrint("Erreur dans isInWishlist: $e");
      return false;
    }
  }

  /// Ajoute ou retire un riad de la wishlist
  void toggleWishlist(Map<String, dynamic> riad) {
    try {
      if (isInWishlist(riad)) {
        removeFromWishlistById(riad['id']);
      } else {
        addToWishlist(riad);
      }
    } catch (e) {
      debugPrint("Erreur dans toggleWishlist: $e");
    }
  }

  /// Vide toute la wishlist
  void clearWishlist() {
    if (_favoriteRiads.isNotEmpty) {
      _favoriteRiads.clear();
      notifyListeners();
    }
  }
}