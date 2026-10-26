import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
Future<void> _confirmBooking() async {
  final response = await http.post(
    Uri.parse('http://votre-domaine/api/create_reservation.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'riad_id': widget.riadId,
      'start_date': DateFormat('yyyy-MM-dd').format(_selectedStartDate!),
      'end_date': DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
    }),
  );

  if (response.statusCode == 200) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BookingConfirmationScreen()),
    );
  }
}