import 'package:flutter/foundation.dart';

class Employee {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final bool isAdmin;
  final bool active;

  Employee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.isAdmin,
    required this.active,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    debugPrint('Creating Employee from JSON: $json'); // Debug print
    
    final employee = Employee(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['mobile_number']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      active: json['Active'] as bool? ?? true,
    );
    
    debugPrint('Created Employee: ${employee.toString()}'); // Debug print
    return employee;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'mobile_number': phone,
      'password': password,
      'is_admin': isAdmin,
      'Active': active,
    };
  }

  @override
  String toString() {
    return 'Employee(fullName: $fullName, email: $email, phone: $phone, isAdmin: $isAdmin)';
  }
} 