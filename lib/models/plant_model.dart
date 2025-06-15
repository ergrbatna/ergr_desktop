import 'package:flutter/foundation.dart';

class Plant {
  final String id;
  final String name;

  Plant({
    required this.id,
    required this.name,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    debugPrint('Creating Plant from JSON: $json'); // Debug print
    
    final plant = Plant(
      id: json['id_plant']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
    
    debugPrint('Created Plant: ${plant.toString()}'); // Debug print
    return plant;
  }

  Map<String, dynamic> toJson() {
    return {
      'id_plant': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Plant(id: $id, name: $name)';
  }
} 