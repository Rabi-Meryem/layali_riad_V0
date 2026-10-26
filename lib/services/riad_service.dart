import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
nnnnnnnn
class RiadService {
  static Future<List<dynamic>> searchRiads({
    String? city, 
    DateTime? startDate, 
    DateTime? endDate
  }) async {
    String url = 'http://votre-domaine/api/search_riads.php?';
    
    if (city != null) url += 'city=${Uri.encodeComponent(city)}&';
    if (startDate != null && endDate != null) {
      url += 'start_date=${DateFormat('yyyy-MM-dd').format(startDate)}&';
      url += 'end_date=${DateFormat('yyyy-MM-dd').format(endDate)}';
    }

    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }
}