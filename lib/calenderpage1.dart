import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'guestspage1.dart';

class CalendarPage1 extends StatefulWidget {
  final List<Map<String, dynamic>> searchResults;
  final String searchQuery;

  const CalendarPage1({
    super.key,
    required this.searchResults,
    required this.searchQuery,
  });

  @override
  State<CalendarPage1> createState() => _CalendarPage1State();
}

class _CalendarPage1State extends State<CalendarPage1> {
  late DateTime _focusedDay;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_selectedStartDate == null) {
      setState(() {
        _selectedStartDate = selectedDay;
        _selectedEndDate = null;
      });
    } else if (_selectedEndDate == null && selectedDay.isAfter(_selectedStartDate!)) {
      setState(() {
        _selectedEndDate = selectedDay;
      });
    } else {
      setState(() {
        _selectedStartDate = selectedDay;
        _selectedEndDate = null;
      });
    }
    _focusedDay = focusedDay;
  }

  void _navigateToGuestsPage1() {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GuestsPage1(
            searchResults: widget.searchResults,
            searchQuery: widget.searchQuery,
            startDate: _selectedStartDate!,
            endDate: _selectedEndDate!,
            fromReservation: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final riad = widget.searchResults.isNotEmpty ? widget.searchResults[0] : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C4C2F),
        title: const Text('Sélection des dates', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          if (riad != null) // Ajout de cette condition
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riad['name'] ?? 'Nom non disponible',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(riad['cityname'] ?? 'Ville non disponible'),
                    const SizedBox(height: 8),
                    Text('Prix: ${riad['price'] ?? 'Prix non disponible'}'),
                    const SizedBox(height: 8),
                    if (riad['selectedServices'] != null && riad['selectedServices'].isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Services sélectionnés:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...(riad['selectedServices'] as List).map((service) => 
                              Text('- $service')).toList(),
                        ],
                      ),
                  ],
                ),
              ),
            ),

          // Calendrier
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedStartDate, day) || 
                     (_selectedEndDate != null && 
                      isSameDay(_selectedEndDate, day));
            },
            rangeStartDay: _selectedStartDate,
            rangeEndDay: _selectedEndDate,
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: Colors.black),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF8C4C2F),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Dates sélectionnées
          if (_selectedStartDate != null || _selectedEndDate != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('ARRIVÉE', style: TextStyle(color: Colors.grey)),
                      Text(
                        _selectedStartDate != null 
                            ? dateFormat.format(_selectedStartDate!)
                            : 'Sélectionner',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('DÉPART', style: TextStyle(color: Colors.grey)),
                      Text(
                        _selectedEndDate != null 
                            ? dateFormat.format(_selectedEndDate!)
                            : 'Sélectionner',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Bouton Confirmer
          if (_selectedStartDate != null && _selectedEndDate != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C4C2F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _navigateToGuestsPage1,
                  child: const Text(
                    'Confirmer les dates',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}