// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class WaterLevelData {
  final String location;
  final double waterLevel;
  final double waterDepth;
  final double flowSpeed;

  WaterLevelData({
    required this.location,
    required this.waterLevel,
    required this.waterDepth,
    required this.flowSpeed,
  });
}

class WeatherData {
  final String condition;
  final double temperature;
  final double humidity;

  WeatherData({required this.condition, required this.temperature, required this.humidity});

  factory WeatherData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WeatherData(condition: 'Unknown', temperature: 0.0, humidity: 0.0);
    }
    return WeatherData(
      condition: json['conditions'] ?? 'Unknown',
      temperature: double.parse(json['temp']?.toString() ?? '0.0'),
      humidity: double.parse(json['humidity']?.toString() ?? '0.0'),
    );
  }
}

class MyApp extends StatelessWidget {
  final List<WaterLevelData> mockData = [
    WaterLevelData(location: 'Bể A', waterLevel: 0.75, waterDepth: 2.5, flowSpeed: 0.8),
    WaterLevelData(location: 'Bể B', waterLevel: 0.60, waterDepth: 1.8, flowSpeed: 0.6),
    WaterLevelData(location: 'Bể C', waterLevel: 0.85, waterDepth: 3.0, flowSpeed: 1.2),
  ];

  Future<WeatherData> fetchWeatherData() async {
    final url = Uri.parse("https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/Da%20Nang?unitGroup=metric&key=U2MUMUYPGWGVYJHSJXUKLJJFG&contentType=json");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final currentConditions = jsonData['currentConditions'] as Map<String, dynamic>?;
        return WeatherData.fromJson(currentConditions);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Failed to load weather data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giám Sát Mức Nước',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<WeatherData>(
        future: fetchWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
          } else {
            final weatherData = snapshot.data!;
            return WaterLevelScreen(data: mockData, weather: weatherData);
          }
        },
      ),
    );
  }
}

class WaterLevelScreen extends StatelessWidget {
  final List<WaterLevelData> data;
  final WeatherData weather;

  WaterLevelScreen({required this.data, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giám Sát Mức Nước'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWeatherInfo(weather),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final waterLevelData = data[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        waterLevelData.location,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: Icon(
                        Icons.water_damage,
                        size: 40.0,
                        color: Colors.blue,
                      ),
                      children: [
                        ListTile(
                          title: Text(
                            'Mức Nước: ${waterLevelData.waterLevel.toStringAsFixed(2)}',
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Độ Sâu Nước: ${waterLevelData.waterDepth.toStringAsFixed(2)} mét',
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Tốc Độ Dòng Chảy: ${waterLevelData.flowSpeed.toStringAsFixed(2)} m/s',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(WeatherData weather) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dự Báo Thời Tiết:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Tình Trạng: ${weather.condition}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            'Nhiệt Độ: ${weather.temperature.toStringAsFixed(1)} °C',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            'Độ Ẩm: ${weather.humidity.toStringAsFixed(1)} %',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
