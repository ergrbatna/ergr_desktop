import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/places_controller.dart';
import '../models/place_model.dart';

class DeletePlaceView extends StatelessWidget {
  DeletePlaceView({super.key});

  final PlacesController controller = Get.find<PlacesController>();
  final TextEditingController searchController = TextEditingController();

  Future<void> _showDeleteConfirmation(
      BuildContext context, Place place) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete this place?\n\nWilaya: ${place.wilaya}\nDayra: ${place.dayra}\nBaladya: ${place.baladya}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await controller.deletePlace(place.id);
                if (result == null) {
                  Get.snackbar(
                    'Success',
                    'Place deleted successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple,
          child: const Row(
            children: [
              Text(
                'Supprimer Lieu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Rechercher des lieux à supprimer...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Erreur: ${controller.error.value}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.fetchPlaces(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final places = controller.filteredPlaces;

            if (places.isEmpty) {
              return const Center(
                child: Text('No places found'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.place, color: Colors.purple),
                    title: Text(place.wilaya),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dayra: ${place.dayra}'),
                        Text('Baladya: ${place.baladya}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context, place),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
