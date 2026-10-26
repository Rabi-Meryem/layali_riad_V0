import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'riad_map.dart';
import 'calenderpage1.dart'; // Import du calendrier

class RiadDetailPage extends StatefulWidget {
  final String name;
  final String price;
  final String locationtype;
  final List<dynamic> imageURL;
  final String rating;
  final List<dynamic> offers;
  final List<Map<String, dynamic>> reviews;
  final String cityname;
  final String rooms;
  final double latitude;
  final double longitude;
  final List<String>? selectedServices;

  const RiadDetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.locationtype,
    required this.rating,
    required this.cityname,
    required this.latitude,
    required this.longitude,
    required this.rooms,
    this.imageURL = const [],
    this.offers = const [],
    this.reviews = const [],
    this.selectedServices,
  });

  @override
  _RiadDetailPageState createState() => _RiadDetailPageState();
}

class _RiadDetailPageState extends State<RiadDetailPage> {
  TextEditingController reviewController = TextEditingController();
  late List<String> selectedServices;

  final List<Map<String, dynamic>> additionalServices = [
    {'name': 'Wifi', 'icon': Icons.wifi},
    {'name': 'Kitchen', 'icon': Icons.kitchen},
    {'name': 'Driver service', 'icon': Icons.drive_eta},
    {'name': 'Daily cleaning', 'icon': Icons.cleaning_services},
    {'name': 'Mini bar', 'icon': Icons.local_bar},
    {'name': 'Hamam and spa', 'icon': Icons.spa},
    {'name': 'Free parking', 'icon': Icons.local_parking},
    {'name': 'Board games', 'icon': Icons.games},
    {'name': 'Baby crib', 'icon': Icons.child_friendly},
    {'name': 'Babysitting service', 'icon': Icons.child_care},
  ];

  @override
  void initState() {
    super.initState();
    selectedServices = widget.selectedServices ?? [];
  }

  void addReview(String reviewText) {
    setState(() {
      widget.reviews.add({
        'username': 'Client',
        'reviewText': reviewText,
        'timestamp': DateTime.now().toString(),
      });
    });
  }

  void deleteReview(int index) {
    setState(() {
      widget.reviews.removeAt(index);
    });
  }

  void editReview(int index, String newReview) {
    setState(() {
      widget.reviews[index]['reviewText'] = newReview;
    });
  }

  void toggleService(String service) {
    setState(() {
      if (selectedServices.contains(service)) {
        selectedServices.remove(service);
      } else {
        selectedServices.add(service);
      }
    });
  }

  void _navigateToCalendar1() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarPage1(
          searchResults: [{
            'name': widget.name,
            'cityname': widget.cityname,
            'price': widget.price,
            'selectedServices': selectedServices,
            'imageURL': widget.imageURL,
            'rating': widget.rating,
            'offers': widget.offers,
            'latitude': widget.latitude,
            'longitude': widget.longitude,
          }],
          searchQuery: widget.cityname,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imageURL.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    child: Image.network(
                      widget.imageURL[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEFE1D6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 106, 62, 3),
                              ),
                            ),
                            Text(
                              '${widget.cityname} • ${widget.locationtype}',
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating.toString(),
                              style: const TextStyle(fontSize: 16, color: Colors.brown),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Caractéristiques',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FeatureChip(
                          icon: Icons.king_bed,
                          label: '${widget.rooms} chambres'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    const Text(
                      'Options supplémentaires',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: additionalServices.map((service) {
                        return ServiceSelectionRow(
                          icon: service['icon'],
                          label: service['name'],
                          isSelected: selectedServices.contains(service['name']),
                          onTap: () => toggleService(service['name']),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Localisation',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: RiadMap(
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                          riadName: widget.name,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Services inclus',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.offers
                          .map((offer) => OfferRow(icon: Icons.check, label: offer))
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Avis clients',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    widget.reviews.isEmpty
                        ? const Center(
                            child: Text('Aucun avis pour le moment',
                                style: TextStyle(fontSize: 16, color: Colors.grey)))
                        : SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.reviews.length,
                              itemBuilder: (context, index) {
                                final review = widget.reviews[index];
                                return ReviewCard(
                                  review: review,
                                  onEdit: () => editReview(index, 'Nouveau texte'),
                                  onDelete: () => deleteReview(index),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: reviewController,
                      decoration: const InputDecoration(
                        labelText: 'Ajouter un avis...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (reviewController.text.isNotEmpty) {
                          addReview(reviewController.text);
                          reviewController.clear();
                        }
                      },
                      child: const Text('Publier'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 106, 62, 3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.price} / nuit',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFE1D6),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              ),
              onPressed: _navigateToCalendar1,
              child: const Text('Réserver maintenant'),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceSelectionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceSelectionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle,
              color: isSelected ? Colors.brown : Colors.grey,
            ),
            const SizedBox(width: 10),
            Icon(icon, color: Colors.brown),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check, color: Colors.brown),
          ],
        ),
      ),
    );
  }
}

class FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.white,
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review['username'] ?? 'Anonyme',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(review['reviewText'] ?? ''),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OfferRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const OfferRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}