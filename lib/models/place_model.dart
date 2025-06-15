class Place {
  final String id;
  final String wilaya;
  final String dayra;
  final String baladya;

  Place({
    required this.id,
    required this.wilaya,
    required this.dayra,
    required this.baladya,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id_place'] ?? '',
      wilaya: json['wilaya'] ?? '',
      dayra: json['dayra'] ?? '',
      baladya: json['baladya'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_place': id,
      'wilaya': wilaya,
      'dayra': dayra,
      'baladya': baladya,
    };
  }
} 