class History {
  final String plantName;
  final String quantity;
  final String space;
  final String wilaya;
  final String dayra;
  final String baladya;
  final String createdBy;
  final DateTime date;

  History({
    required this.plantName,
    required this.quantity,
    required this.space,
    required this.wilaya,
    required this.dayra,
    required this.baladya,
    required this.createdBy,
    required this.date,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      plantName: json['plant_name'] ?? '',
      quantity: json['quantity']?.toString() ?? '',
      space: json['space'] ?? '',
      wilaya: json['wilaya'] ?? '',
      dayra: json['dayra'] ?? '',
      baladya: json['baladya'] ?? '',
      createdBy: json['created_by'] ?? '',
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plant_name': plantName,
      'quantity': quantity,
      'space': space,
      'wilaya': wilaya,
      'dayra': dayra,
      'baladya': baladya,
      'created_by': createdBy,
      'created_at': date.toIso8601String(),
    };
  }
}
