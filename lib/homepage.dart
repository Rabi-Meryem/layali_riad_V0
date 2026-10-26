import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'calenderpage.dart';
import 'riad_detail_page.dart';
import 'wishlistpage.dart';
import 'profil.dart';
import 'message.dart';
import 'wishlist_provider.dart';

class HomePage extends StatefulWidget {
  final String? city;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? adults;
  final int? children;
  final int? babies;
  final bool? pets;

  const HomePage({
    Key? key,
    this.city,
    this.startDate,
    this.endDate,
    this.adults,
    this.children,
    this.babies,
    this.pets,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> riads = [];
  List<dynamic> allRiads = [];
  double _minPrice = 0;
  double _maxPrice = 80000;
  RangeValues _priceRange = const RangeValues(0, 80000);
  int _selectedRoom = 0;
  TextEditingController searchController = TextEditingController();
  bool hasChildren = false;
  bool hasPets = false;
  bool isCitySelected = false;
  bool isCountrySideSelected = false;
  bool isFrontBeachSelected = false;
  bool isPoolSelected = false;
  bool isLoading = true;
  bool isFilterActive = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchRiadData();
  }

  void _initializeData() {
    if (widget.children != null && widget.children! > 0) {
      hasChildren = true;
    }
    if (widget.pets != null) {
      hasPets = widget.pets!;
    }
    if (widget.city != null) {
      searchController.text = widget.city!;
    }
  }

  Future<void> _fetchRiadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String url = 'http://192.168.139.187/mon_api/api.php?';
      
      if (searchController.text.isNotEmpty) {
        url += 'city=${Uri.encodeComponent(searchController.text)}&';
      }
      
      if (hasPets) {
        url += 'pets=true&';
      }
      
      if (hasChildren) {
        url += 'children=true&';
      }

      url = url.replaceAll(RegExp(r'&$'), '');

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          List<dynamic> data = jsonData['data'];
          
          List<Map<String, dynamic>> cleanedData = data.map<Map<String, dynamic>>((item) {
            final riad = Map<String, dynamic>.from(item);
            return {
              ...riad,
              'offers': riad['offers'] is String 
                  ? List<dynamic>.from(jsonDecode(riad['offers'])) 
                  : List<dynamic>.from(riad['offers'] ?? []),
              'imageURL': riad['imageURL'] is String 
                  ? List<dynamic>.from(jsonDecode(riad['imageURL'])) 
                  : List<dynamic>.from(riad['imageURL'] ?? []),
            };
          }).toList();

          setState(() {
            allRiads = cleanedData;
            riads = _applyFilters(cleanedData);
          });
        } else {
          setState(() {
            allRiads = [];
            riads = [];
          });
        }
      } else {
        throw Exception('HTTP error ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        errorMessage = 'La requête a pris trop de temps';
      });
    } on http.ClientException {
      setState(() {
        errorMessage = 'Erreur de connexion au serveur';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de chargement: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> _applyFilters(List<dynamic> riads) {
    List<dynamic> filtered = List.from(riads);

    if (isCitySelected) {
      filtered = filtered.where((riad) => riad['locationtype'] == 'City').toList();
    }

    if (isCountrySideSelected) {
      filtered = filtered.where((riad) => riad['locationtype'] == 'Country Side').toList();
    }

    if (isFrontBeachSelected) {
      filtered = filtered.where((riad) => (riad['offers'] as List).contains('Front Beach')).toList();
    }

    if (isPoolSelected) {
      filtered = filtered.where((riad) => (riad['offers'] as List).contains('Pool')).toList();
    }

    filtered = filtered.where((riad) {
      double price = double.tryParse(riad['price'].toString()) ?? 0.0;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    if (_selectedRoom > 0) {
      filtered = filtered.where((riad) => riad['rooms'] == _selectedRoom).toList();
    }

    if (hasChildren) {
      filtered = filtered.where((riad) => 
        (riad['offers'] as List).any((offer) => offer.toString().contains('Children Friendly')))
        .toList();
    }

    if (hasPets) {
      filtered = filtered.where((riad) => 
        (riad['offers'] as List).any((offer) => offer.toString().contains('Pets Allowed')))
        .toList();
    }

    if (searchController.text.isNotEmpty) {
      filtered = filtered.where((riad) => 
        riad['cityname'].toString().toLowerCase().contains(searchController.text.toLowerCase()) ||
        riad['name'].toString().toLowerCase().contains(searchController.text.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  void _performSearch() {
    if (searchController.text.isEmpty) {
      setState(() {
        riads = allRiads;
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarPage(
          searchResults: allRiads.where((riad) => 
            riad['cityname'].toString().toLowerCase().contains(searchController.text.toLowerCase()) ||
            riad['name'].toString().toLowerCase().contains(searchController.text.toLowerCase())
          ).map((riad) => {
            'name': riad['name'],
            'cityname': riad['cityname'],
            'price': riad['price'],
            'selectedServices': riad['selectedServices'] ?? [],
            'imageURL': riad['imageURL'] ?? [],
            'rating': riad['rating'],
            'latitude': riad['latitude'],
            'longitude': riad['longitude'],
            'rooms': riad['rooms'],
            'offers': riad['offers'],
          }).toList(),
          searchQuery: searchController.text,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? const Color(0xFF4E342E) : Colors.brown.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildRiadCard(List<dynamic> images, String name, String price, String rating, Map<String, dynamic> riadData) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        bool isFavorited = wishlistProvider.isInWishlist(riadData);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    images.isNotEmpty ? images[0] : '',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey,
                      child: const Center(child: Icon(Icons.image, size: 40)),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      wishlistProvider.toggleWishlist(riadData);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: isFavorited ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        price,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _showFilterPanel() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFFF5EBDD),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Filtrer par prix', style: TextStyle(fontWeight: FontWeight.bold)),
                  RangeSlider(
                    values: _priceRange,
                    min: _minPrice,
                    max: _maxPrice,
                    divisions: 20,
                    labels: RangeLabels(
                      '${_priceRange.start.round()}',
                      '${_priceRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Nombre de chambres', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: List.generate(6, (index) {
                      int roomCount = 5 + index;
                      return ChoiceChip(
                        label: Text('$roomCount'),
                        selected: _selectedRoom == roomCount,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRoom = selected ? roomCount : 0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FilterChip(
                        label: const Text('Avec enfants'),
                        selected: hasChildren,
                        onSelected: (value) {
                          setState(() {
                            hasChildren = value;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Avec animaux'),
                        selected: hasPets,
                        onSelected: (value) {
                          setState(() {
                            hasPets = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            riads = _applyFilters(allRiads);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Appliquer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E342E),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
            padding: const EdgeInsets.all(16),
            color: const Color.fromARGB(255, 106, 62, 3),
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Rechercher par nom ou ville',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.brown),
                      onPressed: _performSearch,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Ville', isCitySelected, onTap: () {
                  setState(() {
                    isCitySelected = !isCitySelected;
                    if (isCitySelected) isCountrySideSelected = false;
                    riads = _applyFilters(allRiads);
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Campagne', isCountrySideSelected, onTap: () {
                  setState(() {
                    isCountrySideSelected = !isCountrySideSelected;
                    if (isCountrySideSelected) isCitySelected = false;
                    riads = _applyFilters(allRiads);
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Plage', isFrontBeachSelected, onTap: () {
                  setState(() {
                    isFrontBeachSelected = !isFrontBeachSelected;
                    riads = _applyFilters(allRiads);
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Piscine', isPoolSelected, onTap: () {
                  setState(() {
                    isPoolSelected = !isPoolSelected;
                    riads = _applyFilters(allRiads);
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Filtres', isFilterActive, onTap: _showFilterPanel),
              ],
            ),
          ),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : riads.isEmpty
                    ? const Center(child: Text('Aucun riad trouvé'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: riads.length,
                        itemBuilder: (context, index) {
                          final riad = riads[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RiadDetailPage(
                                    name: riad['name'],
                                    price: '\$${riad['price']}/nuit',
                                    locationtype: riad['locationtype'],
                                    imageURL: riad['imageURL'],
                                    rating: riad['rating'].toString(),
                                    rooms: riad['rooms'].toString(),
                                    cityname: riad['cityname'],
                                    offers: riad['offers'],
                                    reviews: [{'name': 'Host', 'comment': riad['reviews']}],
                                    latitude: riad['latitude'] ?? 31.6295,
                                    longitude: riad['longitude'] ?? -7.9811,
                                    selectedServices: riad['selectedServices'] ?? [],
                                  ),
                                ),
                              );
                            },
                            child: _buildRiadCard(
                              riad['imageURL'],
                              riad['name'],
                              '\$${riad['price']}/nuit',
                              riad['rating'].toString(),
                              riad,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 106, 62, 3),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WishlistPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.message, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MessagingPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}