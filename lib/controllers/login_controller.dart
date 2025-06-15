import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/admin_panel_controller.dart';
import '../controllers/plants_controller.dart';
import '../controllers/places_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/app_controller.dart';

class LoginController extends GetxController {
  final _supabase = Supabase.instance.client;
  final isLoading = false.obs;
  final error = ''.obs;

  // Add variables to store admin info
  final currentAdminId = RxString('');
  final currentAdminName = RxString('');

  Future<void> login(String identifier, String password) async {
    if (identifier.isEmpty || password.isEmpty) {
      error.value = 'Veuillez remplir tous les champs';
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final response = await _supabase
          .from('users')
          .select()
          .or('email.eq.${identifier},full_name.eq.${identifier}')
          .eq('password', password)
          .eq('Active', true)
          .eq('is_admin', true)
          .single();

      debugPrint('Login response: $response'); // Add this for debugging

      if (response != null) {
        // Store admin information after successful login
        currentAdminId.value = response['id'] ?? '';
        currentAdminName.value = response['full_name'] ?? '';

        // Initialize all required controllers
        Get.put(AdminPanelController());
        Get.put(PlantsController());
        Get.put(PlacesController());
        Get.put(HistoryController());
        Get.put(AppController());

        Get.offAllNamed('/dashbored');
      } else {
        error.value = 'Invalid credentials';
        Get.snackbar(
          'Error',
          'Invalid credentials',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      error.value = 'Invalid credentials';
      Get.snackbar(
        'Error',
        'Invalid credentials',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    // Clear admin information on logout
    currentAdminId.value = '';
    currentAdminName.value = '';
    error.value = '';

    // Delete all controllers except LoginController
    if (Get.isRegistered<AdminPanelController>())
      Get.delete<AdminPanelController>();
    if (Get.isRegistered<PlantsController>()) Get.delete<PlantsController>();
    if (Get.isRegistered<PlacesController>()) Get.delete<PlacesController>();
    if (Get.isRegistered<HistoryController>()) Get.delete<HistoryController>();
    if (Get.isRegistered<AppController>()) Get.delete<AppController>();

    Get.offAllNamed('/login');
  }
}
