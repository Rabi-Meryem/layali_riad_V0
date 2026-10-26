import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'wishlist_provider.dart';
import 'riad_detail_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final favoriteRiads = wishlistProvider.favoriteRiads;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C4C2F),
        title: const Text('Ma Wishlist'),
        actions: [
          if (favoriteRiads.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmClearWishlist(context, wishlistProvider),
            ),
        ],
      ),
      body: favoriteRiads.isEmpty
          ? const Center(
              child: Text(
                'Aucun favori pour le moment 💤',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: favoriteRiads.length,
              itemBuilder: (context, index) {
                final riad = favoriteRiads[index];
                final images = _getImageList(riad);
                final offers = _getOffersList(riad);
                final reviews = _getReviewsList(riad);
                
                return _buildRiadCard(
                  context, 
                  riad, 
                  images,
                  offers,
                  reviews,
                  wishlistProvider
                );
              },
            ),
    );
  }

  List<String> _getImageList(Map<String, dynamic> riad) {
    try {
      if (riad['imageURL'] == null) return [''];
      if (riad['imageURL'] is List) {
        return List<String>.from(riad['imageURL'].map((x) => x.toString()));
      }
      return [riad['imageURL'].toString()];
    } catch (e) {
      debugPrint('Error parsing images: $e');
      return [''];
    }
  }

  List<String> _getOffersList(Map<String, dynamic> riad) {
    try {
      if (riad['offers'] == null) return [];
      if (riad['offers'] is List) {
        return List<String>.from(riad['offers'].map((x) => x.toString()));
      }
      if (riad['offers'] is String) {
        return [riad['offers'].toString()];
      }
      return [];
    } catch (e) {
      debugPrint('Error parsing offers: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _getReviewsList(Map<String, dynamic> riad) {
    try {
      if (riad['reviews'] == null) return [];
      if (riad['reviews'] is List) {
        return List<Map<String, dynamic>>.from(riad['reviews'].map(
          (x) => Map<String, dynamic>.from(x as Map)
        ));
      }
      return [];
    } catch (e) {
      debugPrint('Error parsing reviews: $e');
      return [];
    }
  }

  Widget _buildRiadCard(
    BuildContext context,
    Map<String, dynamic> riad,
    List<String> images,
    List<String> offers,
    List<Map<String, dynamic>> reviews,
    WishlistProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _navigateToRiadDetail(
          context, 
          riad, 
          images,
          offers,
          reviews
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildRiadImage(images),
              const SizedBox(width: 16),
              _buildRiadInfo(riad),
              _buildFavoriteButton(riad, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiadImage(List<String> images) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        images.isNotEmpty ? images[0] : '',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 100,
          height: 100,
          color: Colors.grey,
          child: const Center(child: Icon(Icons.image, size: 40)),
        ),
      ),
    );
  }

  Widget _buildRiadInfo(Map<String, dynamic> riad) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            riad['name']?.toString() ?? 'Nom inconnu',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${riad['cityname']?.toString() ?? ''} • ${riad['price']?.toString() ?? ''}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                riad['rating']?.toString() ?? '0',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(Map<String, dynamic> riad, WishlistProvider provider) {
    return IconButton(
      icon: const Icon(Icons.favorite, color: Colors.red),
      onPressed: () => provider.removeFromWishlistById(riad['id']?.toString() ?? ''),
    );
  }

  void _navigateToRiadDetail(
    BuildContext context,
    Map<String, dynamic> riad,
    List<String> images,
    List<String> offers,
    List<Map<String, dynamic>> reviews,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiadDetailPage(
          name: riad['name']?.toString() ?? 'Nom inconnu',
          price: riad['price'] is String ? riad['price'] : '\$${riad['price']}/nuit',
          locationtype: riad['locationtype']?.toString() ?? '',
          imageURL: images,
          rating: riad['rating']?.toString() ?? '0',
          offers: offers,
          reviews: reviews,
          cityname: riad['cityname']?.toString() ?? '',
          latitude: (riad['latitude'] as num?)?.toDouble() ?? 31.6295,
          longitude: (riad['longitude'] as num?)?.toDouble() ?? -7.9811,
          rooms: riad['rooms']?.toString() ?? '0',
        ),
      ),
    );
  }

  void _confirmClearWishlist(BuildContext context, WishlistProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider la wishlist?'),
        content: const Text('Êtes-vous sûr de vouloir supprimer tous vos favoris?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              provider.clearWishlist();
              Navigator.pop(context);
            },
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}