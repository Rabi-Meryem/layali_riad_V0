import 'package:flutter/material.dart';
import 'homepage.dart'; // Assure-toi que ce chemin est correct

class GuestsPage extends StatefulWidget {
  final List<dynamic> searchResults;
  final String searchQuery;
  final DateTime startDate;
  final DateTime endDate;

  const GuestsPage({
    super.key,
    required this.searchResults,
    required this.searchQuery,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<GuestsPage> createState() => _GuestsPageState();
}

class _GuestsPageState extends State<GuestsPage> {
  int adults = 2;
  int children = 0;
  int babies = 0;
bool pets = false;

  Widget buildCounter(String label, int value, Function onIncrement, Function onDecrement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => onDecrement(),
            ),
            Text('$value', style: const TextStyle(fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onIncrement(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C4C2F),
        title: const Text('Guests', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('City: ${widget.searchQuery}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              'Dates: ${widget.startDate.day}/${widget.startDate.month}/${widget.startDate.year} → '
              '${widget.endDate.day}/${widget.endDate.month}/${widget.endDate.year}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            buildCounter('Adults', adults, () {
              setState(() {
                adults++;
              });
            }, () {
              setState(() {
                if (adults > 1) adults--;
              });
            }),
            const Divider(),
            buildCounter('Children', children, () {
              setState(() {
                children++;
              });
            }, () {
              setState(() {
                if (children > 0) children--;
              });
            }),
            const Divider(),
            buildCounter('Babies', babies, () {
              setState(() {
                babies++;
              });
            }, () {
              setState(() {
                if (babies > 0) babies--;
              });
            }),
            const Divider(),
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bringing pets?', style: TextStyle(fontSize: 18)),
           Switch(
           value: pets,
           onChanged: (bool value) {
            setState(() {
            pets = value;
        });
      },
    ),
  ],
),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C4C2F),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  // Rediriger vers HomePage avec les données
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        city: widget.searchQuery,
                        startDate: widget.startDate,
                        endDate: widget.endDate,
                        adults: adults,
                        children: children,
                        babies: babies,
                        pets: pets,
                      ),
                    ),
                  );
                },
                child: const Text('Confirm Guests', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
