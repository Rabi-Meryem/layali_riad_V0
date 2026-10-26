import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'homepage.dart';
import 'riad_detail_page.dart';

class GuestsPage1 extends StatefulWidget {
  final List<Map<String, dynamic>> searchResults;
  final String searchQuery;
  final DateTime startDate;
  final DateTime endDate;
  final bool fromReservation;

  const GuestsPage1({
    Key? key,
    required this.searchResults,
    required this.searchQuery,
    required this.startDate,
    required this.endDate,
    required this.fromReservation,
  }) : super(key: key);

  @override
  State<GuestsPage1> createState() => _GuestsPage1State();
}

class _GuestsPage1State extends State<GuestsPage1> {
  int adults = 2;
  int children = 0;
  int babies = 0;
  bool pets = false;

  Widget _buildCounter(String label, int value, VoidCallback onIncrement, VoidCallback onDecrement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove), onPressed: onDecrement),
            Text('$value', style: const TextStyle(fontSize: 18)),
            IconButton(icon: const Icon(Icons.add), onPressed: onIncrement),
          ],
        ),
      ],
    );
  }

  void _handleReservationConfirmation() {
    if (widget.searchResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun riad sélectionné")),
      );
      return;
    }

    final riad = widget.searchResults[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Réservation confirmée"),
        content: const Text("Votre réservation a été enregistrée avec succès!"),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RiadDetailPage(
                    name: riad['name']?.toString() ?? 'Nom non spécifié',
                    price: (riad['price']?.toString()) ?? '0',
                    locationtype: riad['locationtype']?.toString() ?? 'Type non spécifié',
                    imageURL: List<String>.from(riad['imageURL'] ?? []),
                    rating: (riad['rating']?.toString()) ?? '0',
                    cityname: riad['cityname']?.toString() ?? 'Ville non spécifiée',
                    latitude: (riad['latitude'] as num?)?.toDouble() ?? 0.0,
                    longitude: (riad['longitude'] as num?)?.toDouble() ?? 0.0,
                    rooms: (riad['rooms']?.toString()) ?? '0',
                    offers: List<String>.from(riad['offers'] ?? []),
                    reviews: const [],
                    selectedServices: const [],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleSearchConfirmation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchResults.isEmpty) {
      return const Scaffold(body: Center(child: Text("Aucun résultat de recherche")));
    }

    final riad = widget.searchResults[0];
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C4C2F),
        title: const Text('Invités', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riad['name']?.toString() ?? 'Nom non disponible',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.searchQuery),
                    const SizedBox(height: 8),
                    Text('${dateFormat.format(widget.startDate)} - ${dateFormat.format(widget.endDate)}'),
                    const SizedBox(height: 8),
                    Text('Prix: ${riad['price']?.toString() ?? 'N/A'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildCounter(
              'Adultes', 
              adults, 
              () => setState(() => adults++),
              () => adults > 1 ? setState(() => adults--) : null,
            ),
            const Divider(),
            _buildCounter(
              'Enfants',
              children,
              () => setState(() => children++),
              () => children > 0 ? setState(() => children--) : null,
            ),
            const Divider(),
            _buildCounter(
              'Bébés',
              babies,
              () => setState(() => babies++),
              () => babies > 0 ? setState(() => babies--) : null,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Avec animaux ?', style: TextStyle(fontSize: 18)),
                Switch(
                  value: pets,
                  onChanged: (value) => setState(() => pets = value),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C4C2F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: widget.fromReservation 
                    ? _handleReservationConfirmation
                    : _handleSearchConfirmation,
                child: Text(
                  widget.fromReservation 
                      ? 'Confirmer la réservation' 
                      : 'Confirmer les invités',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}