import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdhanPage extends StatefulWidget {
  const AdhanPage({super.key});

  @override
  State<AdhanPage> createState() => _AdhanPageState();
}

class _AdhanPageState extends State<AdhanPage> {
  Map<String, dynamic> prayerTimes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPrayerTimes();
  }

  Future<void> getPrayerTimes() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    final url =
        'https://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=2';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        prayerTimes = data['data']['timings'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: prayerTimes.entries.map((entry) {
                return Card(
                  child: ListTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
} 