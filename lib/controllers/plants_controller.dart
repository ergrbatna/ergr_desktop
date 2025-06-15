import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/plant_model.dart';
import 'package:uuid/uuid.dart';

class PlantsController extends GetxController {
  final _supabase = Supabase.instance.client;
  final RxList<Plant> plants = <Plant>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = RxString('');
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlants();
  }

  Future<void> fetchPlants() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _supabase.from('plants').select('id_plant, name');

      debugPrint('Supabase Response: $response'); // Debug print

      final List<Plant> fetchedPlants = (response as List).map((json) {
        debugPrint('Processing plant data: $json'); // Debug print
        return Plant.fromJson(json);
      }).toList();

      plants.assignAll(fetchedPlants);
      debugPrint('Processed ${plants.length} plants'); // Debug print
        } catch (e) {
      error.value = 'Error fetching plants: $e';
      debugPrint('Error fetching plants: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Plant> get filteredPlants {
    if (searchQuery.isEmpty) return plants;
    return plants.where((plant) {
      return plant.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          plant.id.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  // Add new plant
  Future<void> addPlant(String name) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Generate UUID that matches Supabase format
      const uuid = Uuid();
      final plantId = uuid.v4(); // Use full UUID without prefix

      // Insert new plant into Supabase
      await _supabase.from('plants').insert({
        'id_plant': plantId,
        'name': name,
      });

      // Refresh plants list
      await fetchPlants();

      Get.snackbar(
        'Success',
        'Plant added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = 'Error adding plant: $e';
      Get.snackbar(
        'Error',
        'Failed to add plant',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete plant
  Future<void> deletePlant(String plantId) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Delete plant from Supabase
      await _supabase.from('plants').delete().eq('id_plant', plantId);

      // Refresh plants list
      await fetchPlants();

      Get.snackbar(
        'Success',
        'Plant deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = 'Error deleting plant: $e';
      Get.snackbar(
        'Error',
        'Failed to delete plant',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
