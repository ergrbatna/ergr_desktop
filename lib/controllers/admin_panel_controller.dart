import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee_model.dart';
import 'package:flutter/material.dart';

class AdminPanelController extends GetxController {
  final _supabase = Supabase.instance.client;
  final employees = <Employee>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final searchQuery = ''.obs;
  final selectedIndex = 0.obs; // Default to Dashboard view

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  // Validation functions
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidAlgerianPhone(String phone) {
    // Remove leading zero if present
    String normalizedPhone = phone.startsWith('0') ? phone.substring(1) : phone;
    // Check if it's 9 digits starting with 5, 6, or 7
    return RegExp(r'^[5-7][0-9]{8}$').hasMatch(normalizedPhone);
  }

  // Add new employee
  Future<String?> addEmployee({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required bool isAdmin,
  }) async {
    try {
      isLoading(true);
      error('');

      // Validate inputs
      if (fullName.trim().isEmpty) {
        return 'Full name is required';
      }
      if (!isValidEmail(email)) {
        return 'Invalid email format';
      }
      if (!isValidAlgerianPhone(phone)) {
        return 'Invalid phone number format. Use Algerian format (e.g., 512345678)';
      }
      if (password.isEmpty) {
        return 'Password is required';
      }

      // Remove leading zero from phone if present
      String normalizedPhone =
          phone.startsWith('0') ? phone.substring(1) : phone;

      // Check if email already exists
      final existingEmails =
          await _supabase.from('users').select('email').eq('email', email);

      if ((existingEmails as List).isNotEmpty) {
        return 'Email already exists';
      }

      // Check if name already exists
      final existingNames = await _supabase
          .from('users')
          .select('full_name')
          .eq('full_name', fullName);

      if ((existingNames as List).isNotEmpty) {
        return 'Full name already exists';
      }

      // Check if phone already exists
      final existingPhones = await _supabase
          .from('users')
          .select('mobile_number')
          .eq('mobile_number', normalizedPhone);

      if ((existingPhones as List).isNotEmpty) {
        return 'Phone number already exists';
      }

      // Insert new employee
      await _supabase.from('users').insert({
        'full_name': fullName,
        'email': email,
        'mobile_number': normalizedPhone,
        'password': password,
        'is_admin': isAdmin,
      });

      // Refresh employees list
      await fetchEmployees();
      return null; // null means success
    } catch (e) {
      error('Error adding employee: $e');
      return 'Error adding employee: $e';
    } finally {
      isLoading(false);
    }
  }

  // Check if there are multiple admins
  Future<bool> hasMultipleAdmins() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('is_admin', true);
      
