import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/place_model.dart';
import 'package:uuid/uuid.dart';

class PlacesController extends GetxController {
  final _supabase = Supabase.instance.client;
  final places = <Place>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    try {
      isLoading(true);
      error('');

      final response = await _supabase.from('place').select();
      
      final List<Place> fetchedPlaces =
          (response as List).map((json) => Place.fromJson(json)).toList();
      places.assignAll(fetchedPlaces);
        } catch (e) {
      error('Error fetching places: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<String?> addPlace({
    required String wilaya,
    required String dayra,
    required String baladya,
  }) async {
    try {
      isLoading(true);
      error('');

      // Validate inputs
      if (wilaya.trim().isEmpty) {
        return 'Wilaya is required';
      }
      if (dayra.trim().isEmpty) {
        return 'Dayra is required';
      }
      if (baladya.trim().isEmpty) {
        return 'Baladya is required';
      }

      // Check if place already exists
      final existingPlaces = await _supabase
          .from('place')
          .select()
          .eq('wilaya', wilaya)
          .eq('dayra', dayra)
          .eq('baladya', baladya);

      if ((existingPlaces as List).isNotEmpty) {
        return 'This place already exists';
      }

      // Generate UUID for place ID
      const uuid = Uuid();
      final placeId = uuid.v4();

      // Insert new place
      await _supabase.from('place').insert({
        'id_place': placeId,
        'wilaya': wilaya,
        'dayra': dayra,
        'baladya': baladya,
      });

      // Refresh places list
      await fetchPlaces();
      return null; // null means success
    } catch (e) {
      error('Error adding place: $e');
      return 'Error adding place: $e';
    } finally {
      isLoading(false);
    }
  }

  Future<String?> deletePlace(String placeId) async {
    try {
      isLoading(true);
      error('');

      await _supabase.from('place').delete().eq('id_place', placeId);

      await fetchPlaces();
      return null; // null means success
    } catch (e) {
      error('Error deleting place: $e');
      return 'Error deleting place: $e';
    } finally {
      isLoading(false);
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Place> get filteredPlaces {
    if (searchQuery.isEmpty) return places;
    return places.where((place) {
      final searchLower = searchQuery.toLowerCase();
      return place.wilaya.toLowerCase().contains(searchLower) ||
          place.dayra.toLowerCase().contains(searchLower) ||
          place.baladya.toLowerCase().contains(searchLower);
    }).toList();
  }
} 