      return (response as List).length > 1;
    } catch (e) {
      error('Error checking admin count: $e');
      return false;
    }
  }

  // Delete employee with admin check
  Future<String?> deleteEmployee(String email) async {
    try {
      isLoading(true);
      error('');

      // Get the employee to check if they're an admin
      final employee = await getEmployeeByEmail(email);
      if (employee == null) {
        return 'Employee not found';
      }

      // If employee is admin, check if they're the only admin
      if (employee.isAdmin) {
        final hasOtherAdmins = await hasMultipleAdmins();
        if (!hasOtherAdmins) {
          return 'Cannot delete the only admin in the system';
        }
      }

      await _supabase.from('users').delete().eq('email', email);
      await fetchEmployees();
      return null; // null means success
    } catch (e) {
      error('Error deleting employee: $e');
      return 'Error deleting employee: $e';
    } finally {
      isLoading(false);
    }
  }

  Future<String?> editEmployee({
    required String currentEmail,
    required String newFullName,
    required String newEmail,
    required String newPhone,
    required String newPassword,
    required bool isAdmin,
  }) async {
    try {
      isLoading(true);
      error('');

      // Get the current employee to check admin status
      final currentEmployee = await getEmployeeByEmail(currentEmail);
      if (currentEmployee == null) {
        return 'Employee not found';
      }

      // If changing from admin to non-admin, check if they're the only admin
      if (currentEmployee.isAdmin && !isAdmin) {
        final hasOtherAdmins = await hasMultipleAdmins();
        if (!hasOtherAdmins) {
          return 'Cannot remove admin status from the only admin';
        }
      }

      // Remove leading zero from phone if present
      String normalizedPhone = newPhone.startsWith('0') ? newPhone.substring(1) : newPhone;

      // Validate email format
      if (!isValidEmail(newEmail)) {
        return 'Invalid email format';
      }

      // Check if new email already exists (if changed)
      if (newEmail != currentEmail) {
        final existingEmail = await _supabase
            .from('users')
            .select('email')
            .eq('email', newEmail)
            .maybeSingle();

        if (existingEmail != null) {
          return 'Email already exists';
        }
      }

      // Additional validation for phone number format
      if (normalizedPhone.length != 9) {
        return 'Phone number must be 9 digits (excluding the leading 0)';
      }
      if (!RegExp(r'^[5-7][0-9]{8}$').hasMatch(normalizedPhone)) {
        return 'Phone number must start with 5, 6, or 7 followed by 8 digits';
      }

      // Additional validation for full name
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(newFullName)) {
        return 'Full name can only contain letters and spaces';
      }
      if (newFullName.length < 3) {
        return 'Full name must be at least 3 characters long';
      }
      if (newFullName.length > 50) {
        return 'Full name cannot exceed 50 characters';
      }

      // Update employee if all validations pass
      await _supabase.from('users').update({
        'full_name': newFullName,
        'email': newEmail,
        'mobile_number': normalizedPhone,
        'password': newPassword,
        'is_admin': isAdmin,
      }).eq('email', currentEmail);

      // Refresh employees list
      await fetchEmployees();
      return null; // null means success
    } catch (e) {
      error('Error updating employee: $e');
      return 'Error updating employee: $e';
    } finally {
      isLoading(false);
    }
  }

  Future<Employee?> getEmployeeByEmail(String email) async {
    try {
      final response =
          await _supabase.from('users').select().eq('email', email).single();

      return Employee.fromJson(response);
    } catch (e) {
      error('Error fetching employee: $e');
      return null;
    }
  }

  Future<void> fetchEmployees() async {
    try {
      isLoading(true);
      error('');

      final response = await _supabase.from('users').select();

      final List<Employee> fetchedEmployees =
          (response as List).map((json) => Employee.fromJson(json)).toList();
      employees.assignAll(fetchedEmployees);
        } catch (e) {
      error('Error fetching employees: $e');
    } finally {
      isLoading(false);
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Employee> get filteredEmployees {
    if (searchQuery.isEmpty) return employees;
    return employees.where((employee) {
      final searchLower = searchQuery.toLowerCase();
      return employee.fullName.toLowerCase().contains(searchLower) ||
          employee.email.toLowerCase().contains(searchLower) ||
          employee.phone.toString().contains(searchLower);
    }).toList();
  }

  Future<bool> employeeHasHistory(String userId) async {
    final response = await _supabase.from('history').select().eq('created_by', userId);
    return (response as List).isNotEmpty;
  }

  Future<void> setEmployeeActiveStatus(String userId, bool isActive) async {
    try {
      isLoading(true);
      error('');
      await _supabase.from('users').update({'Active': isActive}).eq('id', userId);
      await fetchEmployees();
      Get.snackbar(
        'Succès',
        isActive ? 'Utilisateur activé' : 'Utilisateur désactivé',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error('Erreur lors de la mise à jour du statut: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le statut',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteEmployeeAndMessages(String userId, String email) async {
    try {
      isLoading(true);
      error('');

      // 1. Delete all messages for this user
      await _supabase.from('messages').delete().eq('mobile_id', userId);

      // 2. Now delete the user
      await _supabase.from('users').delete().eq('id', userId);

      // 3. Refresh employees list
      await fetchEmployees();
    } catch (e) {
      error('Error deleting employee and messages: $e');
    } finally {
      isLoading(false);
    }
  }
}
